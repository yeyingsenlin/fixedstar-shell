#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ./common.sh
#=========================================
nginxPath="/etc/init.d/nginx"
cfgPath="/etc/nginx"
#=========================================
#设置执行权限 
check777 $nginxPath


nginx()
{
	local arg=""
	read -p "请输入命令{status|start|stop|restart|condrestart|try-restart|force-reload|upgrade|reload|help|configtest}:" arg
	if [ "$arg" = "" ]; then
		err "缺少参数，退出"
		return 
	fi
	$nginxPath $arg
	nginx
}
nginx_conf()
{
	vi ${cfgPath}/nginx.conf
}
default_conf()
{
	vi ${cfgPath}/conf.d/default.conf
}
main()
{
	log "------------------------------------------------"
	log "1.nginx 命令操作"
	log "2.nginx.conf 参数配置"
	log "3.default.conf 参数配置"
	log "输入其它退出"
	log "------------------------------------------------"
	arg=1
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
		*)
		exit 2
		;;
	esac
	main
}
main

#read -p "回车退出..." input

