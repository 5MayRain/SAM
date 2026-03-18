# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 系统 hosts 文件路径
SYSTEM_HOSTS="/system/etc/hosts"

# 日志文件
LOG_FILE="${TMP_PATH}/hosts.log"

EVENT=$1
MONITOR_DIR=$2
MONITOR_FILE=$3

if [ "$EVENT" = "w" ]; then
    log "i" "检测到 hosts 文件发生改变"
    log "i" "重新挂载 hosts 文件"
        
    # 获取挂载状态
    mount_status=$(mount | grep -i "$SYSTEM_HOSTS")
    # 判断正在挂载则取消挂载
    if [ "$mount_status" ]; then
        umount $SYSTEM_HOSTS
    fi
    
    # 挂载 hosts 文件
    mount -o bind "$HOSTS_PATH" "$SYSTEM_HOSTS"
    log "i" "重新挂载成功"
fi