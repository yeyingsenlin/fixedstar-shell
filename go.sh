#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ./lib/common.sh
#=========================================
project_menu="./lib/project/project_menu.sh"
nodejs_menu="./lib/nodejs/nodejs_menu.sh"
mongodb_menu="./lib/mongodb/mongodb_menu.sh"
nginx_menu="./lib/nginx/nginx_menu.sh"
memory_menu="./lib/memory/memory_menu.sh"
ftp_menu="./lib/ftp/ftp_menu.sh"
video_menu="./lib/video/video_menu.sh"
#=========================================
#设置执行权限 
check777 $project_menu
check777 $nodejs_menu
check777 $mongodb_menu
check777 $nginx_menu
check777 $memory_menu
check777 $ftp_menu
check777 $video_menu

project_menu()
{
	$project_menu
}
nodejs_menu()
{
	$nodejs_menu
}
mongodb_menu()
{
	$mongodb_menu
}
nginx_menu()
{
	$nginx_menu
}

memory_menu()
{
	$memory_menu
}
log_menu()
{
	$log_menu
}
set_ftp()
{
	$ftp_menu
}
video()
{
	$video_menu
}
main()
{
	local logmsg=""
	log "=================================================="
	log "欢迎使用夜影森林LINUX服务端管理工具："
	log "1.项目管理"
	log "2.nodejs"
	log "3.mongodb"
	log "4.nginx"
	log "5.内存管理"
	log "6.ftp"
	log "7.定时任务设置"
	log "8.开机启动设置"
	log "9.视频处理"
	log "输入其它退出"
	log "=================================================="
	arg=1
	read -p "请输入选择菜单编号:" arg
	case $arg in
		1)
		project_menu
		;;
		2)
		nodejs_menu
		;;
		3)
		mongodb_menu
		;;
		4)
		nginx_menu
		;;
		5)
		memory_menu
		;;
		5)
		log_menu
		;;
		6)
		set_ftp
		;;
		7)
		timer_task
		;;
		8)
		start_config
		;;
		9)
		video
		;;
		*)
		warn "未选择，退出"
		exit 2
		;;
	esac
	main
}
main

