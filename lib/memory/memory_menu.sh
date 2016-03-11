#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh
#加载配置文件
. ./memory.conf
mem_clear_exec="$(getAbsFilePath $mem_clear_exec)"

check777 $mem_clear_exec

mem_clear()
{
	$mem_clear_exec 100
}
set_timer_task()
{
	local execfile=$(getAbsFilePath ${mem_clear_exec})
	local timearg=$(to_star "* */1 * * *")
	timer_task "${timearg} sh $execfile"
}
look()
{
	free -m
}
clear_sys_temp()
{
	# 占用较多临时缓存，用下面清理内存和硬盘
	echo 1 > /proc/sys/vm/drop_caches
	#tmpwatch --test 0 /tmp
	tmpwatch 0 /tmp
	echo "临时缓存清理完成"
}
main()
{
	log "------------------------------------------------"
	log " - 1.查看内存情况 free -m"
	log " - 2.清理内存"
	log " - 3.设置定时自动清理内存"
	log " - 4.清理系统临时文件"
	log " - 99.配置本模块参数"
	log " - 输入其它退出"
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
		set_timer_task
		;;
		4)
		clear_sys_temp
		;;
		99)
		vi ./memory.conf
		;;
		*)
		warn "未选择，退出"
		exit 2
		;;
	esac
	main
}
main

#read -p "回车退出..." input

