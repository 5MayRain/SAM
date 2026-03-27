# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 启动
start(){
    # 启动 SmartDNS
    ${SERVICE_PATH}/sd.sh start
    # 启动 AdGuardHome
    ${SERVICE_PATH}/agh.sh start
    # 启动 Mihomo
    ${SERVICE_PATH}/mihomo.sh start
    # 添加 DNS 规则
    ${IPTABLES_PATH}/dns.sh enable
    # 添加屏蔽 IP 规则
    [ ${IP_IPTABLES} = true ] && ${IPTABLES_PATH}/ip.sh enable
    # 启动 crontabs
    ${SERVICE_PATH}/crontabs.sh start
    # 屏蔽 app 广告文件
    ${SCRIPTS_PATH}/ad.sh block        
    # 判断 host 启用，则更新 host，并重新挂载
    if [ "${HOST_ENABLE}" = true ]; then
        log "i" "更新 host 规则"
        SYSTEM_HOSTS="/system/etc/hosts"
        ${UPDATE_PATH}/host.sh update
    fi
    # 更新描述
    ${UPDATE_PATH}/desc.sh
}

# 停止
stop(){   
    # 停止 SmartDNS
    ${SERVICE_PATH}/sd.sh stop
    # 停止 AdGuardHome
    ${SERVICE_PATH}/agh.sh stop
    # 停止 Mihomo
    ${SERVICE_PATH}/mihomo.sh stop
    # 删除 DNS 规则
    ${IPTABLES_PATH}/dns.sh disable
    # 删除 TUN 规则
    ${IPTABLES_PATH}/mihomo.sh del    
    # 添加屏蔽 IP 规则
    [ ${IP_IPTABLES} = true ] && ${IPTABLES_PATH}/ip.sh disable
    # 停止 crontabs
    ${SERVICE_PATH}/crontabs.sh stop
    # 更新描述
    ${UPDATE_PATH}/desc.sh
}

# 添加指令
case "$1" in
    # 启动
    start)        
        rm -rf ${TMP_PATH}/*
        log "i" "start >>>"
        start
        log "i" "<<< start"
        ;;
    # 停止
    stop)
        > ${LOG_FILE}
        log "i" "stop >>>"
        stop        
        log "i" "<<< stop"
        ;;
    # 重启
    restart)
        log "i" "restart >>>"
        stop  
        start      
        log "i" "<<< restart"
        ;;
esac