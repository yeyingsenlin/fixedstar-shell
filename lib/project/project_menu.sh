#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh

#加载项目配置文件
local_conf()
{
	#加载配置文件
    include_conf "project"
	project_exec=$project_exec
	templete=$templete
	templete_conf=$templete_conf
	#项目发布根目录
	project_root=$(getAbsPath ${project_root})
	#项目发布根目录不存在时，就创建
	if [ ! -d "${project_root}" ]; then
		mkdir "${project_root}"
	fi
	check777 $project_exec
}
local_conf

create_project()
{
	local arg=""
	read -p "项目名称:" arg
	if [ "$arg" = "" ]; then
		err "缺少名称，退出"
		return
	else
		if [ -d "${project_root}/${arg}" ]; then
			err "项目已存在，不能重复创建同名项目！"
			return
		fi
	fi
	local path="${project_root}/${arg}"
	cp -a $templete $path
}

project_main() {
	$project_exec "$1"
}

main() {
	local dirs=($(getDirs $project_root))
	local len=${#dirs[@]}
	log "------------------------------------------------"
	log " - 0.创建项目($project_root)"
	if [ ! "$len" = "" ]; then
		for((i=0;i<$len;i++))
		do
			log " - `expr ${i} + 1`.${dirs[${i}]}"
		done
	fi
	log " - 98.配置项目模板参数"
	log " - 99.配置本模块参数"
	log " - 输入其它退出"
	log "------------------------------------------------"
	local arg=1
	read -p "请选择项目编号:" arg
	case $arg in
		0)
		create_project
		;;
		98)
		vi $templete_conf
		;;
		99)
		vi_conf "project"
		local_conf
		;;
		*)
		if (( arg > 0 )) && (( arg <= len )); then
			local project_name="${dirs[`expr $arg - 1`]}"
			project_main "${project_name}"
		else
			warn "未选择，退出"
			exit 2
		fi
		;;
	esac
	main
}
main
#read -p "回车退出..." input

