# 加载基础脚本
. /data/adb/modules/SAM/scripts/base.sh

# 获取 GitHub520 
get_GitHub520(){    
    log "下载 GitHub520 host"
    
    # 获取 GitHub520 host 并排除注释
    github_host=$(curl -s https://raw.hellogithub.com/hosts | grep -v "#")
    
    # 检查内容为空则退出
    if [ ${#github_host} -lt 1000 ]; then
        log "下载失败，取消使用"
        return
    fi
    
    log "下载成功"
    
    # 保存文件
    host_file="$MODULE_PATH/tmp/GitHub520_host"
    echo "$github_host" > $host_file
    
    # GitHub520 内容
    host_content="# GitHub 加速\n"
    
    log "读取 GitHub520 host"
    
    # 循环读取每一行
    while read line
    do
        rule=(${line// / })
        host_content+="${rule[0]} ${rule[1]}\n"
    done < $host_file
    
    log "读取成功"
    
    # 写入 hosts 文件
    host_content=$(cat $HOSTS_PATH | grep -i -v "github" | sed '$a END' | sed "s/END/$host_content\n/")
    echo "$host_content" > $HOSTS_PATH
    
    log "写入 hosts 文件"        
}

# 添加指令
case "$1" in
    # GitHub520
    gh)
        get_GitHub520
        ;;
    *)
        echo "使用: gh(GitHub加速) | -l(日志)"
        exit 1
        ;;
esac