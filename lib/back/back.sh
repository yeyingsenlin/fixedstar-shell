#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh
#加载配置参数
include_conf "back"
log_path="$(getAbsFilePath ${log_path})"



zip_back(){
	local curDir="$(pwd)"
	local targetDir="${1}"
	local zipPath="${2}"
	local isClear="${3}"
	if [ ! -d "${targetDir}" ]; then
		err "压缩备份失败=========== \r\n备份源文件目录不存在：${targetDir} \r\n" true "${log_path}"
		return
	fi
	if [ ! -d "${zipPath%/*}" ]; then
		err "压缩备份失败=========== \r\n压缩备份结果目录不存在：${zipPath} \r\n" true "${log_path}"
		return
	fi
	local count=$(getFileCount "${targetDir}")
	if (( count == 0 )); then
		warn "压缩备份失败=========== \r\n备份源文件目录为空：${zipPath} \r\n" true "${log_path}"
		return
	fi
	cd ${targetDir}
	zip -r "${zipPath}" ./*
	if [ "${isClear}" = "true" ]; then
		rm -rf ${targetDir}
	fi
	cd $curDir
	log "压缩备份完成------------------------ \r\n备份源文件：${targetDir} \r\n压缩备份结果：${zipPath} \r\n是否清理了备份源文件：${isClear} \r\n" true "${log_path}"
}

unzip_back(){
	local targetDir="${1}"
	local zipPath="${2}"
	local isClear="${3}"
	if [ ! -d "${targetDir}" ]; then
		err "解压缩失败=========== \r\n源文件目录不存在：${targetDir} \r\n" true "${log_path}"
		return
	fi
	if [ ! -d "${zipPath%/*}" ]; then
		err "解压缩失败=========== \r\n解压缩结果目录不存在：${zipPath} \r\n" true "${log_path}"
		return
	fi
    unzip -o -d "${targetDir}" "${zipPath}"
	if [ "${isClear}" = "true" ]; then
		rm -f "${zipPath}"
	fi
	log "解压缩完成------------------------ \r\n源文件：${targetDir} \r\n压缩结果：${zipPath} \r\n是否清理了源文件：${isClear} \r\n" true "${log_path}"
}


case "$1" in
        zip)
		zip_back "${2}" "${3}" "${4}"
		;;
        unzip)
		unzip_back "${2}" "${3}" "${4}"
		;;
esac
