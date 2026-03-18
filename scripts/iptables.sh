# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# iptables 脚本
AGH_IPTABLES="${SCRIPTS_PATH}/iptables/${AGH_BIN}.sh"
MIHOMO_IPTABLES="${SCRIPTS_PATH}/iptables/${MIHOMO_BIN}.sh"
IP_IPTABLES="${SCRIPTS_PATH}/iptables/ip.sh"


# 添加指令
case "$1" in
    # 启用
    -e)
        case "$2" in
            # AdGuardHome
            agh)
                ${AGH_IPTABLES} "enable"
                ;;
            # Mihomo
            mihomo)  
                ${MIHOMO_IPTABLES} "add"
                ;;
            # ip
            ip)
                log "i" "使用 iptables 拦截 ip"
                ${IP_IPTABLES} "-A"
                ;;
            *)
                echo "使用: agh | mihomo | ip"
                exit 1
                ;;
        esac
        ;;
    # 禁用
    -d)
        case "$2" in
            # AdGuardHome
            agh)
                ${AGH_IPTABLES} "disable"
                ;;
            # Mihomo
            mihomo)
                ${MIHOMO_IPTABLES} "delete"
                ;;
            # ip
            ip)
                log "i" "禁用 iptables 拦截 ip"
                ${IP_IPTABLES} "-D"
                ;;
            *)
                echo "使用: agh | mihomo | ip"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "使用: -e(启用) | -d(禁用)"
        exit 1
        ;;
esac