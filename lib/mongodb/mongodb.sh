#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh

#加载项目配置文件
local_conf()
{
	#加载配置参数
    include_conf "mongodb"
	mongodb_home=$mongodb_home
	mongodb_data=$mongodb_data
	mongodb_bin=$mongodb_bin
	mongodb_conf=$mongodb_conf
}
local_conf

log_path="$(getAbsFilePath ${log_path})"
db_back="$(getAbsFilePath ${db_back})"
db_back_path="$(getAbsFilePath ${db_back_path})"
pidfile=$(GetCfg "$mongodb_conf" "pidfilepath")
execstr="$mongodb_home/bin/mongod -f $mongodb_conf"

back_exec=$back_exec
#设置执行权限
check777 $back_exec

config() {
	vi $mongodb_conf
}
start(){
    if  ps axu|grep mongod|grep -v grep >/dev/null
    then
        $execstr
        log "成功运行" true "${log_path}"
    fi
}
stop(){
    local pid=$(GetPid "$execstr")
    if [ "$pid" != "" ]; then
        kill -2 $pid
        rm -f $mongodb_data/mongod.lock
        pid=$(GetPid "$execstr")
        if [ "$pid" != "" ]; then
                echo "use admin
                db.shutdownServer()" | $mongodb_home/bin/mongo
        fi
        log "成功终止运行" true "${log_path}"
    else
        echo "没有运行"
    fi
}
status(){
	local pid=$(GetPid "$execstr")
	if [ "$pid" != "" ]; then
        echo "正在运行，pid:$pid"
    else
        echo "没有运行"
    fi
}
mongo(){
	local pid=$(GetPid "$execstr")
	if [ "$pid" != "" ]; then
        $mongodb_home/bin/mongo
    else
        echo "没有运行"
    fi
}
back(){
    local dbname="${1}"
    local dump="${db_back}/${dbname}"
    if [ "$dbname" != "" ]; then
        $mongodb_home/bin/mongodump -d ${dbname} -o ${dump}
    else
        dbname="all"
        dump="${db_back}/${dbname}"
        $mongodb_home/bin/mongodump -o ${dump}
    fi
	$back_exec "zip" "${dump}" "${db_back_path}" true
}

restore(){
    local dbname="${1}"
    local zipName="${2}"
    local reName="${3}"
    echo "重9999999 ${reName}"
    if [ "${dbname}" = "" ]; then
        echo "没有指定恢复库名称"
        return
    fi
    if [ "${zipName}" = "" ]; then
        echo "没有指定压缩包名称"
        return
    fi
    local dump="${db_back}/${dbname}"
	$back_exec "unzip" "${db_back}" "${db_back}/${zipName}"
    if [ ! -d "${dump}" ]; then
        return
    fi
    #
    echo "use ${dbname}
    db.dropDatabase()" | $mongodb_home/bin/mongo

    if [ "${reName}" = "" ]; then
        $mongodb_home/bin/mongorestore -d ${dbname} ${dump} --drop
    else
        $mongodb_home/bin/mongorestore -d ${reName} ${dump}
    fi
    rm -rf ${dump}
}


case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        start
        ;;
    mongo)
        start
        mongo
        ;;
    config)
        config
        ;;
    back)
        back "$2"
        ;;
    restore)
        restore "$2" "$3" "$4"
        ;;
esac
