#/bin/bash

find /var/run/postgresql -type f -exec rm -f {} \;
find /var/run/httpd -type f -exec rm -f {} \;

if [ ! -d /var/lib/pgsql/9.6/data/base ] ; then
  cp -prf  /root/data/* /var/lib/pgsql/9.6/data/
  chown -R postgres:postgres /var/lib/pgsql/9.6/data/
  chmod 0700 /var/lib/pgsql/9.6/data/
fi

if [ ! -d /var/log/httpd ] ; then
  cp -prf /root/log/* /var/log/
fi

if [ ! -d /opt/data/try1 ] ; then
  cp -prf /root/try1 /opt/data/try1
fi

if [ ! -e /opt/parser/Main3.py ] ; then
  cp -p /root/Main3.py /opt/parser/Main3.py
fi

trap_TERM() {
  /usr/sbin/httpd -k stop
  /usr/local/bin/postgresq_stop.sh
  exit 0
}
trap 'trap_TERM' TERM

/usr/sbin/httpd  -DFOREGROUND &
/usr/local/bin/postgresq_start.sh

tail -f /dev/null
