# SAM
SAM 是 SmartDNS、AdGuardHome 和 Mihomo 三合一的 Magisk 模块。每一个服务都可以单独使用，或者两两组合，或者全部启用。

## 📖说明
- SmartDNS 的优先级最低，在无启用其它服务的情况下，才会作为本机的 DNS 转发服务，在有两种和三种服务启用，只会作为上游 DNS。
- AdGuardHome 在单独启用和 SmartDNS 一起使用，都会作为本机的 DNS 转发服务，再和 Mihomo 三种一起用，就根据设置文件的配置，来选择使用哪种结构。
- Mihomo 在单独使用，或者和另一种服务使用，都会作为本机的 DNS 转发服务。 

## ⚙️功能
- 两种服务结构:
  - `SmartDNS > Mihomo > AdGuardHome`
  - `SmartDNS > AdGuardHome > Mihomo`
- 监听:
  - 模块:
    - 启用即运行，禁用即停止
    - 卸载备份配置，恢复拦截广告
  - hosts:
    - 修改实时生效
- 黑名单 WIFI 配置
- 黑白名单代理 App 配置
- 定时执行

## 📢注意
- 禁止和其它同类型模块使用
- 模块所有服务的账号和密码都是 `root`
- 禁止该文件随意修改
  - /data/adb/modules/SAM/etc/mihomo/base.yaml

##⚠️无网络
- 检查手机网络，开关飞行模式
- 排查 Mihomo 和 AdGuardHome 的拦截日志，手动添加规则放行

## 🤝使用项目
- [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo)
- [vernesong/mihomo](https://github.com/vernesong/mihomo)
- [AdguardTeam/AdGuardHome](https://github.com/AdguardTeam/AdGuardHome)
- [pymumu/smartdns](https://github.com/pymumu/smartdns)

## 🙏感谢
- [twoone-3/AdGuardHomeForRoot](https://github.com/twoone-3/AdGuardHomeForRoot)
- [GitMetaio/Surfing](https://github.com/GitMetaio/Surfing)
- Kisaratan