# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 获取 Host
get_host(){    
    # 读取 hosts
    hosts_content=$(cat ${HOSTS_FILE} | grep -Ev "^[[:space:]]*$")
     
    # 获取开始和结束行
    start_line=$(echo "${hosts_content}" | sed -n "/^#.*start.*${1}/=")
    end_line=$(echo "${hosts_content}" | sed -n "/^#.*${1}.*end/=")
    # 判断获取到则删除
    if [ -n "${start_line}" ] && [ -n "${end_line}" ]; then
        log "i" "删除 ${1} 旧规则"
        hosts_content=$(echo "${hosts_content}" | sed "${start_line},${end_line}d")
    fi
        
    log "i" "获取最新 ${1} host"
    # 获取 host
    get_content=""
    for i in ${2}
    do
        get_content+=$(curl -m 10 -s ${i} | grep -Ev "^#.*$|^[[:space:]]*$" | awk -F' ' '{print $1a, $2}')
        get_content+="\n"
    done
        
    # 检查内容为空则退出
    if [ -z "${get_content}" ] || [ ${#get_content} -le 100 ]; then
        log "e" "获取失败"
        return 1
    fi
    
    # 排序并查重
    get_content=$(echo -e "${get_content}" | sort | uniq | grep -Ev "^[[:space:]]*$")
    # 输出
    hosts_content+="\n# start > ${1}\n${get_content}\n# ${1} < end"
    echo -e "${hosts_content}" | sed "s/^# .*start/\n# start/g" > ${HOSTS_FILE}
    log "i" "写入 hosts 文件"
}



# 添加指令
case "$1" in
    update)
        log "i" "更新 host 规则"
        # GitHub
        get_host "GitHub" "https://github.com/521xueweihan/GitHub520/raw/main/hosts" || log "i" "更换备用链接" && get_host "GitHub" "https://cdn.jsdelivr.net/gh/521xueweihan/GitHub520@master/hosts"
        # FCM
        get_host "FCM" "https://github.com/cagedbird043/fcm-hosts-next/raw/main/fcm_dual.hosts" || log "i" "更换备用链接" && get_host "FCM" "https://cdn.jsdelivr.net/gh/Mice-Tailor-Infra/fcm-hosts-next@master/fcm_dual.hosts"
        ;;
    *)
        echo "使用: update(更新)"
        exit 1
        ;;
esac