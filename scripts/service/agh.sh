# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 启动
start(){
    # 判断 AdGuardHome 未启用，则退出
    if [ ${AGH_ENABLE} = false ]; then
        log "e" "${AGH_BIN} 未启用"
        return 1
    fi
    
    # 判断 AdGuardHome 已运行，则退出
    isRun ${AGH_BIN} && {
        log "e" "${AGH_BIN} 已运行"
        return 1
    }
        
    # 更新 AdGuardHome 配置
    ${UPDATE_PATH}/agh.sh
    
    # 启动
    busybox setuidgid "${SAM_USER}:${SAM_GROUP}" ${AGH_BIN} -c ${AGH_CONF} -w ${AGH_PATH} --no-check-update > "${TMP_PATH}/${AGH_BIN}.log" 2>&1 &
    
    # 延时，并判断 AdGuardHome 是否启动成功
    sleep 1
    isRun ${AGH_BIN} && log "i" "${AGH_BIN} 启动成功" || log "e" "${AGH_BIN} 启动失败"
}

# 停止
stop(){
    # 判断 AdGuardHome 未运行，则退出
    isRun ${AGH_BIN} || {
        log "e" "${AGH_BIN} 已停止"
        return 1
    }
    # 杀死 AdGuardHome 进程
    kill_process ${AGH_BIN} && log "i" "${AGH_BIN} 停止成功" || log "e" "${AGH_BIN} 停止失败"
}

# 添加指令
case "$1" in
    # 启动
    start)
        start
        ;;
    # 停止
    stop)
        stop
        ;;
esac