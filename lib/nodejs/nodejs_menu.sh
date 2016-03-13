#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh
#加载项目配置文件
local_conf()
{
	#加载配置参数
    include_conf "nodejs"

	nodejs_exec=$nodejs_exec
	check777 $nodejs_exec
}
local_conf


ps_nodejs()
{
	ps -ef | grep " [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} node" | grep -v "grep"
}

main() {
	log "------------------------------------------------"
	log " - 1.查看被nodejs启动的进程"
	log " - 99.配置本模块参数"
	log " - 输入其它退出"
	log "------------------------------------------------"
	local arg=1
	read -p "请输入选择菜单编号:" arg
	case $arg in
		1)
		ps_nodejs
		;;
		2)
		exec_nodejs
		;;
		99)
		vi ./nodejs.conf
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

