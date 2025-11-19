# 加载基础脚本
. /data/adb/modules/SAM/scripts/base.sh

# 修改 AdGuardHome DNS 端口
dns_port(){
    # 获取 AdGuardHome DNS 端口
    port_value=$(cat $AGH_CONF | sed -n '/port:/p' | grep "port" | awk 'NR==2{print $2}' | tr -d "[:space:]")
    # 判断 AdGuardHome DNS 端口与设置的端口不一致则修改
    if ! [ $AGH_DNS_PORT -eq $port_value ]; then
        log "修改 AdGuardHome DNS 端口 $port_value 为 $AGH_DNS_PORT"
        cat $AGH_CONF | sed -i "s/port: $port_value/port: $AGH_DNS_PORT/g" $AGH_CONF 
    fi
}

# 修改 Mihomo TUN 网卡
tun_device(){
    # 获取 Mihomo TUN 网卡
    device_value=$(cat $MIHOMO_CONF | grep "device" | awk '{print $2}' | tr -d "[:space:]")
    # 判断 Mihomo TUN 网卡 与设置的网卡不一致则修改
    if [ $TUN_DEVICE != $device_value ]; then        
        log "修改 Mihomo TUN 网卡 $device_value 为 $TUN_DEVICE"
        cat $MIHOMO_CONF | sed -i "s/device: $device_value/device: $TUN_DEVICE/g" $MIHOMO_CONF 
    fi
}

# 修改模块描述
description(){
    # 文件路径
    file_path="$MODULE_PATH/module.prop"
    # 描述内容
    desc_content=""
    
    # 启动状态数组
    start_state=()
    # 停止状态数组
    stop_state=()
    
    # 获取 AdGuardHome 状态
    state_number=$(pidof $AGH_BIN)
    [ $state_number ] && start_state+=("$AGH_BIN") || stop_state+=("$AGH_BIN")
    # 获取 Mihomo 状态
    state_number=$(pidof $MIHOMO_BIN)
    [ $state_number ] && start_state+=("$MIHOMO_BIN") || stop_state+=("$MIHOMO_BIN")
    # 获取 SmartDNS 状态
    state_number=$(pidof $SMARTDNS_BIN)
    [ $state_number ] && start_state+=("$SMARTDNS_BIN") || stop_state+=("$SMARTDNS_BIN")
    
    # 正在运行    
    [ ${#start_state[@]} -gt 0 ] && desc_content+="🟢已运行: " 
    for start in ${!start_state[@]}
    do
        desc_content+="[ ${start_state[$start]} ] "
    done
    
    # 已停止
    [ ${#stop_state[@]} -gt 0 ] && desc_content+="🔴已停止: "
    for stop in ${!stop_state[@]}
    do     
        desc_content+="[ ${stop_state[$stop]} ] "
    done
    
    # WebUI
    if [ ${#start_state[@]} -gt 1 ]; then
        desc_content+="🌎WebUI: [ AdGuardHome(127.0.0.1:3000) ] [ mihomo(127.0.0.1:9090/ui/) ] "
    elif [ ${#start_state[@]} != 0 ]; then
        if [ "${start_state[0]}" = "$AGH_BIN" ]; then
            desc_content+="🌎WebUI: [ AdGuardHome(127.0.0.1:3000) ] "
        else
            desc_content+="🌎WebUI: [ mihomo(127.0.0.1:9090/ui/) ] "
        fi
    fi
    
    # 用户和密码
    if [ "${start_state[0]}" = "$AGH_BIN" ] || [ "${start_state[1]}" = "$AGH_BIN" ]; then
        desc_content+="🔰AdGuardHome: [ root(账号/密码) ] "
    fi
    
    # host
    if [ $HOST_ENABLE = true ]; then
        desc_content+="🌐Host: 已启用 "
    else
        desc_content+="🌐Host: 已禁用 "
    fi
    
    # 定时
    if [ $CRONTAB_ENABLE = true ]; then
        desc_content+="⏰定时: 已启用 "
    else
        desc_content+="⏰定时: 已禁用 "
    fi
    
    desc_content+="📢注意: 模块已启用开关监听，启用模块则运行程序，禁用模块则停止程序"
    
    # 修改文件
    cat $file_path | sed -i "6c description=$desc_content" $file_path
    log "更新模块描述"
}

# 修改订阅
sub(){
    log "修改订阅配置"
    
    # 基础配置
    base_conf="$MIHOMO_PATH/base.yaml"
    
    # 订阅名称
    sub_names=""
    # 订阅内容
    sub_contents=""
    
    log "获取订阅地址:"
    
    # 遍历订阅地址
    for i in ${!SUB_URL[@]}
    do
        log "${SUB_URL[$i]}"
        # 订阅编号
        index=`expr $i + 1`
        # 订阅名称
        sub_names+="空格空格空格空格- provider$index"
        if [ $index -lt ${#SUB_URL[@]} ]; then
            sub_names+="\n"
        fi
        # 订阅内容
        sub_contents+="空格空格provider$index:\n"
        sub_contents+="空格空格空格空格<<: *p\n"
        sub_contents+="空格空格空格空格url: \"${SUB_URL[$i]}\"\n"
        sub_contents+="空格空格空格空格path: ./proxy_provider/provider$index.yaml\n"
        sub_contents+="空格空格空格空格override:\n"
        sub_contents+="空格空格空格空格空格空格additional-prefix: \"[订阅$index]\"\n"
    done
    
    log "添加订阅地址"
    
    # 在 proxy-providers 项，添加订阅内容
    line=$(cat $base_conf | sed -n -e "/proxy-providers:/=")
    line=`expr $line + 1`
    out_content=$(cat $base_conf | sed $line"c $sub_contents")    
    # 在 All: &All 项，添加订阅名称
    line=$(echo "$out_content" | sed -n -e "/All: &All/=")
    line=`expr $line + 3`
    out_content=$(echo "$out_content" | sed $line"i $sub_names")
    # 在 A: &A 项，添加订阅名称
    line=$(echo "$out_content" | sed -n -e "/A: &A/=")
    line=`expr $line + 2`
    out_content=$(echo "$out_content" | sed $line"i $sub_names")   
    # 输出配置
    echo "$out_content" | sed "s/空格/ /g" > $MIHOMO_CONF
    
    log "订阅配置修改成功"
}


# 根据 SmartDNS 状态，是否使用默认 DNS
smartdns_state(){
    out="$1"
    # SmartDNS
    line_number=$(echo "$out" | sed -n -e "/127.0.0.1:3721/=")
    for i in `echo $line_number`
    do
        out=$(echo "$out" | sed $i"s/$3/$2/")
    done
    # 阿里  
    line_number=$(echo "$out" | sed -n -e "/dns.alidns.com/=")
    for i in `echo $line_number`
    do
        out=$(echo "$out" | sed $i"s/$2/$3/")
    done
    # 腾讯  
    line_number=$(echo "$out" | sed -n -e "/dns.pub/=")
    for i in `echo $line_number`
    do
        out=$(echo "$out" | sed $i"s/$2/$3/")
    done
    echo "$out"
}

# 修改 DNS
dns(){    
    log "修改 DNS 配置"
    # 输出内容
    out_content=$(cat $MIHOMO_CONF)
    
    # 判断 SmartDNS 是否启用
    if [ $SMARTDNS_ENABLE = true ]; then
        log "SmartDNS 已启用"
        log "添加 SmartDNS 规则"  
        out_content=$(smartdns_state "$out_content" "-" "#-")
    else
        log "SmartDNS 已禁用"   
        log "使用默认 DNS 规则"    
        out_content=$(smartdns_state "$out_content" "#-" "-")
    fi
    
    # 写入配置
    echo "$out_content" > $MIHOMO_CONF
    
    log "DNS 配置修改成功"
}

# webui 显示状态
webui_status(){
    content="$1"
    state_number=$(pidof $2)       
    line_number=$(echo "$content" | sed -n -e "/$3/=")
    if [ $state_number ]; then
        content=$(echo "$content" | sed $line_number"s/stopped/running/" | sed $line_number"s/未/已/")
    else
        content=$(echo "$content" | sed $line_number"s/running/stopped/" | sed $line_number"s/已/未/")
    fi
    echo "$content"
}

# 修改 webui
webui(){
    # webui 文件路径
    html_file="$MODULE_PATH/webroot/index.html"    
    # 输出内容
    out_content=$(cat "$html_file")    
    
    # 获取 SmartDNS 状态
    out_content=$(webui_status "$out_content" "$SMARTDNS_BIN" "smartdns-status")
    
    # 获取 AdGuardHome 状态    
    out_content=$(webui_status "$out_content" "$AGH_BIN" "agh-status")
    
    # 获取 Mihomo 状态    
    out_content=$(webui_status "$out_content" "$MIHOMO_BIN" "mihomo-status")
    
    # 输出
    echo "$out_content" > $html_file
}

# 添加指令
case "$1" in
    # 配置
    config)
        # 修改 AdGuardHome DNS 端口
        dns_port
        # 修改 Mihomo TUN 网卡
        tun_device
        ;;
    # 描述
    desc)
        # 修改模块描述
        description
        webui
        ;;
    # 订阅
    sub)
        # 更新订阅
        sub
        ;;
    # DNS
    dns)
        # 修改 DNS
        dns
        ;;
    *)
        webui
        echo "使用: config(更新配置) | desc(更新描述) | dns(更新DNS规则)"
        exit 1
        ;;
esac
