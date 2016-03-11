#!/bin/bash
cd "$(dirname $0)"
# 加载共用代码
. ../common.sh
#加载配置文件
. ./conf.sh

project_ver=$project_ver
my_nodejs_exec=$my_nodejs_exec
my_back_exec=$my_back_exec

check777 $project_ver
check777 $my_nodejs_exec
check777 $my_back_exec

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
	$project_ver "auto" "${project_name}"
	stop
	start
}

debug()
{
	$project_ver "debug" "${project_name}"
}

build()
{
	$project_ver "build" "${project_name}"
}

clear_debug()
{
	$project_ver "clean" "${project_name}"
}

nodejs()
{
	$my_nodejs_exec "${project_name}" "${1}" "${2}" "${3}"
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
	local execfile=$(getAbsFilePath ${my_nodejs_exec})
	local timearg=$(to_star "*/1 * * * *")
	timer_task "${timearg} sh ${execfile} ${project_name} ${server_name} start_back p"
}

set_start_config()
{
	local execfile=$(getAbsFilePath ${my_nodejs_exec})
	start_config "${execfile} ${project_name} ${server_name} start_back p"
}

log_back()
{
	local arg="n"
	read -p "确定需要立即备份吗？(y/n)${arg}:" arg
	if [ ! "$arg" = "y" ]; then
		warn "取消执行，退出"
		return 
	fi
	local isClear=""
	arg="n"
	read -p "备份后需要删除原日志文件吗？(y/n)${arg}:" arg
	if [ "$arg" = "y" ]; then
		isClear="true"
	fi
	$my_back_exec "${project_name}" "${isClear}"
}
log_auto_back()
{
	local execfile=$(getAbsFilePath ${my_back_exec})
	local timearg=$(to_star "0 3 * * 3")
	timer_task "${timearg} sh ${execfile} ${project_name} true"
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
