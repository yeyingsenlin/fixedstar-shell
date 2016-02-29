#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ./common.sh
#=========================================
dbPath="/usr/local/mongo"
mongoPath="./mongodb.sh"
#=========================================
#设置执行权限 
check777 $mongoPath


mongod()
{
	local cfg="{status|mongo|start|restart|stop}"
	local arg=""
	read -p "请输入命令${cfg}:" arg
	if [ "$arg" = "" ]; then
		err "缺少参数，退出"
		return 
	fi
	$mongoPath $arg $dbPath
	mongod
}
mongodb_back()
{
	echo "mongodb_back"
}
mongodb_auto_back()
{
	echo "mongodb_auto_back"
}
mongod_conf()
{
	$mongoPath "config" $dbPath
}
main()
{
	log "------------------------------------------------"
	log "1.mongod 命令操作"
	log "2.mongod.conf 参数配置"
	log "3.mongodb 数据库手动备份"
	log "4.mongodb 数据库自动备份配置"
	log "输入其它退出"
	log "------------------------------------------------"
	local arg=""
	read -p "请输入选择菜单编号:" arg
	case $arg in
		1)
		mongod
		;;
		2)
		mongod_conf
		;;
		3)
		mongodb_back
		;;
		4)
		mongodb_auto_back
		;;
		*)
		exit 2
		;;
	esac
	main
}
main

#read -p "回车退出..." input

