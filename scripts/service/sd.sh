# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 启动
start(){
    # 判断 SmartDNS 未启用，则退出
    if [ ${SMARTDNS_ENABLE} = false ]; then
        log "e" "${SMARTDNS_BIN} 未启用"
        return 1
    fi
    
    # 判断 SmartDNS 已运行，则退出
    isRun ${SMARTDNS_BIN} && {
        log "e" "${SMARTDNS_BIN} 已运行"
        return 1
    }
    
    # 进入工作路径，并启动
    cd ${SMARTDNS_PATH}
    SMARTDNS_WORKDIR="${SMARTDNS_PATH}" exec busybox setuidgid "${SAM_USER}:${SAM_GROUP}" ${SMARTDNS_BIN} -c ${SMARTDNS_CONF} -p - > "${TMP_PATH}/${SMARTDNS_BIN}.log" 2>&1 &
    
    # 延时，并判断 SmartDNS 是否启动成功
    sleep 1
    isRun ${SMARTDNS_BIN} && log "i" "${SMARTDNS_BIN} 启动成功" || log "e" "${SMARTDNS_BIN} 启动失败"
}

# 停止
stop(){
    # 判断 SmartDNS 未运行，则退出
    isRun ${SMARTDNS_BIN} || {
        log "e" "${SMARTDNS_BIN} 已停止"
        return 1
    }
    # 杀死 SmartDNS 进程
    kill_process ${SMARTDNS_BIN} && log "i" "${SMARTDNS_BIN} 停止成功" || log "e" "${SMARTDNS_BIN} 停止失败"
}

# 添加指令
case "$1" in
    # 启动
    start)
        start
        ;;
    # 停止
    stop)
        stop
        ;;
esac