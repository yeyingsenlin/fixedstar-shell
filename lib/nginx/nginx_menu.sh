#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh

#加载项目配置文件
local_conf()
{
	#加载配置
    include_conf "nginx"
	nginx_exec=$nginx_exec
	nginx_root=$nginx_root
	nginx_user=$nginx_user
	#设置执行权限
	check777 $nginx_exec
}
local_conf

nginx()
{
	local arg=""
	read -p "请输入命令{status|start|stop|restart|condrestart|try-restart|force-reload|upgrade|reload|help|configtest}:" arg
	if [ "$arg" = "" ]; then
		warn "缺少参数，退出"
		return 
	fi
	$nginx_exec $arg
	nginx
}
nginx_conf()
{
	vi "${nginx_root}/nginx.conf"
}

types_conf()
{
	vi "${nginx_root}/mime.types"
}
default_conf()
{
	local def="default.conf"
	local arg=""
	read -p "请输入配置文件名(${def}):" arg
	if [ "${arg}" = "" ]; then
		arg=${def}
	fi
	vi "${nginx_user}/${arg}"
}


set_timer_task()
{
	local execfile=$(getAbsFilePath ${nginx_exec})
	local timearg=$(to_star "*/1 * * * *")
	timer_task "${timearg} sh $execfile start"
}

set_start_config()
{
	local execfile=$(getAbsFilePath ${nginx_exec})
	start_config "$execfile start"
}

main()
{
	log "------------------------------------------------"
	log " - 1.nginx 命令操作"
	log " - 2.主参数配置 ${nginx_root}/nginx.conf"
	log " - 3.子参数配置 ${nginx_root}/conf.d/[default.conf] "
	log " - 4.类型配置 ${nginx_root}/mime.types"
	log " - 5.nginx 定时检查是否启动，未启动时拉起"
	log " - 6.nginx 开机时启动配置"
	log " - 99.配置本模块参数"
	log " - 输入其它退出"
	log "------------------------------------------------"
	local arg=1
	read -p "请输入选择菜单编号:" arg
	case $arg in
		1)
		nginx
		;;
		2)
		nginx_conf
		;;
		3)
		default_conf
		;;
		4)
		types_conf
		;;
		5)
		set_timer_task
		;;
		6)
		set_start_config
		;;
		99)
		vi ./nginx.conf
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

