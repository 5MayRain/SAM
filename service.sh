# 等待系统启动
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 3
done

# 模块路径
MODULE_PATH="/data/adb/modules/SAM"
# 脚本.路径
SCRIPTS_PATH="${MODULE_PATH}/scripts"
# 监控脚本目录
INOTIFY_PATH="${SCRIPTS_PATH}/inotify"
# 设置文件
SETTING_FILE="${MODULE_PATH}/setting.conf"

[ ! -e "${MODULE_PATH}/tmp" ] && mkdir "${MODULE_PATH}/tmp"

# 删除日志及缓存文件
rm -rf "${MODULE_PATH}/tmp/*"

# 创建软链接
if [ ! -e "${MODULE_PATH}/bin/smartdns" ]; then
    ln -s "${MODULE_PATH}/etc/SmartDNS/smartdns" "$MODULE_PATH/bin/smartdns"
    ln -s "${MODULE_PATH}/etc/SmartDNS/lib/libc.so" "${MODULE_PATH}/etc/SmartDNS/lib/ld-musl-aarch64.so.1"
    ln -s "${MODULE_PATH}/etc/SmartDNS/lib/ld-musl-aarch64.so.1" "${MODULE_PATH}/etc/SmartDNS/lib/ld-linux.so"
fi

# 重置
sed  -i "6c description=模块未启动" "${MODULE_PATH}/module.prop"


{
    # 等待10秒后启动
    sleep 10
    su -c "${SCRIPTS_PATH}/service.sh start"
} &

# 监控模块
inotifyd "${INOTIFY_PATH}/module.sh" ${MODULE_PATH} &

# 判断 host 启用则执行
grep -q "HOST_ENABLE=true" "${SETTING_FILE}" && {
    # 模块 hosts 文件路径
    HOSTS_FILE="${MODULE_PATH}/etc/hosts"
    # 系统 hosts 文件路径
    SYSTEM_HOSTS="/system/etc/hosts"
    # 挂载 hosts 文件
    mount -o bind "${HOSTS_FILE}" "${SYSTEM_HOSTS}"
    # 监控 hosts 文件
    inotifyd "${INOTIFY_PATH}/host.sh" ${HOSTS_FILE} &
}

# 获取WIFI黑名单
BLACKLIST_WIFI=($(cat "${MODULE_PATH}/setting.conf" | grep "BLACKLIST_WIFI=" | sed -e 's/BLACKLIST_WIFI=(//g' -e 's/)$//g'))
# 判断黑名单不为空，则启动监听
if [ "${#BLACKLIST_WIFI[@]}" -ne 0 ]; then
    ${SCRIPTS_PATH}/wifi.monitor.sh &
fi

# 判断定时启用则执行
grep -q "CRONTAB_ENABLE=true" "${SETTING_FILE}" && busybox crond -c "${MODULE_PATH}/etc/crontabs/"

