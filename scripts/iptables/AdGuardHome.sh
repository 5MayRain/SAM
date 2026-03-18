# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 链
agh_chain="ADGUARD_REDIRECT_DNS"
agh_block_chain="ADGUARD_BLOCK_DNS"

# 启用 iptables
enable_iptables(){
    # 判断存在则退出
    if ${iptables_w} -t nat -L ${agh_chain} >/dev/null 2>&1; then
        log "i" "${agh_chain} 链已经存在"
        return 1
    fi
    log "i" "创建 ${agh_chain} 链并添加规则"    
    ${iptables_w} -t nat -N ${agh_chain}    
    ${iptables_w} -t nat -A ${agh_chain} -m owner --uid-owner $AGH_USER --gid-owner $AGH_GROUP -j RETURN
    ${iptables_w} -t nat -A ${agh_chain} -p udp --dport 53 -j REDIRECT --to-ports $AGH_DNS_PORT
    ${iptables_w} -t nat -A ${agh_chain} -p tcp --dport 53 -j REDIRECT --to-ports $AGH_DNS_PORT
    ${iptables_w} -t nat -I OUTPUT -j ${agh_chain}
}

# 启用阻断 ipv6 的 DNS 请求
add_block_ipv6(){
    # 判断存在则退出
    if ${ip6tables_w} -t filter -L ${agh_block_chain} >/dev/null 2>&1; then
        log "i" "${agh_block_chain} 链已经存在"
        return 1
    fi
    log "i" "创建 ${agh_block_chain} 链并添加规则"
    ${ip6tables_w} -t filter -N ${agh_block_chain}
    ${ip6tables_w} -t filter -A ${agh_block_chain} -p udp --dport 53 -j DROP
    ${ip6tables_w} -t filter -A ${agh_block_chain} -p tcp --dport 53 -j DROP
    ${ip6tables_w} -t filter -I OUTPUT -j ${agh_block_chain}
}

# 禁用 AdGuardHome iptables
disable_iptables(){
    # 判断不存在则退出
    if ! ${iptables_w} -t nat -L ${agh_chain} >/dev/null 2>&1; then
        log "i" "${agh_chain} 链不存在"
        return 1
    fi
    log "i" "删除 ${agh_chain} 链及规则"
    ${iptables_w} -t nat -D OUTPUT -j ${agh_chain}
    ${iptables_w} -t nat -F ${agh_chain}
    ${iptables_w} -t nat -X ${agh_chain}
}

# 禁用阻断 ipv6 的 DNS 请求
del_block_ipv6(){
    if ! ${ip6tables_w} -t filter -L ${agh_block_chain} >/dev/null 2>&1; then
        log "i" "${agh_block_chain} 链不存在"
        return 1
    fi
    log "i" "删除 ${agh_block_chain} 链及规则"
    ${ip6tables_w} -t filter -F ${agh_block_chain}
    ${ip6tables_w} -t filter -D OUTPUT -j ${agh_block_chain}
    ${ip6tables_w} -t filter -X ${agh_block_chain}
}

# 添加指令
case "$1" in
    # 启用
    enable)
        enable_iptables
        [ "${BLOCK_IPV6_DNS}" = true ] && add_block_ipv6
        ;;
    # 禁用
    disable)
        disable_iptables
        del_block_ipv6
        ;;
esac