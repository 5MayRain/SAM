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
            echo 1 > /proc/sys/net/ipv4/ip_forward && log "i" "开启 IP 转发" || log "e" "开启 IP 转发失败"
        fi
        tun_iptables "-I" && log "i" "添加 TUN 流量转发" || log "e" "添加 TUN 流量转发失败"
        ;;
    # 删除
    del)
        tun_iptables "-D" && log "i" "删除 TUN 流量转发" || log "e" "删除 TUN 流量转发失败"
        ;;
esac