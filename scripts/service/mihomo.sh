# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 启动 Mihomo
mihomo_start(){
    # Mihomo 正在运行则退出    
    isRun ${MIHOMO_BIN} && {
        log "e" "${MIHOMO_BIN} 正在运行"
        return 1
    }
    log "i" "启动 ${MIHOMO_BIN}"
    # 后台启动并输出日志
    busybox setuidgid ${MIHOMO_USER_GROUP} ${MIHOMO_BIN} -d ${MIHOMO_PATH} > "${TMP_PATH}/${MIHOMO_BIN}.log" 2>&1 & echo -n $! > "${MIHOMO_PID}"
    # 延时 1秒
    sleep 1
    # 添加 iptables 规则
    "${SCRIPTS_PATH}/iptables.sh" "-e" "mihomo"
    # 输出 Mihomo 状态
    isRun ${MIHOMO_BIN} && log "i" "${MIHOMO_BIN} 启动成功" || log "e" "${MIHOMO_BIN} 启动失败"
}

# 停止 Mihomo
mihomo_stop(){
    # Mihomo 没有运行则退出
    isRun ${MIHOMO_BIN} || {
        log "e" "${MIHOMO_BIN} 已停止"
        return 1
    }
    log "i" "关闭 ${MIHOMO_BIN}"
    # 杀死 Mihomo 进程
    stop "$MIHOMO_PID" "${MIHOMO_BIN}" && log "i" "${MIHOMO_BIN} 关闭成功" || log "e" "${MIHOMO_BIN} 关闭失败"
    # 延时1秒
    sleep 1
    # 删除 iptables 规则
    "${SCRIPTS_PATH}/iptables.sh" "-d" "mihomo"
}

# 添加指令
case "$1" in
    # 启动
    start)
        mihomo_start
        ;;
    # 停止
    stop)
        mihomo_stop
        ;;
esac