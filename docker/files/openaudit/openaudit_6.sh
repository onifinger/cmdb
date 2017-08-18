#/bin/bash

if [ ! -d /var/lib/mysql/mysql ] ; then
  cp -prf /root/mysql/* /var/lib/mysql/
  chown -R mysql:mysql /var/lib/mysql
fi

if [ ! -d /var/log/httpd ] ; then
  cp -prf /root/log/* /var/log/
fi

trap_TERM() {
  service httpd stop
  service mysqld stop
  exit 0
}
trap 'trap_TERM' TERM

service mysqld start
service httpd start
tail -f /dev/null
