# 加载基础脚本
. /data/adb/modules/SAM/scripts/base.sh

# 获取 GitHub520 
get_GitHub520(){    
    log "下载 GitHub520 host"
    
    # 获取 GitHub520 host 并排除注释
    github_host=$(curl -s https://raw.hellogithub.com/hosts | grep -Ev "^#|^\s*$" | awk -F' ' '{print $1a, $2}')
    
    # 检查内容为空则退出
    if [ ${#github_host} -lt 1000 ]; then
        log "下载失败，取消使用"
        return
    fi
    
    # 写入 hosts 文件
    host_content=$(cat $HOSTS_PATH | grep -i -Ev "github|vscode")
    echo "$host_content\n\n# GitHub 加速\n$github_host" > $HOSTS_PATH
    
    log "写入 hosts 文件"
}

# 添加指令
case "$1" in
    # GitHub520
    gh)
        get_GitHub520
        ;;
    *)
        echo "使用: gh(GitHub加速)"
        exit 1
        ;;
esac