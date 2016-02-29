#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ./common.sh
#日志主目录配置
logPath="$(getLogPath)"
#=========================================
logPath="$(pwd)/../log/memory/$(date +%Y%m%d).log"
# 开始清理的最小内存百分比
mem_quota=20
#程序路径
memoryClear="./memory_clear.sh"
check777 $memoryClear
#=========================================

mem_clear()
{
	$memoryClear 100 $logPath
}
auto_clear()
{
	crontab -e
}
look()
{
	free -m
}
main()
{
	log "------------------------------------------------"
	log "1.查看内存情况 free -m"
	log "2.清理内存"
	log "3.设置自动清理内存 crontab -e （复制参考下面代码添加到crontab）"
	echo "*/10 * * * * sh $(pwd)/${memoryClear} ${mem_quota} ${logPath}"
	log "输入其它退出"
	log "------------------------------------------------"
	local arg=""
	read -p "请输入选择菜单编号:" arg
	case $arg in
		1)
		look
		;;
		2)
		mem_clear
		;;
		3)
		auto_clear
		;;
		*)
		exit 2
		;;
	esac
	main
}
main

#read -p "回车退出..." input

