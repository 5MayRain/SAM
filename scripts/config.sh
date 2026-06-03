# 模块路径
MODULE_PATH="/data/adb/modules/SAM"
# 程序路径
BIN_PATH="${MODULE_PATH}/bin"
# 缓存路径
TMP_PATH="${MODULE_PATH}/tmp"
# 脚本路径
SCRIPTS_PATH="${MODULE_PATH}/scripts"
# 监控脚本目录
INOTIFY_PATH="${SCRIPTS_PATH}/inotify"
# 防火墙脚本路径
IPTABLES_PATH="${SCRIPTS_PATH}/iptables"
# 服务脚本路径
SERVICE_PATH="${SCRIPTS_PATH}/service"
# 更新脚本路径
UPDATE_PATH="${SCRIPTS_PATH}/update"

# 日志文件
LOG_FILE="${TMP_PATH}/module.log"
# host 文件
HOSTS_FILE="${MODULE_PATH}/etc/hosts"

# 用户
SAM_USER="root"
# 用户组"
SAM_GROUP="net_admin"

# SmartDNS 路径
SMARTDNS_BIN="smartdns"
# SmartDNS 路径
SMARTDNS_PATH="${MODULE_PATH}/etc/SmartDNS"
# SmartDNS 配置
SMARTDNS_CONF="${SMARTDNS_PATH}/${SMARTDNS_BIN}.conf"

# AdGuardHome 路径
AGH_BIN="AdGuardHome"
# AdGuardHome 路径
AGH_PATH="${MODULE_PATH}/etc/AdGuardHome"
# AdGuardHome 配置
AGH_CONF="${AGH_PATH}/${AGH_BIN}.yaml"

# Mihomo 路径
MIHOMO_BIN="mihomo"
# Mihomo 路径
MIHOMO_PATH="${MODULE_PATH}/etc/mihomo"
# Mihomo 配置
MIHOMO_CONF="${MIHOMO_PATH}/config.yaml"

# 黑名单文件
BLACKLIST_FILE="${MODULE_PATH}/etc/app_blacklist.prop"
# 白名单文件
WHITELIST_FILE="${MODULE_PATH}/etc/app_whitelist.prop"