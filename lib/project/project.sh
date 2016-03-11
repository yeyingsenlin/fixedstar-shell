#!/bin/bash
cd "$(dirname $0)"
# 加载共用代码
. ../common.sh
#加载配置文件
. ./project.conf
project_ver=$project_ver
nodejs_exec=$nodejs_exec
back_exec=$back_exec

check777 $project_ver
check777 $nodejs_exec
check777 $back_exec

#操作项目名称
project_name=$1

#项目发布根目录
project_root="${project_root}/${project_name}"
default_conf="${project_root}/default.conf"


#加载项目配置文件
local_conf()
{
	if [ ! -d "${project_root}" ]; then
		err "项目目录不存在，请先创建项目！"
		exit 2
	fi
	. $default_conf
	local cur="$(pwd)"
	cd "${project_root}"
	server_name=$server_name
	server_local=$server_local
	if [ "$server_local" = "1" ]; then
		server_build=$(getAbsPath ${server_local_build})
	else 
		server_build=$(getAbsPath ${server_build})
	fi
	server_debug=$(getAbsPath ${server_debug})
	server_log=$(getAbsPath ${server_log})
	server_ftp=$(getAbsPath ${server_ftp})
	back_log_zip=$(getAbsFilePath ${back_log_zip})
	cd $cur
}
local_conf

edit_config()
{
	vi $default_conf
	local_conf
	log "配置文件修改完成，并重新加载" 
}

auto()
{
	local arg="n"
	read -p "确认自动执行（清空debug->复制build->解压->切换版本->重新启动）吗？ (y/n)${arg}:" arg
	if [ ! "$arg" = "y" ]; then
		warn "取消执行，退出"
		return 
	fi
	$project_ver "auto" $project_name
	stop
	start
}

debug()
{
	$project_ver "debug" $project_name
}

build()
{
	$project_ver "build" $project_name
}

clear_debug()
{
	$project_ver "clean" $project_name
}

nodejs()
{
	local s_name="${1}"
	local execName="${2}"
	local is_development="${3}"
	if [ "$is_development" = "" ]; then
		is_development="d"
	fi
	$nodejs_exec "$s_name" "$execName" "$is_development" "$server_build" "$server_log"
}

start()
{
	local arg=""
	local s_name=$server_name
	read -p "开始程序名称(${server_name}):" arg
	if [ ! "$arg" = "" ]; then
		s_name=$arg
	fi
	arg="n"
	local execName="start"
	read -p "是否在后台启动？ (y/n)${arg}:" arg
	if [ "$arg" = "y" ]; then
		execName="start_back"
	fi
	arg="n"
	local evn="d"
	read -p "是否运行产品模式？ (y/n)${arg}:" arg
	if [ "$arg" = "y" ]; then
		evn="p"
	fi
	nodejs $s_name $execName $evn
}

stop()
{
	local arg=""
	local s_name=$server_name
	read -p "结束程序名称(${server_name}):" arg
	if [ ! "$arg" = "" ]; then
		s_name=$arg
	fi
	nodejs $s_name "stop"
}

status()
{
	local arg=""
	local s_name=$server_name
	read -p "查看程序名称(${server_name}):" arg
	if [ ! "$arg" = "" ]; then
		s_name=$arg
	fi
	nodejs $s_name "status"
}

set_timer_task()
{
	local execfile=$(getAbsFilePath ${nodejs_exec})
	local timearg=$(to_star "*/1 * * * *")
	timer_task "${timearg} sh ${execfile} ${server_name} start_back p $server_build $server_log"
}

set_start_config()
{
	local execfile=$(getAbsFilePath ${nodejs_exec})
	start_config "${execfile} ${server_name} start_back p $server_build $server_log"
}

log_back()
{
	local arg="n"
	read -p "确定需要立即备份吗？(y/n)${arg}:" arg
	if [ ! "$arg" = "y" ]; then
		warn "取消执行，退出"
		return 
	fi
	$back_exec "zip" "${server_log}" "${back_log_zip}" true
}
log_auto_back()
{
	local execfile=$(getAbsFilePath ${back_exec})
	local timearg=$(to_star "0 3 * * 3")
	timer_task "${timearg} sh ${execfile} ${server_log} ${back_log_zip} true"
}
main() 
{
	local localstr=""
	local disable=""
	if [ "$server_local" = "1" ]; then
		localstr="(本地)"
		disable="disable"
	fi
	local arg=""
	log "------------------------------------------------"
	log " - - 操作项目:${project_name} ${localstr} (ftp:${server_ftp})"
	log " - - 0.编辑项目配置文件"
	log " - - 1.nodejs 查看状态"
	log " - - 2.nodejs 启动项目"
	log " - - 3.nodejs 停止项目"
	log " - - 4.nodejs 重新启动"
	log " - - 5.nodejs 定时检查是否启动，未启动时拉起"
	log " - - 6.nodejs 开机时启动配置"
	log " - - 11.一键快速发布版本" false "" $disable
	log " - - 12.解压新版本" false "" $disable
	log " - - 13.切换版本(build <-> debug)" false "" $disable
	log " - - 14.清理debug目录" false "" $disable
	log " - - 21.日志手动备份" false "" $disable
	log " - - 22.日志自动备份配置" false "" $disable
	log " - - 输入其它退出"
	log "------------------------------------------------"
	read -p "请输入选择菜单编号:" arg
	case $arg in
		0)
		edit_config
		;;
		1)
		status
		;;
		2)
		start
		;;
		3)
		stop
		;;
		4)
		stop
		start
		;;
		5)
		set_timer_task
		;;
		6)
		set_start_config
		;;
		11)
		if [ "$server_local" = "1" ]; then
			err "本地模式下禁用此选项"
		else
			auto
		fi
		;;
		12)
		if [ "$server_local" = "1" ]; then
			err "本地模式下禁用此选项"
		else
			debug
		fi
		;;
		13)
		if [ "$server_local" = "1" ]; then
			err "本地模式下禁用此选项"
		else
			build
		fi
		;;
		14)
		if [ "$server_local" = "1" ]; then
			err "本地模式下禁用此选项"
		else
			clear_debug
		fi
		;;
		21)
		log_back
		;;
		22)
		log_auto_back
		;;
		*)
		warn "未选择，退出"
		exit 2
		;;
	esac
	main
}

main
