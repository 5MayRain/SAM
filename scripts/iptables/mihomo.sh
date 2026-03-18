# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# TUN 流量转发
tun_iptables(){
    iptables ${1} FORWARD -o ${TUN_DEVICE} -j ACCEPT
    iptables ${1} FORWARD -i ${TUN_DEVICE} -j ACCEPT
    ip6tables $1 FORWARD -o ${TUN_DEVICE} -j ACCEPT
    ip6tables ${1} FORWARD -i ${TUN_DEVICE} -j ACCEPT
}

# DNS 端口转发
dns_iptables(){
    # AdGuardHome 未启用，则转发
    if [ "$AGH_ENABLE" = false ]; then        
        [ "${1}" = "-A" ] && log "i" "添加 ${MIHOMO_BIN} DNS 转发" || log "i" "删除 ${MIHOMO_BIN} DNS 转发"
        iptables -t nat ${1} OUTPUT -p udp --dport 53 -j REDIRECT --to-ports $MIHOMO_DNS_PORT
        iptables -t nat ${1} OUTPUT -p tcp --dport 53 -j REDIRECT --to-ports $MIHOMO_DNS_PORT
    fi
}

# 添加指令
case "$1" in
    # 添加
    add)
        # IP 转发
        if [ $(cat "/proc/sys/net/ipv4/ip_forward") = 0 ]; then
            log "i" "启用 IP 转发"
            echo 1 > /proc/sys/net/ipv4/ip_forward || log "e" "开启失败"
        fi
        log "i" "添加 TUN 流量转发"
        tun_iptables "-I" || log "e" "添加失败"
        dns_iptables "-A" || log "e" "添加失败"
        ;;
    # 删除
    delete)
        log "i" "删除 TUN 流量转发"
        tun_iptables "-D" || log "e" "删除失败"
        dns_iptables "-D" || log "e" "删除失败"
        ;;
esac