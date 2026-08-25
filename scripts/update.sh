# 加载基础脚本
source "/data/adb/modules/SAM/scripts/base.sh"

# 下载地址
download_url=""
# 保存文件
save_file=""
# 是否已更新
is_update=false

# SmartDNS 版本
smartdns_ver=$(cd ${SMARTDNS_PATH} && SMARTDNS_WORKDIR="${SMARTDNS_PATH}" exec ${SMARTDNS_BIN} -v | sed -n 's/^.*[[:space:]]\(.*\)[[:space:]].*/\1/p')
# AdGuardHome 版本
agh_ver=$(${AGH_BIN} --version | sed -n 's/^.*version[[:space:]]\(.*\)$/\1/p')
# Mihomo 版本
mihomo_ver=$(${MIHOMO_BIN} -v | sed -n "s/^.*Meta[[:space:]]\(.*\)[[:space:]]android.*$/\1/p")

# 获取下载地址
get_download_url(){
    # API 地址
    api_url="https://api.github.com/repos/${1}/releases"
    # API 内容
    api_content=$(curl -m 10 -s ${api_url})
    
    # 获取下载地址
    download_url=$(echo "${api_content}" | grep "browser_download_url" | grep -E "${2}")
    if [ ${3} = 1 ]; then
        download_url=$(echo "${download_url}" | grep -Ev "Prerelease-Alpha|-b|nightly")
    fi
    download_url=$(echo "${download_url}" | sed -n "1p" | sed -n "s/^.*:[[:space:]]\"\(.*\)\"$/\1/p")
    
    # 检查
    echo ${download_url} | grep -q ${4} && {
        log "i" "已是最新版本"
        return 1
    }
    if [ -n "${download_url}" ]; then
        log "i" "获取下载地址 > ${download_url}"
        return 0
    else
        log "e" "未成功获取下载地址"
        return 1
    fi
}

# 下载文件
download_file(){
    save_file="${TMP_PATH}/$(echo ${download_url} | sed 's/^.*\///g')"
    curl -# -L -o ${save_file} ${download_url} && return 0 || return 1
}

# 替换文件
replace_file(){
    log "i" "替换文件: ${1} > ${2}"
    cp -R -f -p "${1}" "${2}"
}

# SmartDNS 下载
smartdns_download(){
    log "i" "更新 SmartDNS"
    get_download_url "pymumu/smartdns" "aarch64-linux-all" 1 ${smartdns_ver} || return 1
    log "i" "开始下载，请稍等..."
    download_file || {
        return 1
        log "e" "下载失败"
    }
    log "i" "解压缩 > ${save_file}"
    tar -zxvf ${save_file} -C ${TMP_PATH} && rm -rf ${save_file}
    # 删除软连接
    rm -rf "${TMP_PATH}/${SMARTDNS_BIN}/usr/local/lib/smartdns/lib/ld-linux.so"
    rm -rf "${TMP_PATH}/${SMARTDNS_BIN}/usr/local/lib/smartdns/lib/ld-musl-aarch64.so.1"
    # 替换文件
    replace_file "${TMP_PATH}/${SMARTDNS_BIN}/usr/share/smartdns/wwwroot" "${SMARTDNS_PATH}"
    replace_file "${TMP_PATH}/${SMARTDNS_BIN}/usr/local/lib/smartdns/smartdns_ui.so" "${SMARTDNS_PATH}/smartdns_ui.so"
    replace_file "${TMP_PATH}/${SMARTDNS_BIN}/usr/local/lib/smartdns/smartdns" "${SMARTDNS_PATH}/smartdns"
    replace_file "${TMP_PATH}/${SMARTDNS_BIN}/usr/local/lib/smartdns/lib" "${SMARTDNS_PATH}"    
    log "i" "修改权限"
    chmod 755 "${SMARTDNS_PATH}/${SMARTDNS_BIN}"
    chmod 755 "${SMARTDNS_PATH}/smartdns_ui.so"
    chmod -R 755 "${SMARTDNS_PATH}/lib"
    chown "${SAM_USER}:${DNS_GROUP}" "${SMARTDNS_PATH}/${SMARTDNS_BIN}"
    chown root:root "${SMARTDNS_PATH}/smartdns_ui.so"
    chown -R root:root "${SMARTDNS_PATH}/lib"
    log "i" "删除下载文件"
    rm -rf "${TMP_PATH}/${SMARTDNS_BIN}"
    is_update=true
}

# AdGuardHome 下载
agh_download(){
    log "i" "更新 AdGuardHome"
    get_download_url "AdguardTeam/AdGuardHome" "linux_arm64" 1 ${agh_ver} || return 1
    log "i" "开始下载，请稍等..."
    download_file || {
        return 1
        log "e" "下载失败"
    }
    log "i" "解压缩 > ${save_file}"
    tar -zxvf ${save_file} -C ${TMP_PATH} && rm -rf ${save_file}
    # 替换文件
    replace_file "${TMP_PATH}/${AGH_BIN}/${AGH_BIN}" "${BIN_PATH}/${AGH_BIN}"
    log "i" "修改权限"
    chmod 755 "${BIN_PATH}/${AGH_BIN}"
    chown "${SAM_USER}:${DNS_GROUP}" "${BIN_PATH}/${AGH_BIN}"
    log "i" "删除下载文件"
    rm -rf "${TMP_PATH}/${AGH_BIN}"
    is_update=true
}

# Mihomo 下载
mihomo_download(){
    log "i" "更新 Mihomo "
    # 检查内核
    ${MIHOMO_BIN} -v | grep -q "smart" && {
        log "i" "获取 Smart 内核"
        get_download_url "vernesong/mihomo" "android-arm64.*$(echo ${mihomo_ver} | sed -n 's/^\(.*-.*\)-.*$/\1/p')" 0 ${mihomo_ver} || return 1
    } || {
        log "i" "获取标准内核"
        get_download_url "MetaCubeX/mihomo" "android-arm64.*" 1 ${mihomo_ver} || return 1
    }
    log "i" "开始下载，请稍等..."
    download_file || {
        return 1
        log "e" "下载失败"
    }
    log "i" "解压缩 > ${save_file}"
    gzip -d ${save_file}
    log "i" "重命名: $(echo ${save_file} | sed 's/\..*$//g') > ${TMP_PATH}/${MIHOMO_BIN}"
    mv $(echo ${save_file} | sed 's/\..*$//g') "${TMP_PATH}/${MIHOMO_BIN}"
    # 替换文件
    replace_file "${TMP_PATH}/${MIHOMO_BIN}" "${BIN_PATH}/${MIHOMO_BIN}"
    log "i" "修改权限"
    chmod 755 "${BIN_PATH}/${MIHOMO_BIN}"
    chown "${SAM_USER}:${TUN_GROUP}" "${BIN_PATH}/${MIHOMO_BIN}"
    log "i" "删除下载文件"
    rm -rf "${TMP_PATH}/${MIHOMO_BIN}"
    is_update=true
}

log "i" "update >>>"
mihomo_download
agh_download
smartdns_download
log "i" "<<< update"

# 判断已更新则重启服务
if [ ${is_update} = true ]; then
    ${SCRIPTS_PATH}/service.sh restart
fi