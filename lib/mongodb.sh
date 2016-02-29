#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ./common.sh
#=========================================
home=$2
if [ "$home" = "" ]; then
	home="/usr/local/mongo"
fi
conf="${home}/mongod.conf"
#=========================================
pidfile=$(GetCfg "$conf" "pidfilepath")

config() {
	vi $conf
}
start(){
        if  ps axu|grep mongod|grep -v grep >/dev/null
        then
                $home/bin/mongod -f $conf
        fi
}
stop(){
#       echo "use admin
#       db.shutdownServer()" |$home/bin/mongo
        if [ ! -z $pidfile ]
        then
                kill -2 `cat $pidfile`
                rm -f $home/data/mongod.lock
                echo "mongod exit successful"
        fi
}
status(){
        if [ -z $pidfile ]
        then
                echo "mongod is not running."
        else
                pid=`cat $pidfile`
                echo "mongod is running . pid is $pid "
        fi
}
mongo(){
        if [ -z $pidfile ]
        then
                echo "mongod is not running."
        else
        	$home/bin/mongo
	fi
}


case "$1" in
        start)
                start
                ;;
        stop)
                stop
                ;;
        status)
                status
                ;;
        restart)
                stop
                start
                ;;
        mongo)
                start
                mongo
                ;;

        config)
                config
                ;;
esac
