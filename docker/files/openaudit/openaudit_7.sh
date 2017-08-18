#/bin/bash

if [ ! -d /var/lib/mysql/mysql ] ; then
  cp -prf /root/mysql/* /var/lib/mysql/
  chown -R mysql:mysql /var/lib/mysql
fi

if [ ! -d /var/log/httpd ] ; then
  cp -prf /root/log/* /var/log/
fi

trap_TERM() {
  /usr/sbin/httpd -k stop
  /bin/kill -TERM `cat /var/run/mariadb/mariadb.pid`
  exit 0
}
trap 'trap_TERM' TERM

/usr/bin/mysqld_safe --datadir='/var/lib/mysql' &
/usr/sbin/httpd  -DFOREGROUND &
tail -f /dev/null
