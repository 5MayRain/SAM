# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 启动
start(){ 
    # 判断 Mihomo 未启用，则退出
    if [ ${MIHOMO_ENABLE} = false ]; then
        log "e" "${MIHOMO_BIN} 未启用"
        return 1
    fi
    
    if [ ${#SUB_URL[@]} = 0 ]; then
        log "e" "未填写订阅地址，无法启动 ${MIHOMO_BIN}"
        return 1
    fi        
       
    # 判断 Mihomo 已运行，则退出
    isRun ${MIHOMO_BIN} && {
        log "e" "${MIHOMO_BIN} 已运行"
        return 1
    }
    
    # 更新 Mihomo 配置
    ${UPDATE_PATH}/mihomo.sh
    # 更新代理名单
    ${UPDATE_PATH}/proxy.sh
    
    # 启动
    busybox setuidgid "${SAM_USER}:${TUN_GROUP}" ${MIHOMO_BIN} -d ${MIHOMO_PATH} > "${TMP_PATH}/${MIHOMO_BIN}.log" 2>&1 &
    #su -g $(id -g ${TUN_GROUP}) -G $(id -g ${DNS_GROUP}) -- nohup ${MIHOMO_BIN} -d ${MIHOMO_PATH} > "${TMP_PATH}/mihomo.log" 2>&1 &
    
    # 延时，并判断 Mihomo 是否启动成功
    sleep 1
    isRun ${MIHOMO_BIN} && {
        log "i" "${MIHOMO_BIN} 启动成功"
        # 添加 TUN 规则
        ${IPTABLES_PATH}/mihomo.sh add
    } || log "e" "${MIHOMO_BIN} 启动失败"
}

# 停止
stop(){
    # 判断 Mihomo 未运行，则退出
    isRun ${MIHOMO_BIN} || {
        log "e" "${MIHOMO_BIN} 已停止"
        return 1
    }
    # 杀死 Mihomo 进程
    kill_process ${MIHOMO_BIN} && log "i" "${MIHOMO_BIN} 停止成功" || log "e" "${MIHOMO_BIN} 停止失败"
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