# 模块根目录
root=$(pwd)

# 菜单
menu(){
    echo "请选择: 0(电源键) | 1(音量+) | 2(音量-)"
    echo "1. 启动服务/停止服务"
    echo "2. 更新服务"
    echo "0. 退出"
    
    # 获取选择
    select=$(get_key_volume)
    # 判断选择
    if [ ${select} == 24 ]; then
        start_and_stop
    elif  [ ${select} == 25 ]; then
        su -c "${root}/scripts/update.sh"
    fi
}

# 启动和停止
start_and_stop(){
    # 获取已启用服务数量
    service=$(su -c "${root}/scripts/webui.sh service")
    # 获取服务进程数量
    process=$(su -c "${root}/scripts/webui.sh process")
    # 判断数量相等，则停止，反之则运行
    if [ ${service} = ${process} ] || [ ${process} -ne 0 ]; then  
        su -c "${root}/scripts/service.sh stop"  
    else
        su -c "${root}/scripts/service.sh start"
    fi
}

# 获取当前所按音量键
get_key_volume(){
    getevent -l | while read -r line; do
        # 音量上
        echo "${line}" | grep -q "KEY_VOLUMEUP" && {
            echo 24
            return
        }
        # 音量下
        echo "${line}" | grep -q "KEY_VOLUMEDOWN" && {
            echo 25
            return
        }
        # 电源键
        echo "${line}" | grep -q "KEY_POWER" && {
            echo 26
            return
        }
    done
}

menu

sleep 1