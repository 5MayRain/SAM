# 模块根目录
root=$(pwd)
# 获取已启用服务数量
service=$(su -c "$root/scripts/webui.sh service")
# 获取服务进程数量
process=$(su -c "$root/scripts/webui.sh process")
# 判断数量相等，则停止，反之则运行
if [ $service = $process ] || [ $process -ne 0 ]; then  
    su -c "$root/scripts/service.sh stop"  
else
    su -c "$root/scripts/service.sh start"
fi
sleep 1