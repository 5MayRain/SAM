# 防止重复启动
if [ $(pgrep -f "$0" | wc -l) -gt 1 ]; then
    exit 0
fi

# 脚本路径
SCRIPTS_PATH="/data/adb/modules/SAM/scripts"
# 加载配置
source "$SCRIPTS_PATH/config.sh"

# 获取当前连接 WIFI 的 SSID
get_WIFI_SSID(){
    dumpsys connectivity | grep "WIFI CONNECTED" | sed -n 's/.*SSID: "\(.*\)".*/\1/p'
}

# 无限循环
while true
do
    # 加载设置
    source "/data/adb/modules/SAM/setting.conf"
    
    # 判断黑名单为空，和服务未启动，则启动服务并且退出监控
    if [ ${#BLACKLIST_WIFI[@]} -eq 0 ]; then
        run_number=$(
pgrep -f $MIHOMO_BIN $SMARTDNS_BIN $AGH_BIN | wc -l)
        [ $run_number -le 0 ] && $SCRIPTS_PATH/service.sh start
        exit 0
    fi

    # 状态值
    state=0
    # 索引
    i=0
    # 循环遍历黑名单 WIFI
    while(($i < ${#BLACKLIST_WIFI[@]}))
    do
        # 运行服务数量
        run_number=$(
pgrep -f $MIHOMO_BIN $SMARTDNS_BIN $AGH_BIN | wc -l)
        # 判断当前所连接WIFI是否在黑名单
        if [ "$(get_WIFI_SSID)" = "${BLACKLIST_WIFI[$i]}" ]; then
            state=0
            break
        fi
        state=1
        let "i++"
    done
    
    if [ $state -eq 1 ]; then
        # 小于等于0则启动
        [ $run_number -le 0 ] && $SCRIPTS_PATH/service.sh start
    else
        # 大于0则停止
        [ $run_number -gt 0 ] && $SCRIPTS_PATH/service.sh stop
    fi
    
    # 等待10秒
    sleep 10
done