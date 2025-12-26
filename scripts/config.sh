# 模块路径
MODULE_PATH="/data/adb/modules/SAM"

# host 路径
HOSTS_PATH="$MODULE_PATH/etc/hosts"

# 脚本路径
SCRIPTS_PATH="$MODULE_PATH/scripts"

# AdGuardHome 路径
AGH_PATH="$MODULE_PATH/etc/AdGuardHome"
# Mihomo 路径
MIHOMO_PATH="$MODULE_PATH/etc/mihomo"
# SmartDNS 路径
SMARTDNS_PATH="$MODULE_PATH/etc/SmartDNS"

# AdGuardHome 程序
AGH_BIN="AdGuardHome"
# Mihomo 程序
MIHOMO_BIN="mihomo"
# SmartDNS 程序
SMARTDNS_BIN="smartdns"

# AdGuardHome 配置
AGH_CONF="$AGH_PATH/$AGH_BIN.yaml"
# Mihomo 配置
MIHOMO_CONF="$MIHOMO_PATH/config.yaml"
# SmartDNS 配置
SMARTDNS_CONF="$SMARTDNS_PATH/$SMARTDNS_BIN.conf"