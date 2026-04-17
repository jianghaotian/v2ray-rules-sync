#!/usr/bin/env bash

# sync-rules.sh
# 定时从 Loyalsoldier/v2ray-rules-dat 拉取 geoip.dat / geosite.dat，
# 用 v2dat 解包为 mosdns domain_set / ip_set 使用的三个 txt（与 config.yaml 默认路径一致）。
#
# 依赖: curl 或 wget、v2dat（https://github.com/urlesistiana/v2dat）
# 安装 v2dat: go install github.com/urlesistiana/v2dat@latest
#
# 下载与解包在 $RULES_DIR/.sync-work 内进行，成功后 install 到 $RULES_DIR
#
# crontab 示例（每天 4:15）:
#   15 4 * * * /opt/mosdns/sync-rules.sh >> /opt/mosdns/logs/sync-rules.log 2>&1

set -euo pipefail

GEOSITE_URL='https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat'
GEOIP_URL='https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat'
# 可通过环境变量覆盖（例如 CI 中设为仓库内目录）
RULES_DIR="${RULES_DIR:-/opt/mosdns/rules}"

log() { printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*"; }

need_cmd() {
	command -v "$1" >/dev/null 2>&1 || {
		log "ERROR: 未找到命令: $1"
		exit 1
	}
}

download() {
	local url="$1" out="$2"
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL --connect-timeout 30 --max-time 600 -o "$out" "$url"
	elif command -v wget >/dev/null 2>&1; then
		wget -q --timeout=30 --tries=3 -O "$out" "$url"
	else
		log "ERROR: 需要 curl 或 wget"
		exit 1
	fi
}

need_cmd v2dat

WORK="$RULES_DIR/.sync-work"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

mkdir -p "$RULES_DIR"
rm -rf "$WORK"
mkdir -p "$WORK"

log "下载 geosite.dat"
download "$GEOSITE_URL" "$WORK/geosite.dat"
log "下载 geoip.dat"
download "$GEOIP_URL" "$WORK/geoip.dat"

log "解包 geosite (cn)"
v2dat unpack geosite -o "$WORK" -f cn "$WORK/geosite.dat"
log "解包 geosite (geolocation-!cn)"
v2dat unpack geosite -o "$WORK" -f 'geolocation-!cn' "$WORK/geosite.dat"
log "解包 geoip (cn)"
v2dat unpack geoip -o "$WORK" -f cn "$WORK/geoip.dat"

for f in geosite_cn.txt geosite_geolocation-!cn.txt geoip_cn.txt; do
	[[ -s "$WORK/$f" ]] || {
		log "ERROR: 缺少或为空: $WORK/$f"
		exit 1
	}
done

install -m 0644 "$WORK/geosite_cn.txt" "$RULES_DIR/geosite_cn.txt"
install -m 0644 "$WORK/geosite_geolocation-!cn.txt" "$RULES_DIR/geosite_geolocation-!cn.txt"
install -m 0644 "$WORK/geoip_cn.txt" "$RULES_DIR/geoip_cn.txt"

log "已写入 $RULES_DIR/{geosite_cn,geosite_geolocation-!cn,geoip_cn}.txt"
