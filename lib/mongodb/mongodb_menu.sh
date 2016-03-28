#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh

#加载项目配置文件
local_conf()
{
	#加载配置参数
    include_conf "mongodb"
	mongodb_home=$mongodb_home
	mongodb_data=$mongodb_data
	mongodb_bin=$mongodb_bin
	mongodb_conf=$mongodb_conf
}
local_conf

mongodb_exec=$mongodb_exec

#设置执行权限 
check777 $mongodb_exec


mongod()
{
	log "------------------------------------------------"
	log " - - 1.mongod status"
	log " - - 2.mongod mongo"
	log " - - 3.mongod start"
	log " - - 4.mongod restart"
	log " - - 5.mongod stop"
	log " - - 输入其它退出"
	log "------------------------------------------------"
	local arg=""
	read -p "请输入选择菜单编号:" arg
	case $arg in
		1)
		$mongodb_exec "status"
		;;
		2)
		$mongodb_exec "mongo"
		;;
		3)
		$mongodb_exec "start"
		;;
		4)
		$mongodb_exec "restart"
		;;
		5)
		$mongodb_exec "stop"
		;;
		*)
		warn "未选择，退出"
		return
		;;
	esac
	mongod
}
mongodb_back()
{
	local arg="n"
	read -p "确定需要立即备份吗？(y/n)${arg}:" arg
	if [ ! "$arg" = "y" ]; then
		warn "取消执行，退出"
		return 
	fi
	$mongodb_exec "back"
}
mongodb_auto_back()
{
	local execfile=$(getAbsFilePath ${mongodb_exec})
	local timearg=$(to_star "30 3 * * 3")
	timer_task "${timearg} sh $execfile back"
}

mongod_conf()
{
	$mongodb_exec "config"
}


set_timer_task()
{
	local execfile=$(getAbsFilePath ${mongodb_exec})
	local timearg=$(to_star "*/1 * * * *")
	timer_task "${timearg} sh $execfile start"
}

set_start_config()
{
	local execfile=$(getAbsFilePath ${mongodb_exec})
	start_config "$execfile start"
}

main()
{
	log "------------------------------------------------"
	log " - 0.参数配置 (${mongodb_conf})"
	log " - 1.mongod 命令操作"
	log " - 2.mongodb 数据库手动备份 (${mongodb_data})"
	log " - 3.mongodb 数据库自动备份配置"
	log " - 4.mongod 定时检查是否启动，未启动时拉起"
	log " - 5.mongod 开机时启动配置"
	log " - 99.配置本模块参数"
	log " - 输入其它退出"
	log "------------------------------------------------"
	local arg=""
	read -p "请输入选择菜单编号:" arg
	case $arg in
		0)
		mongod_conf
		;;
		1)
		mongod
		;;
		2)
		mongodb_back
		;;
		3)
		mongodb_auto_back
		;;
		4)
		set_timer_task
		;;
		5)
		set_start_config
		;;
		99)
		vi_conf "mongodb"
		local_conf
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

