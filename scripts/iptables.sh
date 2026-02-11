# 加载基础脚本
. /data/adb/modules/SAM/scripts/base.sh

iptables_w="iptables -w 100"
ip6tables_w="ip6tables -w 100"

# AdGuardHome 链
agh_chain="ADGUARD_REDIRECT_DNS"
agh_chain_v6="ADGUARD_BLOCK_DNS"

# 拦截 ip 列表
REJECT_IP_LIST="
#囧次元
116.205.193.167
#反诈中心
49.7.228.53
14.29.101.168
14.29.101.160
14.29.101.169
116.177.251.215
218.77.192.51
111.20.26.186
112.84.130.73
61.243.26.3
116.142.251.100
111.51.90.173
183.236.60.105
101.206.203.174
117.31.116.57
180.163.200.99
106.227.26.33
117.185.20.168
101.69.129.138
39.175.224.40
219.152.87.101
59.49.8.24
223.109.224.43
123.151.98.175
125.74.134.73
182.242.56.70
58.49.156.81
36.158.196.25
111.7.90.97
183.204.227.3
113.137.43.167
218.77.192.52
118.213.92.50
106.41.206.93
171.105.185.55
111.7.93.60
125.39.177.94
122.189.237.9
61.243.26.6
116.177.251.217
60.223.222.162
111.10.52.133
116.162.201.81
116.177.251.216
36.147.40.195
113.125.253.37
221.15.69.47
36.147.27.2
36.249.80.86
123.159.206.44
42.248.133.67
111.48.28.46
113.62.113.46
117.161.138.96
183.201.224.91
111.31.73.182
111.44.252.226
112.240.59.154
153.101.175.200
157.255.34.28
112.48.168.3
1.58.38.6
27.221.54.107
61.135.15.244
183.136.140.25
221.15.69.48
121.228.190.70
42.101.23.53
218.60.173.133
111.44.252.225
111.44.252.227
111.40.177.172
180.163.200.98
106.227.26.32
101.69.129.241
113.24.209.160
125.74.134.74
27.18.12.6
113.249.87.131
111.20.26.185
113.140.36.110
182.242.56.150
106.41.206.92
118.213.92.48
111.10.52.131
116.162.201.82
123.159.206.46
61.243.26.5
113.125.253.40
112.240.59.155
113.62.113.44
111.48.63.25
111.51.90.174
112.17.17.42
1.180.31.27
157.255.34.2
111.29.43.91
36.99.183.88
218.60.173.130
182.40.45.81
36.110.220.114
101.206.203.173
118.123.20.64
111.62.158.220
223.242.37.43
111.26.56.89
124.236.19.61
112.29.213.66
36.131.159.224
60.9.4.220
124.232.180.181
222.75.4.141
58.217.200.222
210.22.248.223
223.111.138.3
36.99.23.32
121.228.190.68
111.26.56.86
117.31.116.58
223.109.62.200
116.142.251.101
110.156.168.131
117.31.116.59
112.17.17.79
36.99.23.31
111.40.177.173
118.123.208.152
124.236.19.60
1.180.22.180
111.62.158.195
111.29.43.90
140.249.153.85
111.40.177.171
60.9.4.195
36.110.220.111
120.201.235.30
124.232.139.148
222.75.36.76
117.31.116.56
121.228.190.71
210.22.248.224
110.156.168.146
223.109.62.202
#国家平台
125.124.253.96
183.214.10.166
125.124.253.95
223.247.113.70
171.105.187.88
223.247.113.71
223.109.62.223
27.128.213.69
111.63.181.104
27.128.213.68
111.7.72.254
183.214.10.165
223.109.62.222
222.75.36.98
36.110.220.144
180.105.72.174
125.77.181.205
36.112.20.111
219.144.24.93
58.63.255.244
27.18.12.94
171.105.187.89
218.77.192.67
122.228.102.60
42.185.159.95
27.18.12.93
222.75.36.97
111.7.93.70
36.110.220.145
124.232.139.238
58.216.30.215
117.31.118.45
58.63.255.243
117.31.118.44
110.156.169.155
42.248.133.83
42.185.159.96
111.62.149.141
112.84.222.66
59.110.245.79
36.158.231.188
124.238.251.162
119.39.205.15
122.228.102.59
211.103.220.221
203.34.106.144
202.127.0.105
127.0.0.2
42.202.155.142
116.211.128.111
59.63.226.15
180.105.72.173
124.225.91.29
111.7.93.69
42.248.133.84
125.77.181.206
124.232.160.126
110.156.169.153
124.232.160.125
111.7.93.68
#备案域名
112.84.222.56
111.62.149.129
119.39.205.85
27.155.113.108
124.238.251.188
116.211.128.178
36.158.231.210
112.45.27.156
42.202.155.215
59.63.226.86
#偷文件
120.76.141.58
"

# 拦截 ip
reject_ip_iptables(){
    # 循环打印ip列表
    for i in $REJECT_IP_LIST
    do
        # 获取ip
        ip=$(echo $i | grep -Eo '([0-9]{1,3}\.){1,3}[0-9]{1,3}')
        # 判断不为空则执行
        if [ $ip ]; then
            $iptables_w $1 OUTPUT -d "$ip" -j DROP >/dev/null 2>&1
        fi
    done
}

# 启用 AdGuardHome iptables
agh_enable_iptables(){
    # 判断存在则退出
    if $iptables_w -t nat -L $agh_chain >/dev/null 2>&1; then
        log "$agh_chain 链已经存在"
        return
    fi
    log "创建 $agh_chain 链并添加规则"    
    $iptables_w -t nat -N $agh_chain    
    $iptables_w -t nat -A $agh_chain -m owner --uid-owner $AGH_USER --gid-owner $AGH_GROUP -j RETURN
    $iptables_w -t nat -A $agh_chain -p udp --dport 53 -j REDIRECT --to-ports $AGH_DNS_PORT
    $iptables_w -t nat -A $agh_chain -p tcp --dport 53 -j REDIRECT --to-ports $AGH_DNS_PORT
    $iptables_w -t nat -I OUTPUT -j $agh_chain
}

# 启用阻断 ipv6 的 DNS 请求
agh_enable_ip6tables(){
    # 判断存在则退出
    if $ip6tables_w -t filter -L $agh_chain_v6 >/dev/null 2>&1; then
        log "$agh_chain_v6 链已经存在"
        return
    fi
    log "创建 $agh_chain_v6 链并添加规则"
    $ip6tables_w -t filter -N $agh_chain_v6
    $ip6tables_w -t filter -A $agh_chain_v6 -p udp --dport 53 -j DROP
    $ip6tables_w -t filter -A $agh_chain_v6 -p tcp --dport 53 -j DROP
    $ip6tables_w -t filter -I OUTPUT -j $agh_chain_v6
}

# 禁用 AdGuardHome iptables
agh_disable_iptables(){
    # 判断不存在则退出
    if ! $iptables_w -t nat -L $agh_chain >/dev/null 2>&1; then
        log "$agh_chain 链不存在"
        return
    fi
    log "删除 $agh_chain 链及规则"
    $iptables_w -t nat -D OUTPUT -j $agh_chain
    $iptables_w -t nat -F $agh_chain
    $iptables_w -t nat -X $agh_chain
}

# 禁用阻断 ipv6 的 DNS 请求
agh_disable_ip6tables(){
    if ! $ip6tables_w -t filter -L $agh_chain_v6 >/dev/null 2>&1; then
        log "$agh_chain_v6 链不存在"
        return
    fi
    log "删除 $agh_chain_v6 链及规则"
    $ip6tables_w -t filter -F $agh_chain_v6
    $ip6tables_w -t filter -D OUTPUT -j $agh_chain_v6
    $ip6tables_w -t filter -X $agh_chain_v6
}

# Mihomo iptables
mihomo_iptables(){
    # 允许 Tun 流量转发
    $iptables_w $1 FORWARD -o $TUN_DEVICE -j ACCEPT
    $iptables_w $1 FORWARD -i $TUN_DEVICE -j ACCEPT
    $ip6tables_w $1 FORWARD -o $TUN_DEVICE -j ACCEPT
    $ip6tables_w $1 FORWARD -i $TUN_DEVICE -j ACCEPT
      
    # 判断 AdGuardHome 未启用，则转发至 Mihomo 的 DNS 端口
    if [ "$AGH_ENABLE" = false ]; then
        $iptables_w -t nat $2 OUTPUT -p udp --dport 53 -j REDIRECT --to-ports $MIHOMO_DNS_PORT
        $iptables_w -t nat $2 OUTPUT -p tcp --dport 53 -j REDIRECT --to-ports $MIHOMO_DNS_PORT
    fi
}

# 添加指令
case "$1" in
    # 启用
    -e)
        case "$2" in
            # AdGuardHome
            agh)
                agh_enable_iptables
                [ "$BLOCK_IPV6_DNS" = true ] && agh_enable_ip6tables || exit 1
                ;;
            # Mihomo
            mihomo)  
                log "添加 Mihomo iptables 规则"
                mihomo_iptables "-I" "-A"
                ;;
            # ip
            ip)
                log "使用 iptables 拦截 ip"
                reject_ip_iptables "-A"
                ;;
            *)
                echo "使用: -e ( agh | mihomo | ip )"
                exit 1
                ;;
        esac
        ;;
    # 禁用
    -d)
        case "$2" in
            # AdGuardHome
            agh)
                agh_disable_iptables
                agh_disable_ip6tables
                ;;
            # Mihomo
            mihomo)
                log "删除 Mihomo iptables 规则"
                mihomo_iptables "-D" "-D"
                ;;
            # ip
            ip)
                log "禁用 iptables 拦截 ip"
                reject_ip_iptables "-D"
                ;;
            *)
                echo "使用: -d ( agh | mihomo | ip )"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "使用: -e(启用) | -d(禁用)"
        exit 1
        ;;
esac