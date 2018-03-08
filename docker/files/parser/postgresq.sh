PATH=$PATH:/usr/pgsql-9.6/bin
export PATH

PGDATA=/var/lib/pgsql/9.6/data
export PGDATA

PGLOG=/var/lib/pgsql/9.6/initdb.log
export PGLOG

export PG_OOM_ADJUST_FILE=/proc/self/oom_score_adj
export PG_OOM_ADJUST_VALUE=0
export PGSTARTTIMEOUT=270
