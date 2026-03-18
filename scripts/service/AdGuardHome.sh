# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 启动 AdGuardHome
agh_start(){
    # 判断禁用则退出
    if [ ${AGH_ENABLE} = false ]; then
        log "i" "${AGH_BIN} 已禁用"
        log "i" "如需启用，请修改 setting.conf 文件"
        return 1
    fi
    # AdGuardHome 正在运行则退出
    isRun ${AGH_BIN} && {
        log "e" "${AGH_BIN} 正在运行"
        return 1
    }
    log "i" "启动 ${AGH_BIN}"
    # 后台启动并输出日志
    busybox setuidgid "${AGH_USER}:${AGH_GROUP}" ${AGH_BIN} -c ${AGH_CONF} -w ${AGH_PATH} --no-check-update > "${TMP_PATH}/${AGH_BIN}.log" 2>&1 & echo -n $! > "${AGH_PID}"
    # 延时 1秒
    sleep 1
    # 添加 iptables 规则
    "${SCRIPTS_PATH}/iptables.sh" "-e" "agh"
    # 输出 AdGuardHome 状态    
    isRun ${AGH_BIN} && log "i" "${AGH_BIN} 启动成功" || log "e" "${AGH_BIN} 启动失败"
}

# 停止 AdGuardHome
agh_stop(){
    # AdGuardHome 没有运行则退出
    isRun ${AGH_BIN} || {
        log "e" "${AGH_BIN} 已停止"
        return 1
    }
    log "i" "关闭 AdGuardHome"
    # 杀死 AdGuardHome 进程
    stop "${AGH_PID}" "${AGH_BIN}" && log "i" "${AGH_BIN} 关闭成功" || log "e" "${AGH_BIN} 关闭失败"
    # 延时1秒
    sleep 1
    # 删除 iptables 规则    
    "${SCRIPTS_PATH}/iptables.sh" "-d" "agh"
}

# 添加指令
case "$1" in
    # 启动
    start)
        agh_start
        ;;
    # 停止
    stop)
        agh_stop
        ;;
esac