#/bin/bash

find /var/run/redis -type f -exec rm -f {} \;
find /var/run/postgresql -type f -exec rm -f {} \;
find /var/run/nginx.pid -type f -exec rm -f {} \;

if [ ! -d /var/opt/rh/rh-postgresql95/lib/pgsql/data/base ] ; then
  cp -prf  /root/data/* /var/opt/rh/rh-postgresql95/lib/pgsql/data/
  chown -R postgres:postgres /var/opt/rh/rh-postgresql95/lib/pgsql/data/
  chmod 0700 /var/opt/rh/rh-postgresql95/lib/pgsql/data/
fi

if [ ! -d /var/log/nginx ] ; then
  cp -prf /root/log/* /var/log/
fi

trap_TERM() {
  nginx -s stop
  pkill gunicorn
  pkill celery
  su - postgres -c '/opt/rh/rh-postgresql95/root/usr/libexec/postgresql-ctl stop -D ${PGDATA} -s -m fast'
  su - redis -g redis -s /bin/bash -c "/usr/bin/redis-shutdown"
  exit 0
}
trap 'trap_TERM' TERM

su - postgres -c '/opt/rh/rh-postgresql95/root/usr/libexec/postgresql-ctl start -D ${PGDATA} -s -w -t ${PGSTARTTIMEOUT}'
sudo -u redis /usr/bin/redis-server /etc/redis.conf --daemonize no &
cd /opt/redash/current
sudo -u redash /opt/redash/current/bin/run gunicorn -b 127.0.0.1:5000 --name redash -w 4 --max-requests 1000 redash.wsgi:app &
sleep 10
sudo -u redash /opt/redash/current/bin/run celery worker --app=redash.worker --beat -c2 -Qqueries,celery --maxtasksperchild=10 -Ofair &
sleep 10
sudo -u redash /opt/redash/current/bin/run celery worker --app=redash.worker -c2 -Qscheduled_queries --maxtasksperchild=10 -Ofair &
sleep 10
/usr/sbin/nginx

tail -f /dev/null
