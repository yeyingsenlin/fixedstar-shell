#!/bin/bash
cd "$(dirname $0)"
#加载公共函数
. ../common.sh



edit_config()
{
	local arg="0"
	log "------------------------------------------------"
 	log " - - 0.新建配置文件(使用模板文件 template)"
    local i=0
    local ids=()
    local v=""
	for v in `ls ./*.conf`
	do
	    i=`expr $i + 1`
        ids[${i}]="${v:11:${#v}-11-5}"
 	    log " - - ${i}.${ids[${i}]}"
	done
	log "------------------------------------------------"
  	read -p "请输入选择菜单编号:" arg
	local file=""
	case $arg in
		0)
        read -p "请输入新配置文件名称:" arg
        if [ "$arg" = "" ]; then
            warn "取消执行，退出"
            return
        fi
        file="./keystore.${arg}.conf"
        cp "./keystore.template.conf" ${file}
		;;
		*)
		local n=`expr $arg + 0`
        if [ "$arg" != "" ] && [ $n -ge 1 ] && [ $n -le ${#ids[*]} ]; then
    	    file="./keystore.${ids[${arg}]}.conf"
        else
            warn "取消执行，退出"
            return
        fi
	    ;;
	esac

    vi ${file}
    edit_config
}


check_keystore(){
	local keystore="${1}"
	local password="${2}"
	local arg=""
	if [ "$keystore" = "" ]; then
		read -p "请输入要检查的 keystore 文件路径(必填):" arg
        if [ "$arg" = "" ]; then
            warn "取消执行，退出"
            return
        fi
        keystore="$arg"
	fi
    if [ ! -f "$keystore" ]; then
        warn "文件不存在，退出"
        return
    fi
	if [ ${#password} -lt 6 ]; then
		read -p "请输入 keystore 文件密码(至少6个字符):" arg
        if [ "$arg" -lt 6 ]; then
            warn "取消执行，退出"
            return
        fi
        password="$arg"
	fi
	echo "${password}
    " | keytool -list -v -keystore "${keystore}"
}


create_keystroe(){
	local arg="0"
	log "$(pwd)"
	log "------------------------------------------------"
    local i=0
    local ids=()
    local v=""
	for v in `ls ./*.conf`
	do
	    i=`expr $i + 1`
        ids[${i}]="${v:11:${#v}-11-5}"
 	    log " - - ${i}.${ids[${i}]}"
	done
	log "------------------------------------------------"
  	read -p "请输入使用的配置文件编号:" arg
	local file="./keystore.${ids[${arg}]}.conf"
    if [ ! -f "$file" ]; then
        warn "配置文件不存在，退出"
        return
    fi
	#加载配置参数
    . "${file}"

    local execstr="keytool -genkey -v -keystore ${keystore} -alias ${alias} -keyalg ${keyalg} -validity ${validity} -keystore ${path}${keystore}"
    echo "${password}
${password}
${CN}
${OU}
${O}
${L}
${ST}
${C}
y
" | $execstr

    check_keystore ${path}${keystore} ${password}
}

main()
{
	local arg=""
	log "------------------------------------------------"
	log " - - 0.编辑配置文件"
	log " - - 1.检查 keystore"
	log " - - 2.生成 keystore"
	log " - - 输入其它退出"
	log "------------------------------------------------"
	read -p "请输入选择菜单编号:" arg
	case $arg in
		0)
		edit_config
		;;
		1)
		check_keystore
		;;
		2)
		create_keystroe
		;;
		*)
		warn "未选择，退出"
		exit 2
		;;
	esac
	main
}

main
