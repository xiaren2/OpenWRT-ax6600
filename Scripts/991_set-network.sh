#!/bin/sh
# 强制为系统生成一个随机 ULA 前缀

# 检查现有配置
ula_prefix=$(uci get network.globals.ula_prefix 2>/dev/null)
if [ -n "$ula_prefix" ]; then
    exit 0
fi

# 若无 globals 段则添加
if ! uci get network.globals >/dev/null 2>&1; then
    uci set network.globals=globals
fi

# 生成随机前缀（fd00::/8）
random_hex=$(hexdump -n 5 -e '1/1 "fd%02x:"' /dev/urandom 2>/dev/null | sed 's/:$//')
ula_prefix="${random_hex}::/48"

uci set network.globals.ula_prefix="$ula_prefix"
uci commit network

# 日志输出（方便调试）
echo "Set ULA prefix to $ula_prefix" > /tmp/ula_log.txt
logger -t set-ula "Set ULA prefix to $ula_prefix"

# 可选：立即应用（非必要）
[ -x /etc/init.d/network ] && /etc/init.d/network restart

exit 0
