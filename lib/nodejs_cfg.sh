#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ./common.sh
#=========================================
#在下面配置多项目参数
declare -A aisocool
aisocool=(
[serverName]="app" # 服务端程序名称
[serverPath]="$(pwd)/../../../aisocool/server" # 服务端程序路径
[logPath]="$(pwd)/../log/aisocool/$(date +%Y%m%d).log" # 日志路径
)
declare -A dbell
dbell=(
[serverName]="app" # 服务端程序名称
[serverPath]="$(pwd)/../../../dbell/server" # 服务端程序路径
[logPath]="$(pwd)/../log/dbell/$(date +%Y%m%d).log" # 日志路径
)
declare -A juuju
juuju=(
[serverName]="app" # 服务端程序名称
[serverPath]="$(pwd)/../../../juuju/server" # 服务端程序路径
[logPath]="$(pwd)/../log/juuju/$(date +%Y%m%d).log" # 日志路径
)
apps="aisocool|dbell|juuju"
#程序路径
nodePath="./nodejs.sh"
check777 $nodePath
#=========================================

main() {
	log "------------------------------------------------"
	log "nodejs 命令参数"
	log "项目名称${apps}"
	log "操作命令{start|restart|start_back|stop|status}"
	log "项目名称{d|p}"
	log "------------------------------------------------"
	read -p "请输入(项目名称 操作命令 执行模式):" arg1 arg2 arg3

	#参数1：项目名称
	local appName="${arg1}"
	if [ "$appName" = "" ]; then
		err "缺少参数1：操作命令，退出"
		return
	fi
	#参数2：操作命令
	local execName="${arg2}"
	if [ "$execName" = "" ]; then
		err "缺少参数2：操作命令，退出"
		return
	fi
	#参数3：执行模式
	local execMode="${arg3}"
	if [ "$execMode" != "p" ]; then
		execMode="d"
	fi
	#=========================================
	#设置执行权限 
	eval serverName="\${$appName[serverName]}"
	eval serverPath="\${$appName[serverPath]}"
	eval logPath="\${$appName[logPath]}"
	log "开始执行项目 $appName 的 $execName 命令 $execMode"
	log "serverName : $serverName"
	log "serverPath : $serverPath"
	log "logPath : $logPath"

	$nodePath $serverName $execName $execMode $serverPath $logPath 
	main
}
main
#read -p "回车退出..." input

