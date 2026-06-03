EVENT=$1
MONITOR_DIR=$2
MONITOR_FILE=$3

# 模块路径
MODULE_PATH="/data/adb/modules/SAM"
# 脚本路径
SCRIPTS_PATH="${MODULE_PATH}/scripts"
# Mihomo备份配置
MIHOMO_CONF="/sdcard/Mihomo配置.yaml"

# 判断模块是否启用
if [ "${MONITOR_FILE}" = "disable" ]; then
    if [ "${EVENT}" = "d" ]; then
        ${SCRIPTS_PATH}/service.sh start
    elif [ "${EVENT}" = "n" ]; then        
        ${SCRIPTS_PATH}/service.sh stop
    fi
fi

# 判断模块是否卸载
if [ "${MONITOR_FILE}" = "remove" ]; then
    if [ "${EVENT}" = "d" ] && [ -e "${MIHOMO_CONF}" ]; then
        rm -rf "${MIHOMO_CONF}"
    elif [ "${EVENT}" = "n" ] && [ -e "${MODULE_PATH}/etc/mihomo/config.yaml" ]; then
        grep -q "BACKUP_CONF=true" "${MODULE_PATH}/setting.conf" && cp -f "${MODULE_PATH}/etc/mihomo/config.yaml" "${MIHOMO_CONF}"
        "${SCRIPTS_PATH}/ad.sh" recovery
    fi
fi