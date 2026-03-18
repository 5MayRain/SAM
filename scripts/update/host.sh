# 加载基础脚本
. /data/adb/modules/SAM/scripts/base.sh

# 获取 Host
get_Host(){    
    log "i" "下载 ${1} host"
    
    # 获取 host 并排除注释
    host=$(curl -s ${2} | grep -Ev "^#|^\s*$" | awk -F' ' '{print $1a, $2}')
    # 检查内容为空则退出
    if [ -z "${host}" ]; then
        log "e" "下载失败，取消使用"
        return 1
    fi
    
    # 写入 hosts 文件
    host_content=$(cat $HOSTS_PATH | grep -i -Ev $3)
    echo -e "$host_content\n\n# $1\n$host" | grep -Ev "^\s*$"  | sed "s/#/\n#/g" > $HOSTS_PATH
    
    log "i" "写入 hosts 文件"
}
    
# 添加指令
case "$1" in
    update)
        # GitHub520
        get_Host "GitHub520" "https://raw.githubusercontent.com/521xueweihan/GitHub520/refs/heads/main/hosts" "github|vscode"
        # FCM
        get_Host "FCM" "https://raw.githubusercontent.com/Mice-Tailor-Infra/fcm-hosts-next/refs/heads/main/fcm_dual.hosts" "fcm|mtalk"
        ;;
    *)
        echo "使用: update(更新)"
        exit 1
        ;;
esac