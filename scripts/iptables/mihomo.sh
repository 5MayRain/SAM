# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# TUN 流量转发
tun_iptables(){
    ${iptables_w} ${1} FORWARD -o ${TUN_DEVICE} -j ACCEPT
    ${iptables_w} ${1} FORWARD -i ${TUN_DEVICE} -j ACCEPT
    ${ip6tables_w} $1 FORWARD -o ${TUN_DEVICE} -j ACCEPT
    ${ip6tables_w} ${1} FORWARD -i ${TUN_DEVICE} -j ACCEPT
}

# 添加指令
case "$1" in
    # 添加
    add)
        # IP 转发
        if [ $(cat "/proc/sys/net/ipv4/ip_forward") = 0 ]; then
            log "i" "开启 IP 转发"
            echo 1 > /proc/sys/net/ipv4/ip_forward || log "e" "开启失败"
        fi
        log "i" "添加 TUN 流量转发"
        tun_iptables "-I" || log "e" "添加失败"
        ;;
    # 删除
    del)
        log "i" "删除 TUN 流量转发"
        tun_iptables "-D" || log "e" "删除失败"
        ;;
esac