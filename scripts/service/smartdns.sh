# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 启动 SmartDNS
smartdns_start(){
    # 判断禁用则退出
    if [ ${SMARTDNS_ENABLE} = false ]; then
        log "i" "${SMARTDNS_BIN} 已禁用"
        log "i" "如需启用，请修改 setting.conf 文件"
        return 1
    fi
    # SmartDNS 正在运行则退出
    isRun ${SMARTDNS_BIN} && {
        log "e" "${SMARTDNS_BIN} 正在运行"
        return 1
    }
    log "i" "启动 SmartDNS"
    # 后台启动并输出日志
    busybox setuidgid ${MIHOMO_USER_GROUP} ${SMARTDNS_BIN} -c ${SMARTDNS_CONF} -p - > "${TMP_PATH}/${SMARTDNS_BIN}.log" 2>&1 & echo -n $! > "${SMARTDNS_PID}"
    # 延时 1秒
    sleep 1
    # 输出 SmartDNS 状态
    isRun ${SMARTDNS_BIN} && log "i" "${SMARTDNS_BIN} 启动成功" || log "e" "${SMARTDNS_BIN} 启动失败"
}

# 停止 SmartDNS
smartdns_stop(){
    # SmartDNS 没有运行则退出
    isRun ${SMARTDNS_BIN} || {
        log "e" "${SMARTDNS_BIN} 已停止"
        return 1
    }
    log "i" "关闭 SmartDNS"
    # 杀死 SmartDNS 进程
    stop "${SMARTDNS_PID}" "${SMARTDNS_BIN}" && log "e" "${SMARTDNS_BIN} 关闭成功" || log "i" "${SMARTDNS_BIN} 关闭失败"
}

# 添加指令
case "$1" in
    # 启动
    start)
        smartdns_start
        ;;
    # 停止
    stop)
        smartdns_stop
        ;;
esac