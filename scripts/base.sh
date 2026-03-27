# 加载设置
source "/data/adb/modules/SAM/setting.conf"
# 加载配置
source "/data/adb/modules/SAM/scripts/config.sh"

# 添加环境
[ -d "/data/adb/magisk" ] && export PATH="/data/adb/magisk:${PATH}"
[ -d "/data/adb/ksu/bin" ] && export PATH="/data/adb/ksu/bin:${PATH}"
[ -d "/data/adb/ap/bin" ] && export PATH="/data/adb/ap/bin:${PATH}"
export PATH="${BIN_PATH}:${PATH}"
export SSL_CERT_DIR="/system/etc/security/cacerts/"
export TZ="Asia/Shanghai"

# 防火墙指令
iptables_w="iptables -w 100"
ip6tables_w="ip6tables -w 100"

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
    echo "${1}" | grep -q "/" && pid=$(pgrep -f ${1}) || pid=$(pidof ${1})
    if [ "${pid}" ]; then
        [ "${2}" = "pid" ] && echo ${pid}
        return 0
    fi
    return 1
}

# 杀死进程
kill_process(){
    pid=$(isRun ${1} "pid") && {
        sleep 1
        kill -9 ${pid} && return 0 || return 1
    } || return 1
}