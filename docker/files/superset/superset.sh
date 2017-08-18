#/bin/bash

if [ ! -d /root/.superset ] ; then
  cp -prf  /root/superset /root/.superset
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
