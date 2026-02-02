# 加载基础脚本
. /data/adb/modules/SAM/scripts/base.sh

# 黑名单包名
blacklist_package(){
    # 判断黑名单无内容则退出
    if [ ${#BLACKLIST_PACKAGE[@]} = 0 ]; then
        log "黑名单为空，请在 $MODULE_PATH/setting.conf 设置文件添加"
        return
    fi
    
    log "添加黑名单"
    
    # 输出内容
    out_content="空格空格exclude-package:"
    rule_content=""
    rule=$(cat "$MIHOMO_PATH/rule_provider/classical_blacklist_direct.list")
    # 获取行号
    line_number=$(cat $MIHOMO_CONF | sed -n -e "/exclude-package:/=")
    
    log "获取App包名:"
    
    # 循环获取包名
    for package in ${BLACKLIST_PACKAGE[@]}
    do
        log "$package"        
        out_content+="\n空格空格空格空格- $package"
        rule=$(echo "$rule" | grep -v $package)
        rule_content+="PROCESS-NAME,$package\n"
    done
    log "写入配置"
    
    # 输出配置
    out_content=$(cat $MIHOMO_CONF | sed $line_number"c $out_content" | sed "s/空格/ /g")
    echo "$out_content" > $MIHOMO_CONF 
    rule_content+="$rule"
    echo -e "$rule_content" > "$MIHOMO_PATH/rule_provider/classical_blacklist_direct.list"
}

# 添加指令
case "$1" in
    # 黑名单
    bg)
        blacklist_package
        ;;
    *)
        echo "使用: bg(黑名单)"
        exit 1
        ;;
esac