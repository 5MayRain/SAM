# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 获取已启用服务的数量
get_service_number(){
    number=3
    if [ ${SMARTDNS_ENABLE} = false ]; then
        number=$((number - 1))
    fi
    if [ ${AGH_ENABLE} = false ]; then
        number=$((number - 1))
    fi
    if [ ${MIHOMO_ENABLE} = false ]; then
        number=$((number - 1))
    fi
    echo ${number}
}

# 获取进程数量
get_process_number(){
    pids=($(pgrep -f "${SMARTDNS_BIN}" -f "${AGH_BIN}" -f "${MIHOMO_BIN}"))
    echo ${#pids[@]}
}

# 获取挂载状态
get_mount_status(){
    status=$(mount | grep "/system/etc/hosts")
    [ "${status}" ] && echo "已挂载" || echo "未挂载"
}

# 获取监控
get_monitor_status(){
    status=$(get_monitor_pid $1)
    [ "${status}" ] && echo "已运行" || echo "未运行"
}

# 获取监控 pid
get_monitor_pid(){
    pid=$(pgrep -f "${SCRIPTS_PATH}/wifi.monitor.sh")
    if [ ${1} = "wifi" ]; then
        echo ${pid}
        return
    fi
    pid=$(pgrep -f "${INOTIFY_PATH}/host.sh")
    if [ ${1} = "host" ]; then
        echo ${pid}
        return
    fi
    pid=$(pgrep -l -f "${INOTIFY_PATH}/module.sh" | grep -E "inotifyd|busybox" | sed "s/ .*$//g")
    if [ ${1} = "module" ]; then
        echo ${pid}
        return
    fi
}

# 杀死监控
kill_monitor(){
    pid=$(get_monitor_pid ${1})
    kill ${pid} || kill -9 ${pid} > /dev/null 2>&1
}

# 启动监控
start_monitor(){
    pid=$(get_monitor_pid ${1})
    if [ $1 = "wifi" ] && [ -z "${pid}" ]; then
        ${SCRIPTS_PATH}/wifi.monitor.sh > /dev/null 2>&1 &
    elif [ ${1} = "host" ] && [ -z "${pid}" ]; then
        inotifyd "${INOTIFY_PATH}/host.sh" "${HOSTS_FILE}" &
    elif [ -z "$pid" ]; then
        inotifyd "${INOTIFY_PATH}/module.sh" "${MODULE_PATH}" &
    fi
}

# 添加指令
case "$1" in
    status)
        isRun ${2} && echo "已运行" || echo "未运行"
        ;;
    service)
        get_service_number
        ;;
    process)
        get_process_number
        ;;
    mount)
        get_mount_status
        ;;
    monitor)
        get_monitor_status ${2}
        ;;
    pid)
        get_monitor_pid ${2}
        ;;
    start)
        start_monitor ${2}
        ;;
    kill)
        kill_monitor ${2}
        ;;
    *)
        echo "使用: status(服务状态) | service(服务数量) | process(进程数量) | mount(挂载状态) | monitor(监控状态) | pid(监控pid) | start(启动监控) | kill(杀死监控)"
        exit 1
        ;;
esac