# 加载设置
. /data/adb/modules/SAM/setting.conf
# 加载配置
. /data/adb/modules/SAM/scripts/config.sh

# 添加环境
[ -d "/data/adb/magisk" ] && export PATH="/data/adb/magisk:$PATH"
[ -d "/data/adb/ksu/bin" ] && export PATH="/data/adb/ksu/bin:$PATH"
[ -d "/data/adb/ap/bin" ] && export PATH="/data/adb/ap/bin:$PATH"
export PATH="/data/adb/modules/SAM/bin:$PATH"
export SSL_CERT_DIR="/system/etc/security/cacerts/"
export TZ="Asia/Shanghai"

# 缓存路径
[ ! -e "${TMP_PATH}" ] && mkdir "${TMP_PATH}"

# 删除日志和缓存
clear_tmp(){
    rm -rf $MODULE_PATH/tmp/*
}

# 占位符
placeholder(){
    i=0
    out=""
    while(( i<${1} ))
    do
        out+="▇"
        let "i++"
    done
    echo ${out}
}

# 日志
log(){
    # 时间
    time=$(date "+%Y-%m-%d %H:%M:%S")
    # 输出内容
    out="[${time}]"
    # 判断日志格式
    if [ "${1}" = "i" ]; then
        out+="[INFO]"
    elif [ "${1}" = "e" ]; then
        out+="[ERRO]"
    fi
    out+=": ${2}"
    echo ${2}
    echo ${out} >> "${LOG_FILE}"
}

# 程序是否运行
isRun(){
    state_number=$(pgrep -l -f ${1} | grep -v "sh")
    [ "${state_number}" ] && return 0 || return 1
}

# 停止程序
stop(){
    if [ -f "${1}" ] || [ "$(pidof ${2})" ]; then
        pid=$(cat "${1}")
        if [ "${pid}" ]; then
            kill -9 ${pid}
            rm "${1}"
        fi
        kill -9 $(pidof ${2})
        return 0
    fi
    return 1
}