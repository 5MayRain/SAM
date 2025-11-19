MODULE_PATH="/data/adb/modules/SAM"
SCRIPTS_PATH="/data/adb/modules/SAM/scripts"

(

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 3
done

# 删除日志及缓存文件
rm -rf "$MODULE_PATH/tmp/*"

# 启动
echo "" > $MODULE_PATH/disable
$SCRIPTS_PATH/service.sh start

)

# 重置
cat "$MODULE_PATH/module.prop" | sed  -i "6c description=None" "$MODULE_PATH/module.prop"
cat "$MODULE_PATH/webroot/index.html" | sed "s/status running/status stopped/g" | sed -i "s/已运行/未运行/g" "$MODULE_PATH/webroot/index.html"

# 监控模块目录
inotifyd $SCRIPTS_PATH/inotify.sh "$MODULE_PATH" > /dev/null 2>&1 &
sleep 3
rm -rf $MODULE_PATH/disable

# 获取 Host 状态
host_status=$(cat "$MODULE_PATH/setting.conf" | grep "HOST_ENABLE=" | sed "s/HOST_ENABLE=//g")
# 判断 host 启用则执行
if [ "$host_status" = true ]; then
    time=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$time]: 启用 Host" >> "$MODULE_PATH/tmp/host.log"
    # 获取 GitHub 加速
    $SCRIPTS_PATH/host.sh gh
    # 模块 hosts 文件路径
    HOSTS_FILE="$MODULE_PATH/etc/hosts"
    # 系统 hosts 文件路径
    SYSTEM_HOSTS="/system/etc/hosts"
    # 挂载 hosts 文件
    mount -o bind "$HOSTS_FILE" "$SYSTEM_HOSTS"    
    echo "[$time]: 挂载 host 文件" >> "$MODULE_PATH/tmp/host.log"
    # 监控 hosts 文件
    inotifyd $SCRIPTS_PATH/host.inotify.sh "$HOSTS_FILE" &
    echo "[$time]: 监控 host 文件" >> "$MODULE_PATH/tmp/host.log"
fi

# 获取定时是否启用
crontab_status=$(cat "$MODULE_PATH/setting.conf" | grep "CRONTAB_ENABLE=" | sed "s/CRONTAB_ENABLE=//g")
# 判断定时启用则执行
if [ "$crontab_status" = true ]; then
    $MODULE_PATH/bin/busybox crond -c "$MODULE_PATH/etc/crontabs/"
fi