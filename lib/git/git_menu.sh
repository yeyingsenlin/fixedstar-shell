#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh

#加载项目配置文件
local_conf()
{
	#加载配置文件
	include_conf "git"

	repositories=$repositories


}
local_conf

add_project()
{
	local arg=""
	read -p "请输入要创建git项目名称:" arg
	if [ "$arg" = "" ]; then
		warn "缺少参数，退出"
		return 
	fi
	local name="${arg}.git"
	echo "su - git
	    cd ${repositories}
        mkdir ${name}
        cd ${name}
        git init --bare
        logout" | su
}

main()
{
	log "------------------------------------------------"
	log " - 0.参数配置(未实现)"
	log " - 1.创建git项目"
	log " - 99.配置本模块参数"
	log " - 输入其它退出"
	log "------------------------------------------------"
	local arg=""
	read -p "请输入选择菜单编号:" arg
	case $arg in
		0)

		;;
		1)
		add_project
		;;
		99)
		vi_conf "git"
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

