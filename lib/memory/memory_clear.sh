#!/bin/bash 
# 当内存使用超过定额时，调用清理内存，本程序需要在 crontab -e 里配置定时启动招行

cd "$(dirname $0)"
# 加载共用代码
. ../common.sh
#加载配置文件
include_conf "memory"

log_path="$(getAbsFilePath $log_path)"
mem_auto_clear=$mem_auto_clear

mem_quota=$1
if [ "${mem_quota}" = "" ]; then 
	mem_quota=$mem_auto_clear
fi
if [ "${mem_quota}" = "" ]; then 
	mem_quota=20
fi


watch_mem() 
{ 
  local memtotal=`cat /proc/meminfo |grep "MemTotal"|awk '{print $2}'` 
  local memfree=`cat /proc/meminfo |grep "MemFree"|awk '{print $2}'` 
  #local cached=`cat /proc/meminfo |grep "^Cached"|awk '{print $2}'` 
  #local buffers=`cat /proc/meminfo |grep "Buffers"|awk '{print $2}'` 

  local n=$((memfree*100/memtotal))
  #local mem_usage=$((100-memfree*100/memtotal-buffers*100/memtotal-cached*100/memtotal)) 

  if [ $n -lt $mem_quota ];then 
    log "开始清理:剩余内存$n％，free:${memfree}，total:${memtotal}" true $log_path
    echo 1 > /proc/sys/vm/drop_caches
    memtotal=`cat /proc/meminfo |grep "MemTotal"|awk '{print $2}'` 
    memfree=`cat /proc/meminfo |grep "MemFree"|awk '{print $2}'` 
    n=$((memfree*100/memtotal))
    log "清理完成:剩余内存$n％，free:${memfree}，total:${memtotal}" false $log_path
    return 1 
  else 
    return 0 
  fi 
}

watch_mem 
 
