# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 基础配置
base_conf="${MIHOMO_PATH}/base.yaml"

# 修改 mihomo 订阅配置
sub_config(){
    log "i" "修改订阅配置"
    
    # 订阅名称
    sub_names=""
    # 订阅内容
    sub_contents=""
    
    log "i" "获取订阅地址:"
    
    # 遍历订阅地址
    for i in ${!SUB_URL[@]}
    do
        log "i" "${SUB_URL[$i]}"
        # 订阅编号
        index=`expr $i + 1`
        # 订阅名称
        sub_names+="$(placeholder 4)- provider$index"
        if [ $index -lt ${#SUB_URL[@]} ]; then
            sub_names+="\n"
        fi
        # 订阅内容
        sub_contents+="$(placeholder 2)provider$index:\n"
        sub_contents+="$(placeholder 4)<<: *p\n"
        sub_contents+="$(placeholder 4)url: \"${SUB_URL[$i]}\"\n"
        sub_contents+="$(placeholder 4)path: ./proxy_provider/provider$index.yaml\n"
        sub_contents+="$(placeholder 4)override:\n"
        sub_contents+="$(placeholder 6)additional-prefix: \"[订阅$index]\"\n"
    done
    
    log "i" "添加订阅地址"
    
    # 在 proxy-providers 项，添加订阅内容
    line=$(cat $base_conf | sed -n -e "/proxy-providers:/=")
    line=`expr $line + 1`
    out_content=$(cat $base_conf | sed $line"i $sub_contents")    
    # 在 All: &All 项，添加订阅名称
    line=$(echo "$out_content" | sed -n -e "/All: &All/=")
    line=`expr $line + 3`
    out_content=$(echo "$out_content" | sed $line"i $sub_names")
    # 在 A: &A 项，添加订阅名称
    line=$(echo "$out_content" | sed -n -e "/A: &A/=")
    line=`expr $line + 2`
    out_content=$(echo "$out_content" | sed $line"i $sub_names")   
    # 输出配置
    echo "$out_content" | sed "s/$(placeholder 1)/ /g" > $MIHOMO_CONF
    
    log "i" "订阅配置修改成功"
}

sub_config