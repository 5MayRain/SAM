# 模块路径
MODULE_PATH="/data/adb/modules/SAM"

# host 路径
HOSTS_PATH="$MODULE_PATH/etc/hosts"

# ipv6 源设置备份路径
# 请勿修改该文件，可能会造成手机无网络
IPV6_PATH="$MODULE_PATH/etc/ipv6"
# ipv6 关闭配置
IPV6_CLOSE_CONF="/proc/sys/net/ipv6/conf/all/accept_ra:0\n/proc/sys/net/ipv6/conf/wlan0/accept_ra:0\n/proc/sys/net/ipv6/conf/all/disable_ipv6:1\n/proc/sys/net/ipv6/conf/default/disable_ipv6:1\n/proc/sys/net/ipv6/conf/wlan0/disable_ipv6:1"

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