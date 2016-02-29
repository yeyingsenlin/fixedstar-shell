#!/bin/bash
cd "$(dirname $0)"
# 加载共用代码
. ./common.sh

process_name="node"
process_param="${1}"
execName="${2}"
is_development="${3}"
homePath="${4}"
logPath="${5}"

start_back(){
	local pid=`GetPid "${process_name} ${process_param}"`
	if [ "$pid" != "" ]; then
                log "node server starting $pid"
	else
		cd $homePath
		if [ "$is_development" != "d" ]; then
			export NODE_ENV=production
		else
			export NODE_ENV=development
		fi
		# 加载一些环境变量
		source /etc/profile
		nohup $process_name $process_param  > $logPath 2>&1 &
                log "node server start for back successful"
        fi
}
start(){
	local pid=`GetPid "${process_name} ${process_param}"`
	if [ "$pid" != "" ]; then
                log "node server starting $pid"
	else
		cd $homePath
		if [ "$is_development" != "d" ]; then
			export NODE_ENV=production
		else
			export NODE_ENV=development
		fi
		# 加载一些环境变量
		source /etc/profile
                $process_name $process_param
                log "node server stopped"
        fi
}
stop(){
	local pid=`GetPid "${process_name} ${process_param}"`
	if [ "$pid" != "" ]; then
                kill -2 $pid
                log "node server exit successful"
	else
		log "node server not starting"
        fi
}
status(){
	local pid=`GetPid "${process_name} ${process_param}"`
	if [ "$pid" != "" ]; then
                log "node server is running . pid is $pid "
        else
		log "node server not starting"
        fi
}


case "$execName" in
	start_back)
	        start_back
	        ;;
	start)
	        start
	        ;;
	stop)
	        stop
	        ;;
	restart)
	        stop
	        start
	        ;;
	restart_back)
	        stop
	        start_back
	        ;;
	status)
	        status
	        ;;
esac


