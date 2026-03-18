# 等待系统启动
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 3
done

# 模块目录
MODULE_PATH="/data/adb/modules/SAM"
# 脚本目录
SCRIPTS_PATH="/data/adb/modules/SAM/scripts"

# 删除日志及缓存文件
rm -rf "${MODULE_PATH}/tmp/*"

# 创建软链接
if [ ! -e "${MODULE_PATH}/bin/smartdns" ]; then
    ln -s "${MODULE_PATH}/etc/SmartDNS/run-smartdns" "$MODULE_PATH/bin/smartdns"
    ln -s "${MODULE_PATH}/etc/SmartDNS/lib/libc.so" "${MODULE_PATH}/etc/SmartDNS/lib/ld-musl-arm.so.1"
    ln -s "${MODULE_PATH}/etc/SmartDNS/lib/ld-musl-arm.so.1" "${MODULE_PATH}/etc/SmartDNS/lib/ld-linux.so"
fi

# 重置
cat "${MODULE_PATH}/module.prop" | sed  -i "6c description=None" "${MODULE_PATH}/module.prop"

# 启动
su -c "${SCRIPTS_PATH}/service.sh start"

# 监控模块
inotifyd ${SCRIPTS_PATH}/inotify/module.sh "${MODULE_PATH}" > /dev/null 2>&1 &

# 获取 Host 状态
host_status=$(cat "${MODULE_PATH}/setting.conf" | grep "HOST_ENABLE=" | awk -F'=' '{print $2}')
# 判断 host 启用则执行
if [ "${host_status}" = true ]; then
    # 模块 hosts 文件路径
    HOSTS_FILE="${MODULE_PATH}/etc/hosts"
    # 系统 hosts 文件路径
    SYSTEM_HOSTS="/system/etc/hosts"
    # 挂载 hosts 文件
    mount -o bind "${HOSTS_FILE}" "${SYSTEM_HOSTS}"
    # 监控 hosts 文件
    inotifyd ${SCRIPTS_PATH}/inotify/host.sh "${HOSTS_FILE}" &
fi

# 获取WIFI黑名单
BLACKLIST_WIFI=($(cat "${MODULE_PATH}/setting.conf" | grep "BLACKLIST_WIFI=" | sed -e 's/BLACKLIST_WIFI=(//g' -e 's/)$//g'))
# 判断黑名单不为空，则启动监听
if [ "${#BLACKLIST_WIFI[@]}" -ne 0 ]; then
    ${SCRIPTS_PATH}/wifi.monitor.sh &
fi

# 获取定时是否启用
crontab_status=$(cat "$MODULE_PATH/setting.conf" | grep "CRONTAB_ENABLE=" | sed "s/CRONTAB_ENABLE=//g")
# 判断定时启用则执行
if [ "${crontab_status}" = true ]; then
    busybox crond -c "${MODULE_PATH}/etc/crontabs/"
fi