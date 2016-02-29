#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ./lib/common.sh
#=========================================
nodejsPath="./lib/nodejs_cfg.sh"
mongodbPath="./lib/mongodb_cfg.sh"
nginxPath="./lib/nginx_cfg.sh"
memoryPath="./lib/memory_cfg.sh"
logAdminPath="./lib/log_cfg.sh"
#=========================================
#设置执行权限 
check777 $nodejsPath
check777 $mongodbPath
check777 $nginxPath
check777 $memoryPath
check777 $logAdminPath

nodejs()
{
	$nodejsPath
}
mongodb()
{
	$mongodbPath
}
nginx()
{
	$nginxPath
}

memory()
{
	$memoryPath
}
log_admin()
{
	$logAdminPath
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
	local arg=""
	read -p "确认进入crontab编辑吗？[n/y](n):" arg
	if [ ! "$arg" = "y" ]; then
		warn "取消操作..."
		return 
	fi
	crontab -e
}
main()
{
	local logmsg=""
	local logerr=""
	if [ ! -d "$(getLogPath ./lib/)" ]; then
		logmsg="(没有配置日志)"
		logerr="err"
	fi
	log "=================================================="
	log "欢迎使用夜影森林LINUX服务端管理工具："
	log "1.nodejs"
	log "2.mongodb"
	log "3.nginx"
	log "4.内存管理"
	log "5.日志管理${logmsg}" false "" $logerr
	log "6.定时任务设置"
	log "7.开机启动设置"
	log "输入其它退出"
	log "=================================================="
	arg=1
	read -p "请输入选择菜单编号:" arg
	case $arg in
		1)
		nodejs
		;;
		2)
		mongodb
		;;
		3)
		nginx
		;;
		4)
		memory
		;;
		5)
		log_admin
		;;
		6)
		timer_task
		;;
		7)
		vi /etc/rc.local
		;;
		*)
		exit 2
		;;
	esac
	main
}
main

