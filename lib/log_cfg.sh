#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ./common.sh
curDir="$(pwd)"
#=========================================
logAdminPath="./log.sh"
#得到上一级的日志目录地址
cd ..
defaultPath="$(pwd)/log"
cd $curDir
#=========================================
#设置执行权限 
check777 $logAdminPath


remove()
{
	local arg=""
	read -p "请输入命令${cfg}:" arg
	if [ ! "$arg" = "y" ]; then
		warn "取消操作..."
		return 
	fi
	rm -rf ../log/*/*.log
}
set_path()
{
	echo "当前日志主目录:$(getLogPath)"
	local arg=""
	read -p "请输入新日志主目录(${defaultPath}):" arg
	if [ "$arg" = "" ]; then
		arg=$defaultPath
	fi
	if [ ! -d "${arg}" ]; then
		err "没有找到目录 ${arg}"
		return 
	fi
	echo $arg > $pathFile
}
back()
{
	echo "back"
}
main()
{
	local logmsg=""
	local logerr=""
	if [ ! -d "$(getLogPath)" ]; then
		logmsg="(没有配置日志)"
		logerr="err"
		echo "" > $pathFile
	fi
	log "------------------------------------------------"
	log "1.显示日志主目录"
	log "2.配置日志主目录${logmsg}" false "" $logerr
	log "3.备份所有日志"
	log "4.删除所有日志"
	log "5.设置自动备份日志 crontab -e （复制参考下面代码添加到crontab）"
	echo "# 配置(每周1 3:30)定时执行备份"
	echo "30 3 * * 1 sh $(pwd)/${logAdminPath} "
	log "输入其它退出"
	log "------------------------------------------------"
	local arg=""
	read -p "请输入选择菜单编号:" arg
	case $arg in
		1)
		echo "$(getLogPath)"
		;;
		2)
		set_path
		;;
		3)
		back
		;;
		4)
		remove
		;;
		5)
		crontab -e
		;;
		*)
		exit 2
		;;
	esac
	main
}
main

#read -p "回车退出..." input

