# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 修改模块描述
description(){
    # 文件路径
    file_path="${MODULE_PATH}/module.prop"
    # 描述内容
    desc_content=""
    
    # 启动状态数组
    start_state=()
    # 停止状态数组
    stop_state=()
    
    # 获取 AdGuardHome 状态
    state_number=$(pidof ${AGH_BIN})
    [ ${state_number} ] && start_state+=("${AGH_BIN}") || stop_state+=("${AGH_BIN}")
    # 获取 Mihomo 状态
    state_number=$(pidof ${MIHOMO_BIN})
    [ ${state_number} ] && start_state+=("${MIHOMO_BIN}") || stop_state+=("${MIHOMO_BIN}")
    # 获取 SmartDNS 状态
    state_number=$(pidof ${SMARTDNS_BIN})
    [ ${state_number} ] && start_state+=("${SMARTDNS_BIN}") || stop_state+=("${SMARTDNS_BIN}")
    
    # 正在运行    
    [ ${#start_state[@]} -gt 0 ] && desc_content+="🟢已运行: " 
    for start in ${!start_state[@]}
    do
        desc_content+="[ ${start_state[$start]} ] "
    done
    
    # 已停止
    [ ${#stop_state[@]} -gt 0 ] && desc_content+="🔴已停止: "
    for stop in ${!stop_state[@]}
    do     
        desc_content+="[ ${stop_state[$stop]} ] "
    done
    
    # 用户和密码
    [ ${#start_state[@]} -gt 0 ] && desc_content+="🔰账号/密码: "
    for i in ${start_state[@]}
    do
        if [ "${i}" = "${AGH_BIN}" ]; then
            desc_content+="[ AdGuardHome(root/root) ] "
        elif [ "${i}" = "${SMARTDNS_BIN}" ]; then
            desc_content+="[ SmartDNS(root/root) ] "
        fi
    done
    
    # host
    if [ ${HOST_ENABLE} = true ]; then
        desc_content+="🌐Host: 已启用 "
    else
        desc_content+="🌐Host: 已禁用 "
    fi
    
    # 定时
    if [ ${CRONTAB_ENABLE} = true ]; then
        desc_content+="⏰定时: 已启用 "
    else
        desc_content+="⏰定时: 已禁用 "
    fi
    
    desc_content+="📢注意: 模块已启用开关监听，启用模块则运行程序，禁用模块则停止程序"
    
    # 修改文件
    cat ${file_path} | sed -i "6c description=${desc_content}" ${file_path}
    log "i" "更新模块描述"
}

# 添加指令
case "$1" in
    # 配置
    config)
        ${SCRIPTS_PATH}/update/dns.sh
        ${SCRIPTS_PATH}/update/proxy.sh
        ;;
    # 描述
    desc)
        description
        ;;
    # 订阅
    sub)
        ${SCRIPTS_PATH}/update/sub.sh
        ;;
    *)
        echo "使用: config(更新配置) | desc(更新描述)"
        exit 1
        ;;
esac
