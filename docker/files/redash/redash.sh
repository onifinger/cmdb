#/bin/bash

if [ ! -d /var/lib/pgsql/data/base ] ; then
  cp -prf  /root/data/* /var/lib/pgsql/data/
  chown -R postgres:postgres /var/lib/pgsql/data
  chmod 0700 /var/lib/pgsql/data
fi

if [ ! -d /var/log/httpd ] ; then
  cp -prf /root/log/* /var/log/
fi

trap_TERM() {
  /usr/sbin/httpd -k stop
  su - postgres -g postgres -c "/usr/bin/pg_ctl stop -D /var/lib/pgsql/data -s -m fast"
  su - redis -g redis -s /bin/bash -c "/usr/bin/redis-shutdown"
  exit 0
}
trap 'trap_TERM' TERM

su - redis -g redis -s /bin/bash -c "/usr/bin/redis-server /etc/redis.conf --daemonize no &"
su - postgres -g postgres -c "/usr/bin/pg_ctl start -D /var/lib/pgsql/data -s -w -t 300"
cd /opt/redash/redash-master
su postgres -c "./bin/run ./manage.py runserver --debugger --reload &"
sleep 30
su postgres -c "./bin/run celery worker --app=redash.worker --beat -Qscheduled_queries,queries,celery -c2 &"
/usr/sbin/httpd  -DFOREGROUND &

tail -f /dev/null
