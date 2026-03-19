# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 修改 Mihomo TUN 网卡
tun_device(){
    # 获取 Mihomo TUN 网卡
    device_value=$(cat ${MIHOMO_CONF} | grep "device" | awk '{print $2}' | tr -d "[:space:]")
    # 判断 Mihomo TUN 网卡 与设置的网卡不一致则修改
    if [ ${TUN_DEVICE} != ${device_value} ]; then        
        log "i" "修改 Mihomo TUN 网卡 ${device_value} 为 ${TUN_DEVICE}"
        cat ${MIHOMO_CONF} | sed -i "s/device: ${device_value}/device: ${TUN_DEVICE}/g" ${MIHOMO_CONF} 
    fi
}

# 修改 Mihomo 的 ipv6
ipv6_proxy(){
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

# 黑名单包名
blacklist_package(){
    # 读取内容
    blacklist_content=$(cat ${BLACKLIST_PATH} | grep -v '^#' | grep -v '^[[:space:]]*$')
    if [ -z "${blacklist_content}" ]; then
        log "i" "黑名单无内容，请在 ${BLACKLIST_PATH} 文件添加 APP 包名"
    fi
    
    log "i" "添加黑名单"
    
    # 输出内容
    out_content="$(placeholder 2)# 排除的 Android 应用包名\n$(placeholder 2)exclude-package:"
    rule_content=""
    rule=$(cat "${MIHOMO_PATH}/rule_provider/classical_blacklist_direct.list")
    # 获取行号
    line_number=$(cat ${MIHOMO_CONF} | sed -n -e "/disable-icmp-forwarding:/=")
    let "line_number++"
    
    log "i" "获取App包名:"
    
    # 循环获取包名
    for package in ${blacklist_content}
    do
        log "i" "$package"        
        out_content+="\n$(placeholder 4)- ${package}"
        rule=$(echo "$rule" | grep -v ${package})
        rule_content+="PROCESS-NAME,${package}\n"
    done
    log "i" "写入配置"
    
    # 输出配置
    out_content=$(cat ${MIHOMO_CONF} | sed ${line_number}"c ${out_content}" | sed "s/$(placeholder 1)/ /g")
    echo "${out_content}" > ${MIHOMO_CONF} 
    rule_content+="${rule}"
    echo -e "${rule_content}" > "${MIHOMO_PATH}/rule_provider/classical_blacklist_direct.list"
}

# 白名单
whitelist_package(){
    # 读取内容
    whitelist_content=$(cat ${WHITELIST_PATH} | grep -v '^#' | grep -v '^[[:space:]]*$')
    if [ -z "${whitelist_content}" ]; then
        log "i" "白名单无内容，请在 ${WHITELIST_PATH} 文件添加 APP 包名"
    fi
        
    log "i" "添加白名单"
    # 输出内容
    out_content="$(placeholder 2)# 包含的 Android 应用包名\n$(placeholder 2)include-package:"
    rule_content=""
    rule=$(cat "${MIHOMO_PATH}/rule_provider/classical_whitelist_proxy.list")
    # 获取行号
    line_number=$(cat ${MIHOMO_CONF} | sed -n -e "/disable-icmp-forwarding:/=")
    let "line_number++"
    
    log "i" "获取App包名:"
    
    # 循环获取包名
    for package in ${whitelist_content}
    do
        log "i" "$package"        
        out_content+="\n$(placeholder 4)- ${package}"
        rule=$(echo "$rule" | grep -v ${package})
        rule_content+="PROCESS-NAME,${package}\n"
    done
    
    log "i" "写入配置"
    
    # 输出配置
    out_content=$(cat ${MIHOMO_CONF} | sed ${line_number}"i ${out_content}" | sed "s/$(placeholder 1)/ /g")
    echo "${out_content}" > ${MIHOMO_CONF} 
    rule_content+="${rule}"
    echo -e "${rule_content}" > "${MIHOMO_PATH}/rule_provider/classical_whitelist_proxy.list"
}

tun_device
ipv6_proxy
if [ "${ENABLE_WHITELIST}" = true ]; then
    log "i" "使用白名单"
    whitelist_package
else
    log "i" "使用黑名单"
    blacklist_package
fi