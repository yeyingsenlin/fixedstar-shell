#!/bin/bash 

cd "$(dirname $0)"
# 加载共用代码
. ../common.sh
#加载配置文件
include_conf "video"

log_path="$(getAbsFilePath $log_path)"
frames_log_path="$(getAbsFilePath $frames_log_path)"

# 使用视频和图片处理插件 ImageMagick-6.4.0 和 ffmpeg-2.8.4
#
# mkdir A0014
# ffmpeg -i A0014.mp4  A0014/%04d.png
# montage -border 0 -geometry 960x -tile 10x -quality 80% A0014/*.png A0014.jpg



getImageStep()
{
	local count=$1
	local itemCount=$2
	local a=`expr $count % $itemCount`;
	local items=`expr $count / $itemCount`;
	if [ $a -gt 0 ]; then
		items=`expr $items + 1`;
	fi
	echo $items
}

getFileCount()
{
	local count="0"
	# 检查目录是否为空
	local files=`ls ${1}`
	if [ -z "${files}" ]; then
		#warn "${2}=${count}"
		echo $count
		return
	fi

	for v in $files
	do
		count=`expr $count + 1`;
	done
	#log "${2}=${count}"
	echo "$count"
}
readImg()
{
    # 检查目录是否存在
    if [ ! -d "${videoDir}" ]; then
        err "readImg:视频目录${videoDir}不存在，取消执行"
        return
    fi
    if [ ! -d "${imgDir}" ]; then
        err "readImg:生成图片目录${imgDir}不存在，取消执行"
        return
    fi
	local id=$1
	local r=$2 # 帧率
	local isre=$3 # 是否覆盖
	local path="${imgDir}/${id}"
	# 目录存在时，先删除
	if [ -d "${path}" ]; then
		if [ "${isre}" != "1" ]; then
            local count=$(getFileCount "${path}" "${id}")
			#warn "readImg:${id},${count},已存在" ture $log_path
            echo $count
			return 0
		fi
		rm -rf $path
	fi
	mkdir $path
	ffmpeg -i ${videoDir}/${id}.mp4 -r ${r} ${path}/%04d.png
	local count=$(getFileCount "${path}" "${id}")
	#log "readImg:${id},${count},${isre},complete." ture $log_path
	echo $count
}
#readImg "A0011" 1
#readImg "A0011"
#exit

readImgAll()
{
    # 检查目录是否存在
    if [ ! -d "${videoDir}" ]; then
        err "readImgAll:视频目录${videoDir}不存在，取消执行"
        return
    fi
    if [ ! -d "${imgDir}" ]; then
        err "readImgAll:生成图片目录${imgDir}不存在，取消执行"
        return
    fi
	local r=$1 # 帧率
	local isre=$2 # 是否覆盖
	# 进入视频目录循环生成
	log "------------------" true $frames_log_path
	for v in `ls ${videoDir}/*.mp4`
	do
		local id="${v##*/}"
		id="${id%.*}"
		local count=$(readImg "${id}" "${r}" "${isre}")
	    log "${id}=${count}" false $frames_log_path
	done
}

#readImgAll
#exit

create()
{
    # 检查目录是否存在
    if [ ! -d "${movieclipDir}" ]; then
        err "create:生成拼合剪辑目录${movieclipDir}不存在，取消执行"
        return
    fi
    if [ ! -d "${imgDir}" ]; then
        err "create:生成图片目录${imgDir}不存在，取消执行"
        return
    fi
	local size=$1
	local tile=$2
	local row=$3
	local quality=$4
	local id=$5
	local isre=$6 # 是否覆盖
	local isPreview=$7 # 是否为生成预览图，单张
	local path="${imgDir}/${id}"
	# 没有图片目录时，不操作
	if [ ! -d $path ]; then
		err "create:${path},${size} 没有图片目录" ture $log_path
		return
	fi
	local fcount=$(getFileCount ${path} ${id})
	if [ "$fcount" = "0" ]; then
		err "create:${path},${size} 没有图片" ture $log_path
		return
	fi

	# 目录不存在
	if [ ! -d "${movieclipDir}/${size}" ]; then
		# 创建尺寸目录
		mkdir "${movieclipDir}/${size}"
	fi

	# 得到源图总数，配置帧数优先
	local items=`expr $row \* $tile`
	local frames=$(getFrames "${id}")
	if [ "$frames" != "" ]; then
		if [ "$frames" = "1" ]; then
			#isre="1" # 临时强制覆盖单帧生成
			row=1
			tile=1
			items=1
		fi
		fcount=$frames
	fi

	# 目录不存在
	if [ ! -d "${movieclipDir}/${size}/${id}" ]; then
		# 创建尺寸目录
		mkdir "${movieclipDir}/${size}/${id}"
	else
		# 删除旧文件
		if [ "${isre}" != "1" ]; then
			err "create:${id},${size}已存在" ture $log_path
			return 0
		fi
	    rm -rf ${movieclipDir}/${size}/${id}/*
	fi

	# 获取需要生成多少张分解图
	local count=$(getImageStep $fcount $items)
#echo "${id}:$frames $fcount $items $isre ${movieclipDir}/${size}/${id}/*"
#return 0
	local v=0
	for i in `seq $count`
	do
		local file="${movieclipDir}/${size}/${id}/${id}_${i}.jpg"
		if [ "${isPreview}" = "1" ]; then
			file="${movieclipDir}/${size}/${id}_${i}.jpg"
		fi
		local filename=""
		for n in `seq $items`
		do
			# 获取补0格式字符串
			v=`expr $v + 1`
			if [ $v -le $fcount ]; then
				nstr=$(zeroString $v 4)
				filename="${filename} ${path}/${nstr}.png "
			fi
		done
		#echo $filename
		montage -border 0 -geometry ${size}x -tile ${tile}x -quality ${quality}% ${filename} ${file}
	done

	# 上面生成图片会占用较多临时缓存，用下面清理内存和硬盘
	echo 1 > /proc/sys/vm/drop_caches
	#tmpwatch --test 0 /tmp
	tmpwatch 0 /tmp
	log "create:${id},${size},${isre},${fcount}complete." ture $log_path
}


createAll()
{
    # 检查目录是否存在
    if [ ! -d "${movieclipDir}" ]; then
        err "createAll:生成拼合剪辑目录${movieclipDir}不存在，取消执行"
        return
    fi
    if [ ! -d "${imgDir}" ]; then
        err "createAll:生成图片目录${imgDir}不存在，取消执行"
        return
    fi
	local size=$1
	local tile=$2
	local row=$3
	local quality=$4
	local isre=$5 # 是否覆盖
	# 进入视频目录循环生成
	for v in `ls ${videoDir}/*.mp4`
	do
		local id="${v##*/}"
		id="${id%.*}"
		create ${size} ${tile} ${row} ${quality} ${id} ${isre}
		#return 0
	done

}


zipSize()
{
    # 检查目录是否存在
    if [ ! -d "${zipDir}/${videoSize}" ]; then
        err "zipSize:压缩目录${zipDir}/${videoSize}不存在，取消执行"
        return
    fi
    local videoSize=$1
    local actions=$@
    echo $videoSize $actions
    if [ ${#@} = 1 ]; then
        # 检查目录是否为空
        local files=`ls "${zipDir}/${videoSize}"`
        if [ -z "${files}" ]; then
            echo 0
            return
        fi
        actions=($files)
    else
        actions=($@)
        actions=${actions[@]:1}
    fi
    log "--------------" true $zip_log_file
	local s=0
	for name in ${actions}
	do
		local size=$(getFileSize "${zipDir}/${videoSize}/${name}.zip")
        log "${name}=$size" false $zip_log_file
		s=`expr $s + $size`;
	done
	echo `expr ${s} / 1024 / 1024`
}


zipImg()
{
    # 检查目录是否存在
    if [ ! -d "${zipDir}" ]; then
        err "zipImg:压缩目录${zipDir}不存在，取消执行"
        return
    fi
    if [ ! -d "${movieclipDir}/${videoSize}/${id}" ]; then
        err "zipImg:生成拼合剪辑目录${movieclipDir}/${videoSize}/${id}不存在，取消执行"
        return
    fi
    local videoSize=$1
	local id=$2
	local isre=$3 # 是否覆盖
	local zDir="${zipDir}/${videoSize}"
	if [ ! -d "${zDir}" ]; then
        mkdir ${zDir}
	fi
	local zipPath="${zDir}/${id}.zip"
	if [ -f "${zipPath}" ]; then
		if [ "${isre}" != "1" ]; then
			err "zipImg ${zipPath} 已存在"
			return 0
		fi
		rm -f ${zipPath}
	fi
	local cur="$(pwd)"
	cd ${movieclipDir}/${videoSize}/${id}
    zip "${zipPath}" ./*
	cd $cur
}

zipAll()
{
    # 检查目录是否存在
    if [ ! -d "${zipDir}" ]; then
        err "zipAll:压缩目录${zipDir}不存在，取消执行"
        return
    fi
    if [ ! -d "${movieclipDir}/${videoSize}/${id}" ]; then
        err "zipAll:生成拼合剪辑目录${movieclipDir}/${videoSize}/${id}不存在，取消执行"
        return
    fi
    local videoSize=$1
	local isre=$2 # 是否覆盖
	local resDir="${movieclipDir}/${videoSize}"
	# 进入视频目录循环生成
	for id in `ls ${resDir}`
	do
	    zipImg "${videoSize}" "${id}" "${isre}"
	done
}


#ret=$(zeroString 1 4)
#echo $ret


#f="0~1~3"
#montage -border 0 -geometry 750x -tile 3x -quality 85% ./image/A0011/000[${f}].png ./xx.jpg
#f="./image/A0011/0001.png ./image/A0011/0002.png ./image/A0011/0003.png ./image/A0011/0004.png"
#montage -border 0 -geometry 750x -tile 3x -quality 85% $f ./xx.jpg



# 使用 iphone 6s 和 meizu mx4 测试最佳优化效果为 750w 85%
# 因为总图宽高android内超过2250后canvas绘制时会出现异常，测试最佳3列5行
#create 750 3 5 85 "Q0011" "1"
#create 480 3 5 85 "Q0011" "1"

#readImgAll
#createAll 750 3 5 85
#createAll 480 3 5 85
#createAll 100 10 11 50 1 1
#read -p "回车退出..." input


args=($@)
args=${args[@]:1}

case "$1" in
    readImg)
        readImg $args
        ;;
    readImgAll)
        readImgAll $args
        ;;
    create)
        create $args
        ;;
    createAll)
        createAll $args
        ;;
    zipSize)
        zipSize $args
        ;;
    zipImg)
        zipImg $args
        ;;
    zipAll)
        zipAll $args
        ;;
esac
