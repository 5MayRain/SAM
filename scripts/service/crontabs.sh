# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 启动 crontabs
crontabs_start(){
    # 判断禁用则退出
    if [ ${CRONTAB_ENABLE} = false ]; then
        log "i" "定时执行已禁用"
        log "i" "如需启用，请修改 setting.conf 文件"
        return 1
    fi
    # crontabs 正在运行则退出
    isRun "SAM/etc/crontabs" && {
        log "e" "crontabs 正在运行"
        return 1
    }
    log "i" "启动 crontabs"
    # 启动
    busybox crond -c "$MODULE_PATH/etc/crontabs/"
    # 延时 1秒
    sleep 1
    # 输出 crontabs 状态
    isRun "SAM/etc/crontabs" && log "i" "crontabs 启动成功" || log "e" "crontabs 启动失败"
}

# 停止 crontabs
crontabs_stop(){
    # crontabs 没有运行则退出
    isRun "SAM/etc/crontabs" || {
        log "e" "crontabs 已停止"
        return 1
    }
    log "i" "关闭 crontabs"
    # 杀死 crontabs 进程
    pid=$(pgrep -f 'SAM/etc/crontabs')
    kill -9 $pid > /dev/null 2>&1
    # 延时1秒
    sleep 1
    # 输出 crontabs 状态
    isRun "SAM/etc/crontabs" && log "e" "crontabs 关闭失败" || log "i" "crontabs 关闭成功"
}

# 添加指令
case "$1" in
    # 启动
    start)
        crontabs_start
        ;;
    # 停止
    stop)
        crontabs_stop
        ;;
esac