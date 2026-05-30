# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# DNS 链
DNS_CHAIN="REDIRECT_DNS"
IPV6_DNS_CHAIN="REDIRECT_IPV6_DNS"
# 阻断 ipv6 链
BLOCK_IPV6_CHAIN="BLOCK_IPV6_DNS"

# 获取 SmartDNS 端口
SMARTDNS_PORT=$(cat ${SMARTDNS_CONF} | grep "bind" | sed -n "s/bind.*:\(.*\)/\1/p")

# DNS 端口
if [ ${MODULE_DNS_MODE} = 1 ] && [ ${AGH_ENABLE} = true ] && [ $(isRun ${AGH_BIN} "pid") ]; then
    log "i" "使用 ${AGH_BIN} DNS"
    DNS_PORT=${AGH_DNS_PORT}
elif [ ${MIHOMO_ENABLE} = false ] && [ ${AGH_ENABLE} = true ] && [ $(isRun ${AGH_BIN} "pid") ]; then
    log "i" "使用 ${AGH_BIN} DNS"
    DNS_PORT=${AGH_DNS_PORT}
elif [ ${MODULE_DNS_MODE} = 2 ] && [ ${MIHOMO_ENABLE} = true ] && [ $(isRun ${MIHOMO_BIN} "pid") ]; then
    log "i" "使用 ${MIHOMO_BIN} DNS"
    DNS_PORT=${MIHOMO_DNS_PORT}
elif [ ${MODULE_DNS_MODE} = false ] && [ ${AGH_ENABLE} = false ] && [ $(isRun ${SMARTDNS_BIN} "pid") ]; then
    log "i" "使用 ${SMARTDNS_BIN} DNS"
    DNS_PORT=${SMARTDNS_PORT}
fi

itw=${iptables_w}

# 启用 dns
enable_dns(){
    [ ${1} = "ipv4" ] && itw=${iptables_w} || itw=${ip6tables_w}
    if ${itw} -t nat -L ${2} > /dev/null 2>&1; then
        log "e" "${2} 链已存在"
        return 1
    fi
    log "i" "创建 ${2} 链并添加规则"
    ${itw} -t nat -N ${2} || return 1
    ${itw} -t nat -A ${2} -m owner --uid-owner ${SAM_USER} --gid-owner ${SAM_GROUP} -j RETURN || return 1      
    ${itw} -t nat -A ${2} -p tcp --dport 53 -j REDIRECT --to-ports ${DNS_PORT} || return 1
    ${itw} -t nat -A ${2} -p udp --dport 53 -j REDIRECT --to-ports ${DNS_PORT} || return 1
    ${itw} -t nat -I OUTPUT -j ${2} || return 1
}

# 禁用 dns
disable_dns(){
    [ ${1} = "ipv4" ] && itw=${iptables_w} || itw=${ip6tables_w}
    if ! ${itw} -t nat -L ${2} > /dev/null 2>&1; then
        log "e" "${2} 链不存在"
        return 1
    fi
    log "i" "删除 ${2} 链及规则"
    ${itw} -t nat -D OUTPUT -j ${2} || return 1
    ${itw} -t nat -F ${2} || return 1
    ${itw} -t nat -X ${2} || return 1
}

# 启用 ipv6 阻断
enabel_block_ipv6(){
    if ${ip6tables_w} -t filter -L ${BLOCK_IPV6_CHAIN} >/dev/null 2>&1; then
        log "e" "${BLOCK_IPV6_CHAIN} 链已存在"
        return 1
    fi
    log "i" "创建 ${BLOCK_IPV6_CHAIN} 链并添加规则"
    ${ip6tables_w} -t filter -N ${BLOCK_IPV6_CHAIN} || return 1
    ${ip6tables_w} -t filter -A ${BLOCK_IPV6_CHAIN} -p tcp --dport 53 -j DROP || return 1
    ${ip6tables_w} -t filter -A ${BLOCK_IPV6_CHAIN} -p udp --dport 53 -j DROP || return 1
    ${ip6tables_w} -t filter -I OUTPUT -j ${BLOCK_IPV6_CHAIN} || return 1
}

# 禁用 ipv6 阻断
disable_block_ipv6(){
    if ! ${ip6tables_w} -t filter -L ${BLOCK_IPV6_CHAIN} >/dev/null 2>&1; then
        log "e" "${BLOCK_IPV6_CHAIN} 链不存在"
        return 1
    fi
    log "i" "删除 ${BLOCK_IPV6_CHAIN} 链及规则"
    ${ip6tables_w} -t filter -F ${BLOCK_IPV6_CHAIN} || return 1
    ${ip6tables_w} -t filter -D OUTPUT -j ${BLOCK_IPV6_CHAIN} || return 1
    ${ip6tables_w} -t filter -X ${BLOCK_IPV6_CHAIN} || return 1
}

# 是否支持 ipv6 nat
is_ipv6_nat(){
    if ${ip6tables_w} -t nat -L >/dev/null 2>&1; then
        return 0
    else
        log "e" "不支持 ipv6 nat"
        return 1
    fi
}

# 判断端口是否等于 53
is_dns_port(){
    if [ ${DNS_PORT} = 53 ]; then
        log "i" "端口等于 53，跳过添加规则"
        return 0
    else
        return 1
    fi
}

# 添加指令
case "$1" in
    # 启用
    enable)
        [ "${DNS_PORT}" ] && {
            is_dns_port || enable_dns "ipv4" ${DNS_CHAIN}
        }
        if [ "${BLOCK_IPV6_DNS}" = true ]; then
            enabel_block_ipv6
        else
            is_ipv6_nat && enable_dns "ipv6" ${IPV6_DNS_CHAIN}
        fi
        ;;
    # 禁用
    disable)
        disable_dns "ipv4" ${DNS_CHAIN}
        is_ipv6_nat && disable_dns "ipv6" ${IPV6_DNS_CHAIN}
        disable_block_ipv6
        ;;
esac