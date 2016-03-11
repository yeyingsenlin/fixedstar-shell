#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh

#加载项目配置文件
local_conf()
{
	#加载配置文件
	include_conf "ftp"

	ftp_config=$ftp_config
	vsftpd_exec=$vsftpd_exec

	#设置执行权限
	check777 $vsftpd_exec
}
local_conf

exec_vsftpd()
{
	local arg=""
	read -p "请输入命令{start|stop|restart|try-restart|force-reload|status}:" arg
	if [ "$arg" = "" ]; then
		warn "缺少参数，退出"
		return 
	fi
	$vsftpd_exec $arg
	exec_vsftpd
}
edit_conf(){
	log "建议：\r\n设置将用户限制仅在帐户目录中访问 chroot_local_user=YES \r\n 如果有425 Security: Bad IP connecting错误，可以配置 pasv_promiscuous=YES" false "" "tag"

	local arg="n"
	read -p "确认进入编辑(y/n)${arg}:" arg
	if [ ! "$arg" = "y" ]; then
		warn "取消执行，退出"
		return 
	fi
	vi ${ftp_config}
}

add() {
	local ftpname=""
	local ftpdir=""
	local arg=""
	read -p "请输入帐户名称:" arg
	if [ "$arg" = "" ]; then
		warn "取消执行，退出"
		return 
	fi
	ftpname="${arg}"
	arg=""
	read -p "请输入帐户目录路径:" arg
	if [ "$arg" = "" ]; then
		warn "取消执行，退出"
		return 
	fi
	ftpdir="$(getAbsFilePath ${arg})"
	useradd -d ${ftpdir} -s /sbin/nologin ${ftpname}
	#setsebool ftp_home_dir on
	chown -R ${ftpname}.${ftpname} ${ftpdir}
}

edit_dir(){
	local ftpname=""
	local ftpdir=""
	local arg=""
	read -p "请输入帐户名称:" arg
	if [ "$arg" = "" ]; then
		warn "取消执行，退出"
		return 
	fi
	ftpname="${arg}"
	arg=""
	read -p "请输入帐户目录路径:" arg
	if [ "$arg" = "" ]; then
		warn "取消执行，退出"
		return 
	fi
	ftpdir="$(getAbsPath ${arg})"
	usermod -d $ftpdir $ftpname
}
password(){
	local ftpname=""
	local arg=""
	read -p "请输入帐户名称:" arg
	if [ "$arg" = "" ]; then
		warn "取消执行，退出"
		return 
	fi
	ftpname="${arg}"
	passwd $ftpname
}
del(){
	local ftpname=""
	local cfg=""
	local arg=""
	read -p "请输入帐户名称:" arg
	if [ "$arg" = "" ]; then
		warn "取消执行，退出"
		return 
	fi
	ftpname="${arg}"
	arg="n"
	read -p "是否也删除此帐户的目录及文件:(y/n)${arg}" arg
	if [ "$arg" = "y" ]; then
		cfg="-r"
	fi
	userdel $cfg $ftpname
}


set_timer_task()
{
	local execfile=$(getAbsFilePath ${vsftpd_exec})
	local timearg=$(to_star "*/1 * * * *")
	timer_task "${timearg} sh $execfile start"
}

set_start_config()
{
	local execfile=$(getAbsFilePath ${vsftpd_exec})
	start_config "$execfile start"
}

main()
{
	log "------------------------------------------------"
	log " - 0.参数配置(${ftp_config})"
	log " - 1.vsftpd 命令操作"
	log " - 2.创建帐户"
	log " - 3.修改帐户目录"
	log " - 4.修改帐户密码"
	log " - 5.删除帐户"
	log " - 6.vsftpd 定时检查是否启动，未启动时拉起"
	log " - 7.vsftpd 开机时启动配置"
	log " - 99.配置本模块参数"
	log " - 输入其它退出"
	log "------------------------------------------------"
	local arg=""
	read -p "请输入选择菜单编号:" arg
	case $arg in
		0)
		edit_conf
		;;
		1)
		exec_vsftpd
		;;
		2)
		add
		;;
		3)
		edit_dir
		;;
		4)
		password
		;;
		5)
		del
		;;
		6)
		set_timer_task
		;;
		7)
		set_start_config
		;;
		99)
		vi ./ftp.conf
		local_conf
		;;
		*)
		exit 2
		;;
	esac
	main
}
main

#read -p "回车退出..." input

