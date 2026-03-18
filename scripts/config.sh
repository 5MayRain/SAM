# 模块路径
MODULE_PATH="/data/adb/modules/SAM"
# host 路径
HOSTS_PATH="${MODULE_PATH}/etc/hosts"
# 脚本路径
SCRIPTS_PATH="${MODULE_PATH}/scripts"

# SmartDNS 路径
SMARTDNS_PATH="${MODULE_PATH}/etc/SmartDNS"
# AdGuardHome 路径
AGH_PATH="${MODULE_PATH}/etc/AdGuardHome"
# Mihomo 路径
MIHOMO_PATH="${MODULE_PATH}/etc/mihomo"

# SmartDNS 程序
SMARTDNS_BIN="smartdns"
# AdGuardHome 程序
AGH_BIN="AdGuardHome"
# Mihomo 程序
MIHOMO_BIN="mihomo"

# SmartDNS pid
SMARTDNS_PID="${MODULE_PATH}/bin/${SMARTDNS_BIN}.pid"
# AdGuardHome pid
AGH_PID="${MODULE_PATH}/bin/${AGH_BIN}.pid"
# Mihomo pid
MIHOMO_PID="${MODULE_PATH}/bin/${MIHOMO_BIN}.pid"

# SmartDNS 配置
SMARTDNS_CONF="${SMARTDNS_PATH}/${SMARTDNS_BIN}.conf"
# AdGuardHome 配置
AGH_CONF="${AGH_PATH}/${AGH_BIN}.yaml"
# Mihomo 配置
MIHOMO_CONF="${MIHOMO_PATH}/config.yaml"

# AdGuardHome 用户和用户组
AGH_USER="root"
AGH_GROUP="net_raw"

# Mihomo 用户和用户组
MIHOMO_USER_GROUP="root:net_admin"

# 缓存路径
TMP_PATH="${MODULE_PATH}/tmp"
# 日志文件
LOG_FILE="${TMP_PATH}/module.log"

# 黑名单路径
BLACKLIST_PATH="${MODULE_PATH}/etc/app_blacklist.prop"
# 白名单路径
WHITELIST_PATH="${MODULE_PATH}/etc/app_whitelist.prop"

iptables_w="iptables -w 100"
ip6tables_w="ip6tables -w 100"