# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 读取配置内容
content=$(cat ${AGH_CONF})

# 修改配置
modify_conf(){
    # 获取开始行
    start_line=$(echo "${content}" | sed -n "/upstream_dns:/=")
    let "start_line++"
    # 获取项的前缀
    prefix=$(echo "${content}" | sed -n "${start_line}p" | sed "s/-.*/- /g")
    # 默认DNS (腾讯，阿里)
    default_dns="${prefix}https://doh.pub/dns-query\n${prefix}https://dns.alidns.com/dns-query"
    # 判断 SmartDNS 启用，则使用 SmartDNS，未启用则使用默认DNS
    if [ ${SMARTDNS_ENABLE} = true ] && [ ${MODULE_DNS_MODE} = 2 ] && [ $(isRun ${SMARTDNS_BIN} "pid") ]; then
        log "i" "${AGH_BIN} 上游DNS使用 ${SMARTDNS_BIN}"
        modify_dns "${prefix}127.0.0.1:3721"
    elif [ ${MIHOMO_ENABLE} = true ] && [ ${MODULE_DNS_MODE} = 1 ] && [ $(isRun ${MIHOMO_BIN} "pid") ]; then
        log "i" "${AGH_BIN} 上游DNS使用 ${MIHOMO_BIN}"
        modify_dns "${prefix}127.0.0.1:${MIHOMO_DNS_PORT}"
    elif [ ${MIHOMO_ENABLE} = false ] && [ ${SMARTDNS_ENABLE} = true ] && [ $(isRun ${SMARTDNS_BIN} "pid") ]; then
        log "i" "${AGH_BIN} 上游DNS使用 ${SMARTDNS_BIN}"
        modify_dns "${prefix}127.0.0.1:3721"
    else
        log "i" "${AGH_BIN} 上游DNS使用默认DNS"
        modify_dns "${default_dns}"
    fi
}

# 修改DNS
modify_dns(){
        echo "${content}" | sed "/upstream_dns:/,/upstream_dns_file:/c\  upstream_dns:\n${1}\n  upstream_dns_file: \"\"" > ${AGH_CONF}
}

# 修改 DNS 端口
modify_dns_port(){
    # 获取 AdGuardHome DNS 端口
    port_value=$(cat ${AGH_CONF} | sed -n '/port:/p' | grep "port" | awk 'NR==2{print $2}' | tr -d "[:space:]")
    # 判断 AdGuardHome DNS 端口与设置的端口不一致则修改
    if ! [ ${AGH_DNS_PORT} -eq ${port_value} ]; then
        log "i" "修改 AdGuardHome DNS 端口 ${port_value} 为 ${AGH_DNS_PORT}"
        cat ${AGH_CONF} | sed -i "s/port: ${port_value}/port: ${AGH_DNS_PORT}/g" ${AGH_CONF}
    fi
}

# 获取结束行数
get_end_line(){
    line=${1}
    # 获取当前行数的内容
    item=$(echo "${content}" | sed -n "${line}p" | grep "-")
    # 判断当前内容是否还在项内
    if [ "${item}" ]; then
        # 自增，并重新调用当前函数
        let "line++"
        get_end_line ${line}
    else
        # 自减，并返回行数
        let "line--"
        echo ${line}
        return 0
    fi
}

modify_conf
modify_dns_port