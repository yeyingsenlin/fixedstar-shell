#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh
#加载配置参数
include_conf "mongodb"

log_path="$(getAbsFilePath ${log_path})"
db_back_path="$(getAbsFilePath ${db_back_path})"
mongodb_home=$mongodb_home
mongodb_data=$mongodb_data
mongodb_bin=$mongodb_bin
mongodb_conf=$mongodb_conf
pidfile=$(GetCfg "$mongodb_conf" "pidfilepath")
execstr="$mongodb_home/bin/mongod -f $mongodb_conf"

back_exec=$back_exec
#设置执行权限
check777 $back_exec

config() {
	vi $mongodb_conf
}
start(){
        if  ps axu|grep mongod|grep -v grep >/dev/null
        then
                $execstr
                log "成功运行" true "${log_path}"
        fi
}
stop(){
	local pid=$(GetPid "$execstr")
	if [ "$pid" != "" ]; then
                kill -2 $pid
                rm -f $mongodb_data/mongod.lock
		pid=$(GetPid "$execstr")
		if [ "$pid" != "" ]; then
			echo "use admin
			db.shutdownServer()" | $mongodb_home/bin/mongo
		fi
                log "成功终止运行" true "${log_path}"
	else
                echo "没有运行"
        fi
}
status(){
	local pid=$(GetPid "$execstr")
	if [ "$pid" != "" ]; then
                echo "正在运行，pid:$pid"
        else
                echo "没有运行"
        fi
}
mongo(){
	local pid=$(GetPid "$execstr")
	if [ "$pid" != "" ]; then
        	$mongodb_home/bin/mongo
        else
                echo "没有运行"
        fi
}
back(){
	$back_exec "zip" "${mongodb_data}" "${db_back_path}"
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
        back)
                back
                ;;

esac
