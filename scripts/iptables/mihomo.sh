# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# TUN 流量转发
tun_iptables(){
    ${iptables_w} ${1} FORWARD -o ${TUN_DEVICE} -j ACCEPT
    ${iptables_w} ${1} FORWARD -i ${TUN_DEVICE} -j ACCEPT
    ${ip6tables_w} ${1} FORWARD -o ${TUN_DEVICE} -j ACCEPT
    ${ip6tables_w} ${1} FORWARD -i ${TUN_DEVICE} -j ACCEPT
}

# 删除路由规则
del_ip_rule(){
    ip rule show | grep -E "^${1}:.*" | while IFS= read i
    do
        ip rule del pref ${1}
    done
}

rec_ip_rule(){
    del_ip_rule "9000"
    del_ip_rule "9001"
    del_ip_rule "9002"
    del_ip_rule "9003"
    del_ip_rule "9010"
    ip rule add pref 9000 from all lookup main
    ip route flush table 2022
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
        #rec_ip_rule && log "i" "恢复默认路由" || log "e" "恢复默认路由失败"
        ;;
esac