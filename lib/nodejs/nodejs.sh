#!/bin/bash
cd "$(dirname $0)"
# 加载共用代码
. ../common.sh

process_name="node"
process_param="${4}/${1}"
execName="${2}"
is_development="${3}"
homePath="${4}"
logPath=""
if [ -d "${5}" ]; then
	logPath="${5}/nodejs_${1}_$(date +%Y-%m-%d).log"
fi


start_back(){
	local pid=`GetPid "${process_name} ${process_param}"`
	if [ "$pid" != "" ]; then
                echo "正在运行，pid:$pid"
	else
		if [ ! -d "${homePath}" ]; then
			err "服务端根目录${homePath}不存在，取消执行"
			return
		fi
		if [ ! -f "${process_param}" ]; then
			err "服务端程序${process_param}不存在，取消执行"
			return
		fi
		cd $homePath
		if [ "$is_development" != "d" ]; then
			export NODE_ENV=production
		else
			export NODE_ENV=development
		fi
		# 加载一些环境变量
		source /etc/profile
		nohup $process_name $process_param  >> $logPath 2>&1 &
                log "从后台启动运行成功" true $logPath
        fi
}
start(){
	local pid=`GetPid "${process_name} ${process_param}"`
	if [ "$pid" != "" ]; then
                echo "正在运行，pid:$pid"
	else
		if [ ! -d "${homePath}" ]; then
			err "服务端根目录${homePath}不存在，取消执行"
			return
		fi
		if [ ! -f "${process_param}" ]; then
			err "服务端程序${process_param}不存在，取消执行"
			return
		fi
		cd $homePath
		if [ "$is_development" != "d" ]; then
			export NODE_ENV=production
		else
			export NODE_ENV=development
		fi
		# 加载一些环境变量
		source /etc/profile
                $process_name $process_param
                log "启动运行成功" true $logPath
        fi
}
stop(){
	local pid=`GetPid "${process_name} ${process_param}"`
	if [ "$pid" != "" ]; then
                kill -2 $pid
                log "成功终止运行" true $logPath
	else
                echo "没有运行"
        fi
}
status(){
	local pid=`GetPid "${process_name} ${process_param}"`
	if [ "$pid" != "" ]; then
                echo "正在运行，pid:$pid"
        else
                echo "没有运行"
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


