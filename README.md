# SAM
1. 这是 SmartDNS、Mihomo、AdGuardHome 三个结合的Magisk 模块
2. 模块结构为 SmartDNS > Mihomo > AdGuardHome
3. 模块启用了开关监听，启用模块则运行程序，禁用模块则停止程序
4. 设置文件路径: /data/adb/modules/SAM/setting.conf
5. 部分代码参考: twoone-3 的 [AdGuardHome for Root](https://github.com/twoone-3/AdGuardHomeForRoot/) 模块，GitMetaio 的 [Surfing](https://github.com/MoGuangYu/Surfing/
) 模块，和 Kisaratan 的 [HoshiTele](https://www.coolapk.com/feed/67830667) 模块

# 注意
1. AdGuardHome 禁止更新
2. AdGuardHome 的账号和密码都是 root
3. /data/adb/modules/SAM/etc/mihomo/base.yaml 配置文件禁止随意修改或删除
4. /data/adb/modules/SAM/etc/hosts 文件修改实时生效

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