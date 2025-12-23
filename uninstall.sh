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
# Mihomo 路径
MIHOMO_PATH="$MODULE_PATH/etc/mihomo"
# Mihomo 配置
MIHOMO_CONF="$MIHOMO_PATH/config.yaml"

# 获取备份设置
BACKUP_CONF=$(cat "$MODULE_PATH/setting.conf" | grep "BACKUP_CONF=" | awk -F'=' '{print $2}')

# 判断已启用备份
if [ $BACKUP_CONF = true ]; then
    # 复制配置文件到sd根目录
    cp -f "$MIHOMO_CONF" "/sdcard/Mihomo配置.yaml"
fi

# 解除 App 广告文件锁定
"$SCRIPTS_PATH/ad.sh" recovery

[ -d "$MODULE_PATH" ] && rm -rf "$MODULE_PATH"