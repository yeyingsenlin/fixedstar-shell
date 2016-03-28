#!/bin/bash



# 加载共用代码
. ./lib/common.sh
#加载配置文件
include_conf "lib/video/video"

actions=$(getFrames A0012)
echo ${actions}


#. ./lib/video/video.local.conf
#
#declare -A actions
#actions=()
#actions["A0011"]=74
#actions["A0012"]=74
#actions["A0013"]=74
#actions["A0014"]=74
#actions["A0024"]=74
#actions["A0025"]=74
#actions["A0121"]=74
#actions["A2111"]=74
#actions["A2211-2"]=74
#actions["A2311"]=74
#actions[B0013-2]=100
#actions[B0021]=100
#actions[B0031]=100
#actions[B0032]=100
#actions[B0122]=100
#actions[B1112]=100
#actions[B1121]=100
#actions[B1311]=100

echo ${actions["A0011"]} ${actions["A2211-2"]} ${actions["B0013-2"]}
echo ${actions[@]}

exit

getInput()
{
	local text="$1"
	local default="$2"
	local default2="$3"
	local arg=""
	read -p "${text}" arg
	if [ "$arg" = "" ]; then
		echo "$default"
		return
    elif [ ! "$default2" = "" ]; then
		echo "$default2"
		return
	fi
    echo "$arg"
}

create(){

	local size=$(getInput "视频生成可等比绽放，请输入生成宽度:(750)" "750")
	local tile=$(getInput "请输入生成拼图列数:(3)" "3")
	local row=$(getInput "请输入生成拼图行数:(5)" "5")
	local quality=$(getInput "请输入生成品质0-100:(85)" "85")
	local isre=$(getInput "存在时是否覆盖:(y/n)n" "0" "1")


    echo $size $tile $row $quality $isre
}

create

exit

a()
{

    if [ ${#@} = 3 ]; then
    echo ${#@}
    fi
    a=$@
    echo "${a[@]:1}"
	for name in ${a[@]:1}
	do
		echo $name
	done
}

a $@



getFileCount()
{
	local count=0
	# 检查目录是否为空
	local files=`ls ${1}`
	if [ -z "${files}" ]; then
		echo $count
		return
	fi
	local ary=($files)
#	for v in $files
#	do
#		count=`expr $count + 1`;
#	done
	echo ${#ary[*]}
}

getFileCount ./
