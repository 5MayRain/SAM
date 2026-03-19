# 2026.03.18_fix
1. 添加用户自定义直连配置文件 `classical_user_direct.liat`
2. 使用白名单模式，部分 app 无网络，那是因为该域名不在直连规则内，导致使用国外的DNS解析。需要手动将该域名添加至 `classical_user_direct.liat` 文件，则恢复使用国内的DNA解析。