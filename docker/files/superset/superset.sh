#/bin/bash

if [ ! -e /root/.superset/superset.db ] ; then
  cp -prf  /root/superset/superset.db /root/.superset/superset.db
fi

if [ ! -d /var/log/anaconda ] ; then
  cp -prf /root/log/* /var/log/
fi

trap_TERM() {
  exit 0
}
trap 'trap_TERM' TERM

superset runserver -w 2 &

tail -f /dev/null
