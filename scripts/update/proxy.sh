# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 处理黑白名单的app包名
app_package(){    
    # 读取内容
    list_content=$(cat ${1} | grep -v '^#' | grep -v '^[[:space:]]*$')
    if [ -z "${list_content}" ]; then
        log "i" "${2}无内容，请在 ${1} 文件添加 APP 包名"
    fi
        
    # 输出内容
    out_content="$(placeholder 2)# ${2}应用包名\n$(placeholder 2)${3}:"
    
    # 获取行号
    line_number=$(cat ${MIHOMO_CONF} | sed -n -e "/disable-icmp-forwarding:/=")
    let "line_number++"
    
    log "i" "添加${2} App:"
    
    # 循环获取包名
    for package in ${list_content}
    do
        log "i" "$package" | sed "s/,.*//g"   
        out_content+="\n$(placeholder 4)- $(echo ${package} | sed 's/,.*//g')"
    done
    
    log "i" "写入配置"
    
    # 输出配置
    out_content=$(cat ${MIHOMO_CONF} | sed ${line_number}"i ${out_content}" | sed "s/$(placeholder 1)/ /g")
    echo "${out_content}\n" > ${MIHOMO_CONF} 
}

# 处理白名单模式
whitelist_mode(){
    # 获取用户应用
    user_app=$(pm list packages -3 | sed "s/package://g")
    # 读取白名单
    white_content=$(cat ${WHITELIST_FILE} | grep -Ev "^#.*|^[[:space:]]*$" | sed "s/,no-rule//g")
    # 排除白名单
    for i in ${white_content}
    do
        user_app=$(echo "${user_app}" | grep -v "${i}")
    done
    # 保存文件
    echo "${user_app}" > "${TMP_PATH}/blacklist.prop" 
    # 输出配置    
    app_package "${TMP_PATH}/blacklist.prop" "黑名单" "exclude-package"
}


if [ ${ENABLE_WHITELIST} = true ] && [ ${WHITELIST_MODE} = 1 ]; then
    log "i" "使用白名单模式 1"
    app_package "${WHITELIST_FILE}" "白名单" "include-package"
elif [ ${ENABLE_WHITELIST} = true ] && [ ${WHITELIST_MODE} = 2 ]; then
    log "i" "使用白名单模式 2"
    whitelist_mode
elif [ ${ENABLE_WHITELIST} = false ]; then
    log "i" "使用黑名单"
    app_package "${BLACKLIST_FILE}" "黑名单" "exclude-package"
fi