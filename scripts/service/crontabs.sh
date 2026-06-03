# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 启动
start(){
    # 判断 crontabs 未启用，则退出
    if [ ${CRONTAB_ENABLE} = false ]; then
        log "i" "定时执行已禁用"
        return 1
    fi
    
    # 判断 crontabs 已运行，则退出
    isRun "${MODULE_PATH}/etc/crontabs" && {
        log "e" "crontabs 正在运行"
        return 1
    }
    # 启动
    busybox crond -c "$MODULE_PATH/etc/crontabs/"
    # 延时 1秒
    sleep 1
    # 输出 crontabs 状态
    isRun "${MODULE_PATH}/etc/crontabs" && log "i" "crontabs 启动成功" || log "e" "crontabs 启动失败"
}

# 停止
stop(){
    # crontabs 没有运行则退出
    isRun "${MODULE_PATH}/etc/crontabs" || {
        log "e" "crontabs 已停止"
        return 1
    }
    # 杀死 crontabs 进程
    kill_process "${MODULE_PATH}/etc/crontabs" && log "i" "crontabs 停止成功" || log "e" "crontabs 停止失败"
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