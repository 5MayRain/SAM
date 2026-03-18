# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 修改 AdGuardHome DNS 端口
agh_dns_port(){
    # 获取 AdGuardHome DNS 端口
    port_value=$(cat ${AGH_CONF} | sed -n '/port:/p' | grep "port" | awk 'NR==2{print $2}' | tr -d "[:space:]")
    # 判断 AdGuardHome DNS 端口与设置的端口不一致则修改
    if ! [ ${AGH_DNS_PORT} -eq ${port_value} ]; then
        log "i" "修改 AdGuardHome DNS 端口 ${port_value} 为 ${AGH_DNS_PORT}"
        cat ${AGH_CONF} | sed -i "s/port: ${port_value}/port: ${AGH_DNS_PORT}/g" ${AGH_CONF}
    fi
}

# 修改 Mihomo DNS 端口
mihomo_dns_port(){
    # 获取 Mihomo DNS 端口
    port_value=$(cat ${MIHOMO_CONF} | grep "listen" | awk '{print $2}' | tr -d "[:space:]" | sed "s/0.0.0.0://g")
    # 判断 Mihomo DNS 端口 与设置的端口不一致则修改
    if [ ${MIHOMO_DNS_PORT} != ${port_value} ]; then        
        log "i" "修改 Mihomo DNS 端口 ${port_value} 为 ${MIHOMO_DNS_PORT}"
        cat ${MIHOMO_CONF} | sed -i "s/listen: 0.0.0.0:${port_value}/listen: 0.0.0.0:${MIHOMO_DNS_PORT}/g" ${MIHOMO_CONF}
        
        log "i" "同步修改 AdGuardHome 配置"
        cat ${AGH_CONF} | sed -i "s/127.0.0.1:${port_value}/127.0.0.1:${MIHOMO_DNS_PORT}/g" ${AGH_CONF}
    fi
}

# 根据 SmartDNS 状态，是否使用默认 DNS
smartdns_state(){
    out="${1}"
    # SmartDNS
    line_number=$(echo "${out}" | sed -n -e "/127.0.0.1:3721/=")
    for i in `echo ${line_number}`
    do
        out=$(echo "${out}" | sed ${i}"s/${3}/${2}/")
    done
    # 阿里  
    line_number=$(echo "${out}" | sed -n -e "/dns.alidns.com/=")
    for i in `echo $line_number`
    do
        out=$(echo "${out}" | sed ${i}"s/${2}/${3}/")
    done
    # 腾讯  
    line_number=$(echo "${out}" | sed -n -e "/doh.pub/=")
    for i in `echo $line_number`
    do
        out=$(echo "${out}" | sed ${i}"s/${2}/${3}/")
    done
    echo "${out}"
}

# 修改 DNS
mihomo_dns(){    
    log "i" "修改 DNS 配置"
    # 输出内容
    out_content=$(cat ${MIHOMO_CONF})
    
    # 判断 SmartDNS 是否启用
    if [ ${SMARTDNS_ENABLE} = true ]; then
        log "i" "SmartDNS 已启用"
        log "i" "添加 SmartDNS 规则"  
        out_content=$(smartdns_state "$out_content" "-" "#-")
    else
        log "i" "SmartDNS 已禁用"   
        log "i" "使用默认 DNS 规则"    
        out_content=$(smartdns_state "$out_content" "#-" "-")
    fi
    
    # 写入配置
    echo "${out_content}" > ${MIHOMO_CONF}
    
    log "i" "DNS 配置修改成功"
}

agh_dns_port
mihomo_dns_port
mihomo_dns