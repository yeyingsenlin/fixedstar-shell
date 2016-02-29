#!/bin/bash
#=========================================
#日志主目录配置
pathFile="./log.conf"
#=========================================
getLogPath()
{
	echo `cat ${1}${pathFile}`
}
getFilePath()
{
	echo "$(pwd)/${0##*/}"
}
#获取文件大小
getSize()
{
	local v=`ls -l ${1} | awk '{ print $5 }'`
	echo $v
}
#设置执行权限 
check777()
{
	if [ ! -x $1 ]; then 
		#设置执行权限 
		sudo chmod 777 $1
	fi 
}

# 从配置文件里获取定义的参数值
GetCfg()
{
	local filepath=$1
	local cfgname=$2
	local v=`sed '/^'${cfgname}'=/!d;s/.*=//' ${filepath}`
	echo $v
}

# 一个取程序进程pid的方法
# pid=`GetPid "${process_name} ${process_param}"`
GetPid()
{
	# $1 表示传进来的第一个参数, $是正则的结束符
	# awk 的$2表示从结果里, 输出第二列
	ps -ef | grep "$1\$" | grep -v "grep" | awk '{print $2}'
}

# 输出日志，参数1日志内容，参数2是日志文件路径（空则不写）
# pid=`GetPid "${process_name} ${process_param}"`
log()
{
	local msg="$1"
	local isDate="$2"
	local path="$3"
	local type="log"
	local color="32"
	if [ "$4" = "err" ]; then
		type="error"
		color="31"
	elif [ "$4" = "warn" ]; then
		type="warn"
		color="33"
	elif [ "$4" = "tag" ]; then
		type="tag"
		color="35"
	fi
	local msg2="\e[${color}m${msg}\e[0m"
	if [ "$isDate" = "true" ]; then
		msg2="$(date +%H:%M:%S) ${msg2}"
	fi
	echo -e $msg2
	if [ "$path" != "" ] && [ -f "$path" ]; then
		echo -e "$(date +%Y-%m-%d_%H:%M:%S) ${type} : ${msg}" >> $path 2>&1 &
	fi
}

err()
{
	log "$1" "$2" "$3" "err"
}


warn()
{
	log "$1" "$2" "$3" "warn"
}
