import { fullScreen, exec, toast } from './kernelsu.js'

const module_path = "/data/adb/modules/SAM"
const scripts_path = "/data/adb/modules/SAM/scripts"

// 获取服务状态
function getServiceStatus(id, status) {
    const control = document.getElementById(id);    
    control.innerHTML = status;
    if ( status == "已运行" || status == "已挂载" ) {  
        control.classList.remove('status-inactive');
        control.classList.add('status-active');
    } else {
        control.classList.remove('status-active');
        control.classList.add('status-inactive');
    }
}

// 更新服务状态
async function updateServiceStatus() {    
    // SmartDNS 状态
    var smartdns_status = await exec(`su -c "${scripts_path}/webui.sh status smartdns"`);
    getServiceStatus("smartdns-status",smartdns_status.stdout);
        
    // AdGuardHome 状态
    var agh_status = await exec(`su -c "${scripts_path}/webui.sh status AdGuardHome"`);
    getServiceStatus("agh-status",agh_status.stdout);
           
    // Mihomo 状态
    var mihomo_status = await exec(`su -c "${scripts_path}/webui.sh status mihomo"`);
    getServiceStatus("mihomo-status",mihomo_status.stdout);
       
    // Host 状态
    var host_mount_status = await exec(`su -c "${scripts_path}/webui.sh mount"`);
    getServiceStatus("host-mount-status",host_mount_status.stdout);
    
    const host_mount_action = document.getElementById("host-mount-action");    
    if ( host_mount_status.stdout == "已挂载" ) {    
        host_mount_action.classList.add('disable');
        host_mount_action.textContent = "禁用";
    } else {
        host_mount_action.classList.remove('disable');
        host_mount_action.textContent = "启用";
    }
    
    updateMonitorStatus("wifi","wifi-monitor-status","wifi-monitor-action","wifi-monitor-pid");
    updateMonitorStatus("host","host-monitor-status","host-monitor-action","host-monitor-pid");
    updateMonitorStatus("module","module-monitor-status","module-monitor-action","module-monitor-pid");
    
   updateServiceStatus();
}

// 更新监控状态
async function updateMonitorStatus(value, status, action, showPid) {
    var monitor = await exec(`su -c "${scripts_path}/webui.sh monitor ${value}"`);    
    const monitor_status = document.getElementById(status);
    const monitor_action = document.getElementById(action);
    if ( monitor.stdout == "已运行" ) {
        var pid = await exec(`su -c "${scripts_path}/webui.sh pid ${value}"`);
        document.getElementById(showPid).innerHTML = "PID: " + pid.stdout + ( value == "module" ? " | 监听模块开关，模块启用则运行程序，模块禁用则停止程序" : value == "wifi" ? " | 监听已连接WIFI，监听到WIFI在黑名单内则停止服务，反之则启动" : " | 监听 hosts 文件，修改文件实时生效" );
        monitor_status.innerHTML = "已运行";
        monitor_status.classList.remove('status-inactive');
        monitor_status.classList.add('status-active')
        monitor_action.classList.add('disable');
        monitor_action.textContent = "禁用";
    } else {  
        document.getElementById(showPid).innerHTML = "PID: null" + ( value == "module" ? " | 监听模块开关，模块启用则运行程序，模块禁用则停止程序" : value == "wifi" ? " | 监听已连接WIFI，监听到WIFI在黑名单内则停止服务，反之则启动。若没有在设置文件添加黑名单，则无法启动监听" : " | 监听 hosts 文件，修改文件实时生效" );      
        monitor_status.innerHTML = "未运行";
        monitor_status.classList.remove('status-active');
        monitor_status.classList.add('status-inactive');
        monitor_action.classList.remove('disable');
        monitor_action.textContent = "启用";
    }
}


// 页面导航功能
function pageNavigation() {
    const navItems = document.querySelectorAll('.nav-item');
    const pages = document.querySelectorAll('.page');
    
    navItems.forEach(item => {
        item.addEventListener('click', function() {
            const targetPageId = this.getAttribute('data-page');
            
            // 更新导航状态
            navItems.forEach(nav => nav.classList.remove('active'));
            this.classList.add('active');
            
            // 更新页面显示
            pages.forEach(page => {
                page.classList.remove('active');
                if (page.id === targetPageId) {
                    page.classList.add('active');
                }
            });
        });
    });
}

// 服务控制功能
async function serviceControls(text, cmd) {
    toast(`正在${text}，请稍等......`);
    exec(`su -c "${scripts_path}/service.sh ${cmd}"`)
    updateServiceStatus();
    var outNumber = await exec(`su -c "${scripts_path}/webui.sh process"`);
    var serNumber = await exec(`su -c "${scripts_path}/webui.sh service"`);
    if ( outNumber.stdout < serNumber.stdout && ( cmd == "start" || cmd == "restart" )) {
        showToast(text+"失败");
    } else if ( outNumber.stdout == serNumber.stdout && ( cmd == "start" || cmd == "restart" )) {
        showToast(text+"成功");
    } else if ( outNumber.stdout > 0 && cmd == "stop" ) {
        showToast(text+"失败");
    } else if ( outNumber.stdout == 0 && cmd == "stop" ) {
        showToast(text+"成功");
    }
}

// 挂载控制
async function mountControls(){
    const hostMountStatus = document.getElementById("host-mount-status");
    var host_mount_status = await exec(`su -c "${scripts_path}/webui.sh mount"`);
    if ( host_mount_status.stdout == "已挂载" ) {
        // 切换到禁用
        hostMountStatus.classList.remove('status-active');
        hostMountStatus.classList.add('status-inactive');
        exec('su -c "umount /system/etc/hosts"');
        showToast(`Host 未挂载`);
    } else {
        // 切换到启用
        hostMountStatus.classList.remove('status-inactive');
        hostMountStatus.classList.add('status-active');
        exec(`su -c "mount ${module_path}/etc/hosts /system/etc/hosts"`);
        showToast(`Host 已挂载`);
    }
    updateServiceStatus();
}

// 监控控制
async function monitorControls(text) {
    var pid_status = await exec(`su -c "${scripts_path}/webui.sh monitor ${text}"`);
    if ( pid_status.stdout == "已运行" ) {
        exec(`su -c "${scripts_path}/webui.sh kill ${text}"`);
        showToast(text == "module" ? "模块未监控" : text == "wifi" ? "WIFI未监控" : "host未监控");
    } else {
        exec(`su -c "${scripts_path}/webui.sh start ${text}"`);
        showToast(text == "module" ? "模块已监控" : text == "wifi" ? "WIFI已监控" : "host已监控");
    }
    updateServiceStatus();
}

(async () => {
    // 全屏    
    fullScreen(true);
    
    // 消息提示功能
    const toast = document.getElementById('toast');
    window.showToast = function(message) {
        toast.textContent = message;
        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 2000);
    };
    
    // 更新服务状态
    updateServiceStatus();
    
    // 更新监控状态
    updateMonitorStatus();
    
    // 页面导航
    pageNavigation();
    
    // 启动点击事件
    const startBtn = document.querySelector('.start-service');
    startBtn.addEventListener('click', () => {
        serviceControls("启动","start");
    });
    
    // 停止点击事件
    const stopBtn = document.querySelector('.stop-service');
    stopBtn.addEventListener('click', () => {
        serviceControls("停止","stop");
    });
    
    // 重启点击事件
    const restartBtn = document.querySelector('.restart-service');
    restartBtn.addEventListener('click', () => {      
        serviceControls("重启","restart");
    });
    
    // host 挂载按钮点击事件
    const hostMountAction = document.getElementById("host-mount-action");
    hostMountAction.addEventListener('click', () => {
        mountControls();
    });
    
    // 模块目录监控点击事件
    const module_monitor_action = document.getElementById("module-monitor-action");
    module_monitor_action.addEventListener('click', () => {
        monitorControls("module");
    });
     
    // hosts文件监控点击事件   
    const host_monitor_action = document.getElementById("host-monitor-action");
    host_monitor_action.addEventListener('click', () => {
        monitorControls("host");
    });
    
    // wifi监控点击事件   
    const wifi_monitor_action = document.getElementById("wifi-monitor-action");
    wifi_monitor_action.addEventListener('click', () => {
        monitorControls("wifi");
    });
    
})().catch((err) => 'null')