{
    # 等待系统启动
    until [ "$(getprop sys.boot_completed)" = "1" ]; do
        sleep 2
    done

    # 等待目录可用
    until [ -d "/sdcard" ]; do
        sleep 2
    done

    # 模块路径
    MODULE_PATH="/data/adb/modules/SAM"
    # 脚本路径
    SCRIPTS_PATH="$MODULE_PATH/scripts"
    # Mihomo 配置路径
    MIHOMO_CONF="$MODULE_PATH/etc/mihomo/config.yaml"

    # 备份
    if [ ! -e "/sdcard/Mihomo配置.yaml" ]; then
        grep -q "BACKUP_CONF=true" "$MODULE_PATH/setting.conf" && cp $MIHOMO_CONF "/sdcard/Mihomo配置.yaml"
    fi
    
    # 解除 App 广告文件锁定
    "$SCRIPTS_PATH/ad.sh" recovery

    # 删除模块目录
    [ -d "$MODULE_PATH" ] && rm -rf "$MODULE_PATH"
    
} &