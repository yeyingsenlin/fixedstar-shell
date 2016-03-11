#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh
#加载配置文件
include_conf "project"


#操作项目名称
project_name=$2
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
	if [ ! -f "${default_conf}" ]; then
		err "项目配置文件不存在，请先创建！"
		exit 2
	fi
	. $default_conf
	server_name=$server_name
	local cur="$(pwd)"
	cd "${project_root}"
	server_build=$(getAbsPath ${server_build})
	server_debug=$(getAbsPath ${server_debug})
	server_log=$(getAbsPath ${server_log})
	server_ftp=$(getAbsPath ${server_ftp})
	server_zip=$(getAbsFilePath ${server_zip})
	cd $cur
	if [ ! -d "${server_build}" ]; then
		err "项目 build 目录不存在，请确认项目配置是否正确！"
		exit 2
	fi
	if [ ! -d "${server_debug}" ]; then
		err "项目 debug 目录不存在，请确认项目配置是否正确！"
		exit 2
	fi
	if [ ! -d "${server_log}" ]; then
		err "项目 log 目录不存在，请确认项目配置是否正确！"
		exit 2
	fi
	if [ ! -d "${server_ftp}" ]; then
		err "项目 ftp 目录不存在，请确认项目配置是否正确！"
		exit 2
	fi
	logPath="${server_log}/ver_${project_name}_$(date +%Y-%m-%d).log"
}
local_conf


#下面不要改动
debugAll="$server_debug/*"
buildAll="$server_build/*"
debug(){
	log "" false $logPath
	log "正在发布${project_name} debug" true $logPath
	local isClean="$1"
	if [ "$isClean" = "" ]; then
		isClean="n"
	fi
	if [ ! "$isClean" = "y" ]; then
		read -p "是否需要清空 debug 目录，并复制 build 内容(y/n)$isClean:" isClean
	fi
	if [ "$isClean" == "y" ]; then
		rm -rf $debugAll
		log "debug 目录清理完成" false $logPath
		cp -rf $buildAll $server_debug
		log "从 build 目录复制文件完成" false $logPath
	fi
	unzip -o -d $server_debug $server_zip
	log "解压并覆盖文件完成" false $logPath
}

build(){
	local tempPath="${project_root}/__temp__"
	mv $server_build $tempPath
	mv $server_debug $server_build
	mv $tempPath $server_debug
	log "切换版本完成" true $logPath
}

clean(){
	local isClean="$1"
	if [ "$isClean" = "" ]; then
		isClean="n"
	fi
	if [ ! "$isClean" = "y" ]; then
		read -p "是否需要清空 debug 目录(y/n)$isClean:" isClean
	fi
	if [ ! "$isClean" = "y" ]; then
		log "取消清理" false $logPath
		return
	fi
	local files=`ls ${server_debug}`
	if [  -z "${files}" ]; then
		log "目录是空的，不需要清理" false $logPath
		return
	fi
	rm -rf $debugAll
	log "debug 目录清理完成" true $logPath
}


case "$1" in
	debug)
	        debug
	        ;;
	build)
	        build
	        ;;
	clean)
	        clean
	        ;;
	auto)
		debug "y"
		build
		;;
	*)
		exit 2
	        ;;
esac


