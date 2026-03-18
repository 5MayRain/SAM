# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 服务脚本
SMARTDNS_SERVICE="${SCRIPTS_PATH}/service/${SMARTDNS_BIN}.sh"
AGH_SERVICE="${SCRIPTS_PATH}/service/${AGH_BIN}.sh"
MIHOMO_SERVICE="${SCRIPTS_PATH}/service/${MIHOMO_BIN}.sh"
CRONTABS_SERVICE="${SCRIPTS_PATH}/service/crontabs.sh"

# 启动服务
start(){
    # 判断没有订阅地址则退出
    if [ ${#SUB_URL[@]} = 0 ]; then
        log "e" "没有填写订阅地址 !!!"
        log "e" "请打开 $MODULE_PATH/setting.conf 设置文件，填写订阅地址"
        cat $MODULE_PATH/module.prop | sed -i "6c description=没有填写订阅地址 !!! 请打开 $MODULE_PATH/setting.conf 设置文件，填写订阅地址" "$MODULE_PATH/module.prop"
        exit 0
    fi        
    
    log "i" "关闭私人DNS"
    {
        settings get global private_dns_mode | grep off || settings put global private_dns_mode off
    } > /dev/null
    
    # 更新订阅
    ${SCRIPTS_PATH}/update.sh sub
    # 更新配置
    ${SCRIPTS_PATH}/update.sh config
    # 启动 SmartDNS
    ${SMARTDNS_SERVICE} start
    # 启动 Mihomo
    ${MIHOMO_SERVICE} start
    # 启动 AdGuardHome
    ${AGH_SERVICE} start
    # 添加 iptables 规则    
    [ ${IP_IPTABLES} = true ] && ${SCRIPTS_PATH}/iptables.sh -e ip
    # 启动 crontabs
    ${CRONTABS_SERVICE} start
    # 屏蔽 app 广告文件
    ${SCRIPTS_PATH}/ad.sh block
        
    # 判断 host 启用，则更新 host，并重新挂载
    if [ "${HOST_ENABLE}" = true ]; then
        log "i" "更新 host 规则"
        SYSTEM_HOSTS="/system/etc/hosts"
        [ ! "$(mount | grep ${SYSTEM_HOSTS})" ] && mount -o bind "${HOSTS_PATH}" "${SYSTEM_HOSTS}" 
        ${SCRIPTS_PATH}/update/host.sh update
    fi
    
    # 更新描述
    ${SCRIPTS_PATH}/update.sh desc
}

# 停止
stop(){
    # 停止 AdGuardHome
    ${AGH_SERVICE} stop
    # 停止 Mihomo
    ${MIHOMO_SERVICE} stop
    # 停止 SmartDNS
    ${SMARTDNS_SERVICE} stop
    # 删除 iptables 规则    
    [ ${IP_IPTABLES} = true ] && ${SCRIPTS_PATH}/iptables.sh -d ip
    # 关闭 crontabs
    ${CRONTABS_SERVICE} stop
    # 更新描述
    ${SCRIPTS_PATH}/update.sh desc
}

# 清除日志
clear_tmp

# 添加指令
case "$1" in
    # 启动
    start)
        log "i" "START >>>"
        start
        log "i" "<<< START"
        ;;
    # 停止
    stop)
        log "i" "STOP >>>"
        stop
        log "i" "<<< STOP"
        ;;
    # 重启
    restart)
        log "i" "RESTART >>>"
        stop
        start
        log "i" "<<< RESTART"
        ;;
    *)
        start
        echo "使用: start(启动) | stop(停止) | restart(重启)"
        exit 1
        ;;
esac