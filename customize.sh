#!/system/bin/sh
SKIPUNZIP=1

# 模块路径
MODULE_PATH="/data/adb/modules/SAM"

ui_print "📥 开始安装"
ui_print "📥 解压模块文件"
unzip -o "${ZIPFILE}" "*" -x "META-INF/*" -d "${MODPATH}" >/dev/null 2>&1
ui_print "💾 文件解压完成"

ui_print "🔒 设置权限"
chmod -R +x "${MODPATH}/bin"
chmod +x "${MODPATH}/etc/SmartDNS/smartdns"
chmod +x "${MODPATH}/etc/SmartDNS/smartdns_ui.so"
chmod -R +x "${MODPATH}/etc/SmartDNS/lib"
chown -R root:net_admin "${MODPATH}/bin"
chown root:net_admin "${MODPATH}/etc/SmartDNS/smartdns"
find "${MODPATH}" -type f -name "*.sh" -exec chmod +x {} \;

# 设置输出内容
out_content=$(cat "${MODPATH}/setting.conf")
# 旧设置内容
old_content=$(cat "${MODULE_PATH}/setting.conf")

# 修改设置
modify_setting(){
    # 旧值
    old_value=$(echo "${1}" | grep -v "示例" | grep ${3})
    # 判断内容为空则返回
    [ -z "${old_value}" ] && return 0
    # 替换行
    line_number=$(echo "${2}" | sed "/示例:/c \#" | sed -n "/${3}/=")
    # 替换
    out_content=$(echo "${2}" | sed "${line_number}c ${old_value}")
}

# 更新设置
update_setting(){
    modify_setting "${old_content}" "${out_content}" "SMARTDNS_ENABLE"
    modify_setting "${old_content}" "${out_content}" "AGH_ENABLE"
    modify_setting "${old_content}" "${out_content}" "AGH_DNS_PORT"
    modify_setting "${old_content}" "${out_content}" "BLOCK_IPV6_DNS"
    modify_setting "${old_content}" "${out_content}" "MIHOMO_ENABLE"
    modify_setting "${old_content}" "${out_content}" "MIHOMO_IPV6"
    modify_setting "${old_content}" "${out_content}" "MIHOMO_DNS_PORT"
    modify_setting "${old_content}" "${out_content}" "TUN_DEVICE"
    modify_setting "${old_content}" "${out_content}" "IP_IPTABLES"
    modify_setting "${old_content}" "${out_content}" "HOST_ENABLE"
    modify_setting "${old_content}" "${out_content}" "CRONTAB_ENABLE"
    modify_setting "${old_content}" "${out_content}" "MODULE_DNS_MODE"
    modify_setting "${old_content}" "${out_content}" "BACKUP_CONF"
    modify_setting "${old_content}" "${out_content}" "SUB_URL"
    modify_setting "${old_content}" "${out_content}" "ENABLE_WHITELIST"
    modify_setting "${old_content}" "${out_content}" "WHITELIST_MODE"
    modify_setting "${old_content}" "${out_content}" "BLACKLIST_WIFI"
    echo "${out_content}" > "${MODPATH}/setting.conf"
}

if [ -e "${MODULE_PATH}/setting.conf" ]; then
    ui_print "🏷️ 使用已有配置"
    # 更新设置
    update_setting
    # 复制黑白名单和hosts文件
    find "${MODULE_PATH}/etc" -maxdepth 1 -type f -exec cp {} "${MODPATH}/etc" \;
    # 复制 SmartDNS 使用缓存
    cp -R -f "${MODULE_PATH}/etc/SmartDNS/data/." "${MODPATH}/etc/SmartDNS/data"
    # 复制 AdGuardHome 使用缓存
    find "${MODULE_PATH}/etc/AdGuardHome/data" -maxdepth 1 -type f -exec cp {} "${MODPATH}/etc/AdGuardHome/data" \;
    # 复制 Mihomo 使用缓存
    cp -R -f "${MODULE_PATH}/etc/mihomo/proxy_provider/." "${MODPATH}/etc/mihomo/proxy_provider"
    cp -R -f "${MODULE_PATH}/etc/mihomo/rule_provider/." "${MODPATH}/etc/mihomo/rule_provider"    
    cp -f "${MODULE_PATH}/etc/mihomo/cache.db" "${MODPATH}/etc/mihomo/cache.db"
fi

ui_print "🌐 SmartDNS ( 账号: root | 密码: root )"
ui_print "🌐 SmartDNS ( WebUI: 127.0.0.1:6080 )"
ui_print "🔰 AdGuardHome ( 账号: root | 密码: root )"
ui_print "🔰 AdGuardHome ( WebUI: 127.0.0.1:3000 )"
ui_print "✈️ Mihomo ( WebUI: 127.0.0.1:9090/ui/ )"

ui_print "🎉 安装完成"