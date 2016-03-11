#!/bin/bash
cd "$(dirname $0)"
# 加载共用代码
. ../common.sh

#操作项目名称
project_name=$1

#加载项目配置文件
local_conf()
{
	#加载配置文件
    include_conf "project"

	#项目发布根目录
	project_root="${project_root}/${project_name}"
	default_conf="${project_root}/default.conf"

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


