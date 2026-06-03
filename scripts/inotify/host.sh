# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

EVENT=$1
MONITOR_DIR=$2
MONITOR_FILE=$3

# 系统 hosts 文件路径
SYSTEM_HOSTS="/system/etc/hosts"
# 日志文件
LOG_FILE="${TMP_PATH}/hosts.log"

if [ "$EVENT" = "w" ]; then
    log "i" "检测到 hosts 文件发生改变"
    log "i" "重新挂载 hosts 文件"
            
    # 判断正在挂载则取消挂载
    mount | grep -q $SYSTEM_HOSTS && umount $SYSTEM_HOSTS
    
    # 挂载 hosts 文件
    mount -o bind $HOSTS_FILE $SYSTEM_HOSTS
    log "i" "重新挂载成功"
fi