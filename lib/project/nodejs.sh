#!/bin/bash
cd "$(dirname $0)"
#加载配置文件
. ./conf.sh

nodejs_exec=$nodejs_exec

check777 $nodejs_exec

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

nodejs "${2}" "${3}" "${4}"
