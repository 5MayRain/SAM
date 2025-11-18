# 加载基础脚本
. /data/adb/modules/SAM/scripts/base.sh

# 启动 AdGuardHome
agh_start(){
    # 判断禁用则退出
    if [ $AGH_ENABLE = false ]; then
        log "AdGuardHome 已禁用"
        log "如需启用，请修改 setting.conf 文件"
        return
    fi
    # AdGuardHome 状态
    state_number=$(pidof $AGH_BIN)
    # AdGuardHome 正在运行则退出
    if [ $state_number ]; then
        log "AdGuardHome 正在运行"
        return
    fi
    log "启动 AdGuardHome"
    # 后台启动并输出日志
    nohup $MODULE_PATH/bin/$AGH_BIN -c $AGH_CONF -w $AGH_PATH --no-check-update > $MODULE_PATH/tmp/$AGH_BIN.log 2>&1 &
    # 延时 1秒
    sleep 1
    # 添加 iptables 规则
    $SCRIPTS_PATH/iptables.sh -e agh
    # 输出 AdGuardHome 状态
    state_number=$(pidof $AGH_BIN)
    [ $state_number ] && log "AdGuardHome 启动成功" || log "AdGuardHome 启动失败"
    return
}

# 停止 AdGuardHome
agh_stop(){
    # AdGuardHome 状态
    state_number=$(pidof $AGH_BIN)
    # AdGuardHome 没有运行则退出
    if [ -z $state_number ]; then
        log "AdGuardHome 已停止运行"
        return
    fi
    log "关闭 AdGuardHome"
    # 杀死 AdGuardHome 进程
    pid=$(pidof $AGH_BIN)
    kill $pid || kill -9 $pid > /dev/null 2>&1
    # 延时1秒
    sleep 1
    # 删除 iptables 规则    
    $SCRIPTS_PATH/iptables.sh -d agh
    # 输出 AdGuardHome 状态
    state_number=$(pidof $AGH_BIN)
    [ -z $state_number ] && log "AdGuardHome 关闭成功" || log "AdGuardHome 关闭失败"
}

# 启动 SmartDNS
smartdns_start(){
    # 判断禁用则退出
    if [ $SMARTDNS_ENABLE = false ]; then
        log "SmartDNS 已禁用"
        log "如需启用，请修改 setting.conf 文件"
        return
    fi
    # SmartDNS 状态
    state_number=$(pidof $SMARTDNS_BIN)
    # SmartDNS 正在运行则退出
    if [ $state_number ]; then
        log "SmartDNS 正在运行"
        return
    fi
    log "启动 SmartDNS"
    # 后台启动并输出日志
    nohup $MODULE_PATH/bin/$SMARTDNS_BIN -c $SMARTDNS_CONF -p - > $MODULE_PATH/tmp/$SMARTDNS_BIN.log 2>&1 &
    # 延时 1秒
    sleep 1
    # 输出 SmartDNS 状态
    state_number=$(pidof $SMARTDNS_BIN)
    [ $state_number ] && log "SmartDNS 启动成功" || log "SmartDNS 启动失败"
    return
}

# 停止 SmartDNS
smartdns_stop(){
    # SmartDNS 状态
    state_number=$(pidof $SMARTDNS_BIN)
    # SmartDNS 没有运行则退出
    if [ -z $state_number ]; then
        log "SmartDNS 已停止运行"
        return
    fi
    log "关闭 SmartDNS"
    # 杀死 SmartDNS 进程
    pid=$(pidof $SMARTDNS_BIN)
    kill $pid || kill -9 $pid > /dev/null 2>&1
    # 延时1秒
    sleep 1
    # 输出 SmartDNS 状态
    state_number=$(pidof $SMARTDNS_BIN)
    [ -z $state_number ] && log "SmartDNS 关闭成功" || log "SmartDNS 关闭失败"
}

# 启动 Mihomo
mihomo_start(){
    # Mihomo 状态
    state_number=$(pidof $MIHOMO_BIN)
    # Mihomo 正在运行则退出
    if [ $state_number ]; then
        log "Mihomo 正在运行"
        return
    fi
    log "启动 Mihomo"
    # 后台启动并输出日志
    nohup $MODULE_PATH/bin/$MIHOMO_BIN -d $MIHOMO_PATH > $MODULE_PATH/tmp/$MIHOMO_BIN.log 2>&1 &
    # 延时 1秒
    sleep 1
    # 添加 iptables 规则
    $SCRIPTS_PATH/iptables.sh -e mihomo
    # 输出 Mihomo 状态
    state_number=$(pidof $MIHOMO_BIN)
    [ $state_number ] && log "Mihomo 启动成功" || log "Mihomo 启动失败"
}

# 停止 Mihomo
mihomo_stop(){
    # Mihomo 状态
    state_number=$(pidof $MIHOMO_BIN)
    # Mihomo 没有运行则退出
    if [  -z $state_number ]; then
        log "Mihomo 已停止运行"
        return
    fi
    log "关闭 Mihomo"
    # 杀死 Mihomo 进程
    pid=$(pidof $MIHOMO_BIN)
    kill $pid || kill -9 $pid > /dev/null 2>&1
    # 延时1秒
    sleep 1
    # 删除 iptables 规则    
    $SCRIPTS_PATH/iptables.sh -d mihomo
    # 输出 Mihomo 状态
    state_number=$(pidof $MIHOMO_BIN)
    [ -z $state_number ] && log "Mihomo 关闭成功" || log "Mihomo 关闭失败"
}

# 启动 crontabs
crontabs_start(){
    # 判断禁用则退出
    if [ $CRONTAB_ENABLE = false ]; then
        log "定时执行已禁用"
        log "如需启用，请修改 setting.conf 文件"
        return
    fi
    # crontabs 状态
    state_number=$(pgrep -f 'SAM/etc/crontabs')
    # crontabs 正在运行则退出
    if [ $state_number ]; then
        log "crontabs 正在运行"
        return
    fi
    log "启动 crontabs"
    # 获取 busybox 路径
    busybox_path="/data/adb"
    if [ -e "/data/adb/ksu" ]; then
        busybox_path+="/ksu/bin/busybox"
    elif [ -e "/data/adb/magisk" ]; then
        busybox_path+="/magisk/busybox"
    fi
    # 启动
    $busybox_path crond -c "$MODULE_PATH/etc/crontabs/"
    # 延时 1秒
    sleep 1
    # 输出 crontabs 状态
    state_number=$(pgrep -f 'SAM/etc/crontabs')
    [ $state_number ] && log "crontabs 启动成功" || log "crontabs 启动失败"
    return
}

# 停止 crontabs
crontabs_stop(){
    # crontabs 状态
    state_number=$(pgrep -f 'SAM/etc/crontabs')
    # crontabs 没有运行则退出
    if [ -z $state_number ]; then
        log "crontabs 已停止运行"
        return
    fi
    log "关闭 crontabs"
    # 杀死 SmartDNS 进程
    pid=$(pgrep -f 'SAM/etc/crontabs')
    kill $pid || kill -9 $pid > /dev/null 2>&1
    # 延时1秒
    sleep 1
    # 输出 SmartDNS 状态
    state_number=$(pgrep -f 'SAM/etc/crontabs')
    [ -z $state_number ] && log "crontabs 关闭成功" || log "crontabs 关闭失败"
}

# 启动
start(){
    # 判断没有订阅地址则退出
    if [ ${#SUB_URL[@]} = 0 ]; then
        log "没有填写订阅地址 !!!"
        log "请打开 $MODULE_PATH/setting.conf 设置文件，填写订阅地址"
        cat $MODULE_PATH/module.prop | sed -i "6c description=没有填写订阅地址 !!! 请打开 $MODULE_PATH/setting.conf 设置文件，填写订阅地址" "$MODULE_PATH/module.prop"
        log "<<< END"
        exit 0
    fi
    
    # 关闭私人DNS
    log "关闭私人DNS"
    settings get global private_dns_mode | grep off || settings put global private_dns_mode off
    
    # 更新订阅
    $SCRIPTS_PATH/update.sh sub
    # 更新 DNS
    $SCRIPTS_PATH/update.sh dns
    # 更新配置
    $SCRIPTS_PATH/update.sh config
    # 添加黑名单应用
    $SCRIPTS_PATH/proxy.sh bg
    # 启动 SmartDNS
    smartdns_start
    # 启动 Mihomo
    mihomo_start
    # 启动 AdGuardHome
    agh_start 
    # 启动 crontabs
    crontabs_start
    # 更新描述
    $SCRIPTS_PATH/update.sh desc   
}

# 停止
stop(){
    # 停止 AdGuardHome
    agh_stop
    # 停止 Mihomo
    mihomo_stop
    # 停止 SmartDNS
    smartdns_stop
    # 关闭 crontabs
    crontabs_stop
    # 更新描述
    $SCRIPTS_PATH/update.sh desc
}

# 添加指令
case "$1" in
    start)
        # 启动
        log "start >>>" "start"
        start
        log "<<< end"
        ;;
    stop)
        # 停止
        log "stop >>>" "stop"
        stop
        log "<<< end"
        ;;
    restart)
        # 重启
        log "restart >>>" "restart"    
            
        log "stop >"
        stop
        log "< stop"
        
        sleep 1
        
        log "start >"
        start
        log "< start"
        
        log "<<< end"
        ;;
    *)
        echo "使用: start(启动) | stop(停止) | restart(重启)"
        exit 1
        ;;
esac