#!/usr/bin/env bash
#============================================================
# 自动清空并创建需要外部引用的模块到node_modules目录中
#============================================================

cd "$(dirname $0)"
#加载公共函数
. ../lib/common.sh

root="../../"

file_templete()
{
    local path="$1"
    local targetPath="$2"
    # 下面第一个参数是替换表达式，后面加上/g是全部替换多个，参考 http://www.tuicool.com/articles/reEfey
    sed "s/{path}/${path//\//\/}/" ./module_templete.js > ${targetPath}
}

create_js_modules()
{
    local modulesPath="${root}fixedstar-js/modules"
    local nodeModulesPath="${root}node_modules"
    local path=""
    local targetPath=""
    # 进入目录循环生成
	for id in `ls ${modulesPath}`
	do
	    path="fixedstar-js/modules/${id}"
	    targetPath="${nodeModulesPath}/${id}"
        # 目录不存在
        if [ ! -d "${targetPath}" ]; then
            # 创建目录
            mkdir "${targetPath}"
            file_templete "${path}" "${targetPath}/index.js"
            #return
        fi
	done
}

create_gulp_modules()
{
    local targetPath="${root}node_modules/fixedstar-gulp"
    # 创建目录
    mkdir "${targetPath}"
    file_templete "fixedstar-gulp" "${targetPath}/index.js"
}

clean_node_modules()
{
    local nodeModulesPath="${root}node_modules"
    # 进入目录循环生成
	for id in `ls ${nodeModulesPath}`
	do
	    rm -r "${nodeModulesPath}/${id}"
	done
}

# 清空外部引用目录
clean_node_modules

# 生成gulp到外部引用的模块
create_gulp_modules

# 生成js模块到外部引用的模块
create_js_modules