#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh

#加载项目配置文件
local_conf()
{
	#加载配置文件
	include_conf "video"

	#设置执行权限
	check777 $video_create_exec
}
local_conf


readImg(){
	local id=$(getInput "请输入视频名称（所有）:")
	local r=$(getInput "请输入生成帧率(25):" "25")
	local isre=$(getInput "存在时是否覆盖(y/n)n:" "0" "1")
	if [ "$id" = "" ]; then
	    $video_create_exec "readImgAll" "${r}" "${isre}"
		return
	fi
	$video_create_exec "readImg" "${id}" "${r}" "${isre}"
}



create(){
	local size=$(getInput "视频生成可等比绽放，请输入生成宽度(750):" "750")
	local tile=$(getInput "请输入生成拼图列数(3):" "3")
	local row=$(getInput "请输入生成拼图行数(5):" "5")
	local quality=$(getInput "请输入生成品质0-100(85):" "85")
	local isre=$(getInput "存在时是否覆盖(y/n)n:" "0" "1")
	local id=$(getInput "请输入视频名称（所有）:")
	if [ "$id" = "" ]; then
	    $video_create_exec "createAll" "${size}" "${tile}" "${row}" "${quality}" "${isre}"
        return
	fi
    local isPreview=$(getInput "是否生成单张预览图(y/n)n:" "0" "1")
	$video_create_exec "create" "${size}" "${tile}" "${row}" "${quality}" "${id}" "${isre}" "${isPreview}"
}


zipImg(){
	local size=$(getInput "视频生成可等比绽放，请输入生成宽度:(750)" "750")
	local id=$(getInput "请输入视频名称（所有）:")
	local isre=$(getInput "存在时是否覆盖(y/n)n:" "0" "1")
	if [ "$id" = "" ]; then
	    $video_create_exec "zipAll" "${size}" "${isre}"
        return
	fi
	$video_create_exec "zipImg" "${size}" "${id}" "${isre}"
}


zipSize(){
	local size=$(getInput "请输入生成宽度(750):" "750")
	local actions=$(getInput "请输入要查看的视频名称，多个以空格隔开(所有):")
	$video_create_exec "zipSize" "${size}" "${actions}"
}


main()
{
	log "------------------------------------------------"
	log " - 1.读取mp4文件，生成单帧序列图片"
	log " - 2.从单帧序列图片生成网页可用图片序列"
	log " - 3.压缩生成的网页可用图片序列"
	log " - 4.查看生成压缩包的字节大小"
	log " - 99.配置本模块参数"
	log " - 输入其它退出"
	log "------------------------------------------------"
	local arg=""
	read -p "请输入选择菜单编号:" arg
	case $arg in
		1)
		readImg
		;;
		2)
		create
		;;
		3)
		zipImg
		;;
		4)
		zipSize
		;;
		99)
		vi_conf "video"
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

