# SAM
1. 这是 SmartDNS、Mihomo、AdGuardHome 三个结合的Magisk 模块
2. 模块结构为 SmartDNS > Mihomo > AdGuardHome
3. 模块启用了开关监听，启用模块则运行程序，禁用模块则停止程序
4. 设置文件路径: /data/adb/modules/SAM/setting.conf
5. 部分代码参考: twoone-3 的 [AdGuardHome for Root](https://github.com/twoone-3/AdGuardHomeForRoot/) 模块，GitMetaio 的 [Surfing](https://github.com/MoGuangYu/Surfing/
) 模块，和 Kisaratan 的 [HoshiTele](https://www.coolapk.com/feed/67830667) 模块

# 注意
1. SmartDNS 的账号和密码都是 root
2. AdGuardHome 禁止更新
3. AdGuardHome 的账号和密码都是 root
4. /data/adb/modules/SAM/etc/mihomo/base.yaml 配置文件禁止随意修改或删除
5. /data/adb/modules/SAM/etc/hosts 文件修改实时生效

# 无网络
1. 排查有没有安装其它去广告的模块
2. 开关飞行模式
3. 把 Mihomo 的广告拦截改为直连，再排查 AdGuardHome 的拦截日志，把拦截的域名解除
4. 把 Mihomo 的漏网之鱼改为直连，或排查相关域名，手动添规则

## 2025.12.16
1. 修改 Mihomo 配置
2. 修改部分代码

## 2025.12.01
1. Mihomo 更新版本
2. 修复部分 BUG

## 2025.11.29
1. 屏蔽部分 App 广告文件

## 2025.11.28
1. 重写模块的 WebUI
2. 调整部分代码
3. 黑名单采用双配置，tun规则过滤和路由规则过滤
4. 黑名单路由规则可手动添加，不会被代码覆盖
5. 路径: /data/adb/modules/SAM/etc/mihomo/rule_provider/classical_blacklist_direct.list

## 2025.11.20
1. SmartDNS 更新版本
2. SmartDNS 添加 WebUI
3. 调整模块的 WebUI 代码
4. 修复用模块 WebUI 控制启动，导致手机没有网络

## 2025.11.19
1. 调整部分代码
2. 重写 WebUI
3. 修复 BUG

## 2025.11.18
1. 添加定时执行功能
2. 给模块添加 WebUI

## 2025.11.17
1. 重新调整模块架构
2. 添加 Host 规则