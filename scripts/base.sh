# 加载设置
. /data/adb/modules/SAM/setting.conf
# 加载配置
. /data/adb/modules/SAM/scripts/config.sh

# 添加路径
[ -d "/data/adb/magisk" ] && export PATH="/data/adb/magisk:$PATH"
[ -d "/data/adb/ksu/bin" ] && export PATH="/data/adb/ksu/bin:$PATH"
[ -d "/data/adb/ap/bin" ] && export PATH="/data/adb/ap/bin:$PATH"
export PATH="/data/adb/modules/SAM/bin:$PATH"


# 日志
log(){
    time=$(date "+%Y-%m-%d %H:%M:%S")
    echo $1
    if [ $2 ]; then
        echo "[$time]: $1" > "$MODULE_PATH/tmp/module.log"
        return
    fi
    echo "[$time]: $1" >> "$MODULE_PATH/tmp/module.log"
}