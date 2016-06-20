#!/bin/bash

# 配置项
conf_target="local"
# aliyun 如果使用阿里云请开启此项
#conf_target="ali"

vi_conf()
{
    local name="$1"
  	local arg=""
	read -p "请输入配置文件类型(local):" arg
	if [ "$arg" = "" ]; then
		arg="local"
	fi
    local file="./${name}.${arg}.conf"
    vi "${file}"
}
include_conf()
{
    local name="$1"
    local file="./${name}.local.conf"
    if [ ! -f "${file}" ]; then
		err "加载配置文件失败 ${file} ，请配置好文件路径后重试"
		exit 2
    fi
    . "${file}"

	file="./${name}.${conf_target}.conf"
	if [ -f "${file}" ]; then
        . "${file}"
	fi
}


getInput()
{
	local text="$1"
	local default="$2"
	local default2="$3"
	local arg=""
	read -p "${text}" arg
	if [ "$arg" = "" ]; then
	    if [ "$default" != "" ]; then
		    echo "$default"
		    return
		fi
    elif [ ! "$default2" = "" ]; then
		echo "$default2"
		return
	fi
    echo "$arg"
}

getFileSize()
{
    if [ ! -f "${1}" ]; then
		echo 0
		return
    fi
	echo `ls -l ${1} | awk '{ print $5 }'`
}

getFileCount()
{
	local count=0
	# 检查目录是否为空
	local files=`ls ${1}`
	if [ -z "${files}" ]; then
		echo $count
		return
	fi
	local ary=($files)
#	for v in $files
#	do
#		count=`expr $count + 1`;
#	done
	echo ${#ary[*]}
}

zeroString()
{
	local n=$1
	local count=$2
	local len=${#n}
	len=`expr $count - $len`;
	local ret="${n}"
	for i in `seq $len`
	do
		ret="0"${ret}
	done
	echo ${ret}
}

to_star()
{
	echo ${1//"*"/"\052"} 
}

start_config()
{
	echo "直接在文件尾部加上需要执行的命令"
	if [ ! "$1" = "" ]; then 
		echo "示例"
		log "${1}" false "" "tag"
	fi
	local arg=""
	read -p "确认进入 rc.local 编辑吗？[n/y](n):" arg
	if [ ! "$arg" = "y" ]; then
		warn "取消操作..."
		return 
	fi
	vi /etc/rc.local
}

timer_task()
{
	echo "* * * * * command "
	echo "分 时 日 月 周 命令 "
	echo "第1列表示分钟1～59 每分钟用*或者 */1表示 "
	echo "第2列表示小时0～23"
	echo "第3列表示日期1～31 "
	echo "第4列表示月份1～12 "
	echo "第5列标识号星期0～6（0表示星期天）"
	echo "第6列要运行的命令 "
	if [ ! "$1" = "" ]; then 
		echo "示例"
		log "${1}" false "" "tag"
	fi
	local arg=""
	read -p "确认进入 crontab 编辑吗？[n/y](n):" arg
	if [ ! "$arg" = "y" ]; then
		warn "取消操作..."
		return 
	fi
	crontab -e
}
#获取某路径下子目录名称数组，如 ary=($(getDirs ./))
getDirs()
{
	local root=$1
	local cur="$(pwd)"
	cd $root
	local dirs=`ls -l | grep "^d" | awk '{print $9}'`
	cd $cur
	echo $dirs
}
#获取某地址的绝对路径，如 ./a.jpg -> /root/usr/project/a.jpg
getAbsPath()
{
	local root=$1
	if [ ! -d "$root" ]; then
		warn "${root}目录不存在，取消操作..."
		return 
	fi
	local cur="$(pwd)"
	cd $root
	root="$(pwd)"
	cd $cur
	echo $root
}
getAbsFilePath()
{
	local s="$1"
	echo "$(getAbsPath ${s%/*})/${s##*/}"
}
#获取当前文件地址的绝对路径，如 ./a.jpg -> /root/usr/project/a.jpg
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
	local col="$2"
	if [ "${col}" = "" ]; then
		col="2"
	fi
	ps -ef | grep " [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} $1" | grep -v "grep" | awk "{print \$${col}}"
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
		color="36"
	elif [ "$4" = "disable" ]; then
		type="disable"
		color="2"
	fi
	local msg2="\e[${color}m${msg}\e[0m"
	if [ "$isDate" = "true" ]; then
		msg2="$(date +%H:%M:%S) ${msg2}"
	fi
	echo -e $msg2
	if [ "$path" != "" ]; then
		if [ ! -d "${path%/*}" ]; then
			warn "日志目录不存在，没有写入"
			return 
		fi
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
