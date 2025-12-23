#!/system/bin/sh
SKIPUNZIP=1

ui_print "📥 开始安装 ......"

# 模块路径
MODULE_PATH="/data/adb/modules/SAM"
# 脚本路径
SCRIPTS_PATH="$MODPATH/scripts"
# AdGuardHome 路径
AGH_PATH="$MODPATH/etc/AdGuardHome"
# Mihomo 路径
MIHOMO_PATH="$MODPATH/etc/mihomo"
# SmartDNS 路径
SMARTDNS_PATH="$MODPATH/etc/SmartDNS"
# AdGuardHome 程序
AGH_BIN="AdGuardHome"
# Mihomo 程序
MIHOMO_BIN="mihomo"
# SmartDNS 程序
SMARTDNS_BIN="smartdns"

# 修改配置文件
modify_conf(){
    # 获取已安装模块的配置文件内容
    content=$(cat $1 | sed "/示例:/c \#")
    # 获取所需修改设置的行号
    line=$(echo "$content" | sed -n -e "/$3/=")
    # 获取所需修改设置行的内容
    text=$(echo "$content"| sed -n -e "/$3/p")
    echo "$(cat "$2" | sed $line"c $text")" > $2
}

# 更新配置文件
update_conf(){
    # 已安装模块的配置文件路径
    s="$MODULE_PATH/setting.conf"
    # 更新模块的配置文件路径
    t="$MODPATH/setting.conf"
    # 需要更新的配置
    #conf_array=("AGH_ENABLE" "AGH_DNS_PORT" "AGH_USER" "AGH_GROUP" "BLOCK_IPV6_DNS" "SMARTDNS_ENABLE" "TUN_DEVICE" "MIHOMO_DNS_PORT" "MIHOMO_IPV6" "IP_IPTABLES" "HOST_ENABLE" "CRONTAB_ENABLE" "BACKUP_CONF" "SUB_URL" "BLACKLIST_PACKAGE")
    # 循环执行查找并替换
    #for i in ${!conf_array[@]}
    #do
        #modify_conf "$s" "$t" "${conf_array[$i]}"
    #done
    modify_conf "$s" "$t" "AGH_ENABLE"
    modify_conf "$s" "$t" "AGH_DNS_PORT"
    modify_conf "$s" "$t" "AGH_USER"
    modify_conf "$s" "$t" "AGH_GROUP"
    modify_conf "$s" "$t" "BLOCK_IPV6_DNS"
    modify_conf "$s" "$t" "SMARTDNS_ENABLE"
    modify_conf "$s" "$t" "TUN_DEVICE"
    modify_conf "$s" "$t" "MIHOMO_DNS_PORT"
    modify_conf "$s" "$t" "MIHOMO_IPV6"
    modify_conf "$s" "$t" "IP_IPTABLES"
    modify_conf "$s" "$t" "HOST_ENABLE"
    modify_conf "$s" "$t" "CRONTAB_ENABLE"
    modify_conf "$s" "$t" "BACKUP_CONF"
    modify_conf "$s" "$t" "SUB_URL"
    modify_conf "$s" "$t" "BLACKLIST_PACKAGE"
}

ui_print "📥 解压模块基本文件"
unzip -o "$ZIPFILE" "module.prop" -d "$MODPATH" >/dev/null 2>&1
unzip -o "$ZIPFILE" "service.sh" -d "$MODPATH" >/dev/null 2>&1
unzip -o "$ZIPFILE" "action.sh" -d "$MODPATH" >/dev/null 2>&1
unzip -o "$ZIPFILE" "setting.conf" -d "$MODPATH" >/dev/null 2>&1
unzip -o "$ZIPFILE" "uninstall.sh" -d "$MODPATH" >/dev/null 2>&1
unzip -o "$ZIPFILE" "webroot/*" -d "$MODPATH" >/dev/null 2>&1
unzip -o "$ZIPFILE" "tmp/*" -d "$MODPATH" >/dev/null 2>&1

ui_print "📥 解压脚本文件"
unzip -o "$ZIPFILE" "scripts/*" -d "$MODPATH" >/dev/null 2>&1

ui_print "📥 解压二进制文件"
unzip -o "$ZIPFILE" "bin/*" -d "$MODPATH" >/dev/null 2>&1

ui_print "📥 解压 AdGuardHome 文件"
unzip -o "$ZIPFILE" "etc/AdGuardHome/*" -d "$MODPATH" >/dev/null 2>&1

ui_print "📥 解压 Mihomo 文件"
unzip -o "$ZIPFILE" "etc/mihomo/*" -d "$MODPATH" >/dev/null 2>&1

ui_print "📥 解压 SmartDNS 文件"
unzip -o "$ZIPFILE" "etc/SmartDNS/*" -d "$MODPATH" >/dev/null 2>&1

ui_print "📥 解压 crontabs 文件"
unzip -o "$ZIPFILE" "etc/crontabs/*" -d "$MODPATH" >/dev/null 2>&1

ui_print "📥 解压 hosts 文件"
unzip -o "$ZIPFILE" "etc/hosts" -d "$MODPATH" >/dev/null 2>&1

ui_print "💾 文件解压完成"

# 使用已有配置
if [ -e "$MODULE_PATH/setting.conf" ]; then
    ui_print "🏷️ 使用已有配置"
    update_conf
    copy_path="$MODULE_PATH/etc"
    if [ ! -e "$MODULE_PATH/etc"]; then
        copy_path="$MODULE_PATH"    
    fi
    cp -rf "$copy_path/AdGuardHome/data/." "$AGH_PATH/data/"
    cp -f "$copy_path/AdGuardHome/AdGuardHome.yaml" "$AGH_PATH/AdGuardHome.yaml"
    cp -f "$copy_path/mihomo/cache.db" "$MIHOMO_PATH/cache.db"
    cp -rf "$copy_path/mihomo/rule_provider/." "$MIHOMO_PATH/rule_provider/"
    cp -rf "$copy_path/mihomo/proxy_provider/." "$MIHOMO_PATH/proxy_provider/"
    if [ -e "$copy_path/SmartDNS/data" ]; then
        cp -rf "$copy_path/SmartDNS/data/." "$SMARTDNS_PATH/data/"
    else        
        cp -f "$copy_path/SmartDNS/smartdns.cache" "$SMARTDNS_PATH/data/smartdns.cache"
    fi 
    cp -f "$copy_path/crontabs/root" "$MODPATH/etc/crontabs/root"    
    cp -f "$copy_path/hosts" "$MODPATH/etc/hosts"
fi

# 获取 busybox 路径
busybox_path="/data/adb"
if [ "$KSU" = true ]; then
    busybox_path="$busybox_path/ksu/bin/busybox"
else
    busybox_path="$busybox_path/magisk/busybox"
fi
# 创建软链接
busybox_bin="$MODPATH/bin/busybox"
ln -s "$busybox_path" "$busybox_bin"
ui_print "🏷️ 创建软链接 $busybox_path > $busybox_bin"

# 设置权限
ui_print "🔒 设置权限 ......"
chmod +x "$MODPATH/bin/$AGH_BIN"
chmod +x "$MODPATH/bin/$MIHOMO_BIN"
chmod -R 666 "$MIHOMO_PATH/rule_provider/"
chmod +x "$SMARTDNS_PATH/run-smartdns"
chmod +x "$SMARTDNS_PATH/smartdns_ui.so"
chmod +x "$SMARTDNS_PATH/$SMARTDNS_BIN"
chmod -R +x "$SMARTDNS_PATH/lib/"
chmod +x "$SCRIPTS_PATH"/*.sh "$MODPATH"/*.sh
chown root:net_raw "$MODPATH/bin/$AGH_BIN"
chown root:net_admin "$MODPATH/bin/$MIHOMO_BIN"
chown root:net_raw "$SMARTDNS_PATH/run-smartdns"
chown root:net_raw "$SMARTDNS_PATH/$SMARTDNS_BIN"
ui_print "🔒 设置权限完成"

ui_print "🌐 SmartDNS ( 账号: root | 密码: root )"
ui_print "🌐 SmartDNS ( WebUI: 127.0.0.1:6080 )"
ui_print "🔰 AdGuardHome ( 账号: root | 密码: root )"
ui_print "🔰 AdGuardHome ( WebUI: 127.0.0.1:3000 )"
ui_print "✈️ Mihomo ( WebUI: 127.0.0.1:9090/ui/ )"

ui_print "🎉 安装完成"
ui_print "🏷️ 请打开 $MODPATH/setting.conf 设置文件，填写订阅地址"
ui_print "🏷️ 填写完成后请重启"