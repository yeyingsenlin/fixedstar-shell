#!/bin/bash
cd "$(dirname $0)"
#加载配置文件
. ./conf.sh

back_exec=$back_exec

check777 $back_exec

back()
{
	$back_exec "zip" "${server_log}" "${back_log_zip}" "${1}"
}

back "${2}"
