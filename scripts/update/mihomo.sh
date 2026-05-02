# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 读取配置内容
content=$(cat "${MIHOMO_PATH}/base.yaml")

# DNS 端口
if [ ${MODULE_DNS_MODE} = 1 ] && [ ${SMARTDNS_ENABLE} = true ] && [ $(isRun ${SMARTDNS_BIN} "pid") ]; then
    DNS_PORT=3721
elif [ ${MODULE_DNS_MODE} = 2 ] && [ ${AGH_ENABLE} = true ] && [ $(isRun ${AGH_BIN} "pid") ]; then
    DNS_PORT=${AGH_DNS_PORT}
elif [ ${SMARTDNS_ENABLE} = true ] && [ ${AGH_ENABLE} = false ] && [ $(isRun ${SMARTDNS_BIN} "pid") ]; then
    DNS_PORT=3721
elif [ ${SMARTDNS_ENABLE} = false ] && [ ${AGH_ENABLE} = true ] && [ $(isRun ${AGH_BIN} "pid") ]; then
    DNS_PORT=${AGH_DNS_PORT}
fi

# 修改订阅配置
modify_sub(){
    # 订阅名称
    sub_name=""
    # 订阅内容
    sub_content=""
    # 配置内容字数
    sub_size=${#content}
    
    log "i" "获取订阅地址:"
    
    # 索引
    index=0
    # 遍历订阅地址
    while(( index < ${#SUB_URL[@]} ))
    do
        number=`expr ${index} + 1`
        log "i" "${SUB_URL[${index}]}"
        # 订阅名称
        sub_name+="    - provider${number}"
        [ ${index} -lt ${#SUB_URL[@]} ] && sub_name+="\n"
        # 订阅内容
        sub_content+="  provider${number}:\n"
        sub_content+="    <<: *p\n"
        sub_content+="    url: \"${SUB_URL[${index}]}\"\n"
        sub_content+="    path: ./proxy_provider/provider${number}.yaml\n"
        sub_content+="    override:\n"
        sub_content+="      additional-prefix: \"[订阅${number}]\"\n"        
        let "index++"
    done
    
    log "i" "添加订阅"
    
    # 获取插入行
    line=$(echo "${content}" | sed -n "/hosts:/=")
    let "line--"
    # 输出配置
    content=$(echo "${content}" | sed "${line}i # 订阅\nA: &A\n  use:\n${sub_name}\nAll: &All\n  type: url-test\n  use:\n${sub_name}\nproxy-providers:\n${sub_content}")
    echo "${content}" > ${MIHOMO_CONF}
    [ ${sub_size} -lt ${#content} ] && log "i" "订阅配置修改成功" || log "e" "订阅配置修改失败"
}

# 修改 dns
modify_dns(){
    # 需要修改的数量
    number=$(cat ${MIHOMO_CONF} | sed -n "/- system/=" | wc -l)
    # 遍历
    index=0
    while(( ${index} < ${number} ))
    do
        # 读取配置内容
        content=$(cat ${MIHOMO_CONF})
        # 读取所需修改行
        line=$(echo "${content}" | sed -n "/- system/=" | sed -n "1p")
        # 获取前缀
        prefix=$(echo "${content}" | sed -n "${line}p" | sed -e "s/-.*/- /g" -e "s/ /$(placeholder 1)/g")
        # 判断 AdGuardHome 启用，则使用 AdGuardHome dns，未启用则使用默认 dns
        if [ ${AGH_ENABLE} = true -o ${SMARTDNS_ENABLE} = true ] && [ "${DNS_PORT}" ]; then
            content=$(echo "${content}" | sed "${line}c ${prefix}127.0.0.1:${DNS_PORT}" | sed "s/$(placeholder 1)/ /g")
        else
            content=$(echo "${content}" | sed "${line}c ${prefix}https://doh.pub/dns-query#🇨🇳 国内\n${prefix}https://dns.alidns.com/dns-query#🇨🇳 国内" | sed "s/$(placeholder 1)/ /g")
        fi
        # 输出
        echo "${content}" > ${MIHOMO_CONF}
        let "index++"        
    done
    if [ ${AGH_ENABLE} = true -o ${SMARTDNS_ENABLE} = true ] && [ "${DNS_PORT}" ]; then
        [ ${DNS_PORT} = ${AGH_DNS_PORT} ] && log "i" "${MIHOMO_BIN} 使用 ${AGH_BIN} DNS" || log "i" "${MIHOMO_BIN} 使用 ${SMARTDNS_BIN} DNS"
    else
        log "i" "${MIHOMO_BIN} 使用默认 DNS"
    fi
}

# 修改 Mihomo DNS 端口
modify_dns_port(){
    # 获取 Mihomo DNS 端口
    port_value=$(cat ${MIHOMO_CONF} | grep "listen" | awk '{print $2}' | tr -d "[:space:]" | sed "s/0.0.0.0://g")
    # 判断 Mihomo DNS 端口 与设置的端口不一致则修改
    if [ ${MIHOMO_DNS_PORT} != ${port_value} ]; then        
        log "i" "修改 Mihomo DNS 端口 ${port_value} 为 ${MIHOMO_DNS_PORT}"
        cat ${MIHOMO_CONF} | sed -i "s/listen: 0.0.0.0:${port_value}/listen: 0.0.0.0:${MIHOMO_DNS_PORT}/g" ${MIHOMO_CONF}
    fi
}

# 修改 Mihomo TUN 网卡
modify_tun_device(){
    # 获取 Mihomo TUN 网卡
    device_value=$(cat ${MIHOMO_CONF} | grep "device" | awk '{print $2}' | tr -d "[:space:]")
    # 判断 Mihomo TUN 网卡 与设置的网卡不一致则修改
    if [ ${TUN_DEVICE} != ${device_value} ]; then        
        log "i" "修改 Mihomo TUN 网卡 ${device_value} 为 ${TUN_DEVICE}"
        cat ${MIHOMO_CONF} | sed -i "s/device: ${device_value}/device: ${TUN_DEVICE}/g" ${MIHOMO_CONF} 
    fi
}

# 修改 Mihomo 的 ipv6
modify_ipv6_proxy(){
    log "i" "修改 Mihomo ipv6 设置"
    # 输出内容
    out_content=$(cat ${MIHOMO_CONF})
    # 获取索引
    indexs=$(echo "${out_content}" | grep -n "ipv6:" | cut -d: -f1)
    # 循环打印
    for i in ${indexs}
    do
        # 获取值
        ipv6_value=$(echo "${out_content}" | sed -n "${i}p" | awk '{print $2}' | tr -d "[:space:]")
        # 判断 Mihomo ipv6 与设置的 ipv6 不一致则修改
        if [ ${MIHOMO_IPV6} != ${ipv6_value} ]; then
            out_content="$(echo "${out_content}" | sed "${i}s/${ipv6_value}/${MIHOMO_IPV6}/g")"
        fi
    done
    echo "${out_content}" > ${MIHOMO_CONF}
}

# 排除 ZeroTier 网卡接口
exclude_zerotier(){
    # ZeroTier 未运行则退出
    isRun "zerotier-one" || {
        return 0
    }
    log "i" "排除 ZeroTier 网卡接口"
    # 获取网卡接口
    zt_device=$(ip link show | grep "zt" | sed -n 's/^[0-9][0-9]: \(.*\):.*$/\1/p')    
    # 获取行号
    line_number=$(cat ${MIHOMO_CONF} | sed -n -e "/disable-icmp-forwarding:/=")
    let "line_number++"
    # 输出配置
    out_content=$(cat ${MIHOMO_CONF} | sed ${line_number}"i $(placeholder 2)# 排除网络接口\n$(placeholder 2)exclude-interface:\n$(placeholder 4)- ${zt_device}" | sed "s/$(placeholder 1)/ /g")
    echo "${out_content}" > ${MIHOMO_CONF}
}

modify_sub
modify_dns
modify_dns_port
modify_tun_device
modify_ipv6_proxy
exclude_zerotier