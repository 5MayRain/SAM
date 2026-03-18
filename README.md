# SAM
1. 这是 SmartDNS、Mihomo、AdGuardHome 三个结合的Magisk 模块
2. 模块结构为 SmartDNS > Mihomo > AdGuardHome
3. 模块启用了开关监听，启用模块则运行程序，禁用模块则停止程序
4. 设置文件路径: /data/adb/modules/SAM/setting.conf
5. 部分代码参考: twoone-3 的 [AdGuardHome for Root](https://github.com/twoone-3/AdGuardHomeForRoot/) 模块，GitMetaio 的 [Surfing](https://github.com/MoGuangYu/Surfing/
) 模块，和 Kisaratan 的 [HoshiTele](https://www.coolapk.com/feed/67830667) 模块

# 注意
1. 模块服务的账号和密码都是 root
2. AdGuardHome 禁止更新
3. /data/adb/modules/SAM/etc/mihomo/base.yaml 配置文件禁止随意修改或删除
4. /data/adb/modules/SAM/etc/hosts 文件修改实时生效

# 无网络
1. 排查有没有安装其它去广告的模块
2. 开关飞行模式
3. 把 Mihomo 的广告拦截改为直连，再排查 AdGuardHome 的拦截日志，把拦截的域名解除
4. 把 Mihomo 的漏网之鱼改为直连，或排查相关域名，手动添规则