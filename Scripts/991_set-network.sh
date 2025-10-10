#!/bin/sh

# 检查 network.globals.ula_prefix 是否存在且不为空
ula_prefix=$(uci get network.globals.ula_prefix 2>/dev/null)

if [ -z "$ula_prefix" ]; then
    # 尝试生成随机的 ULA 前缀（fd00::/8）
    random_ula_prefix=$(hexdump -n 5 -e '1/1 "fd%02x:"' /dev/urandom 2>/dev/null | sed 's/:$//')
    
    if [ -n "$random_ula_prefix" ]; then
        # 如果成功生成随机 ULA，则使用它（格式如 fdXX:XXXX:XXXX::/48）
        ula_prefix="${random_ula_prefix}::/48"
    else
        # 如果随机生成失败，则使用默认的 ULA 前缀
        ula_prefix="fd32:f54e:36f7::/48"
    fi

    # 设置 ULA 前缀
    uci set network.globals.ula_prefix="$ula_prefix"
    uci commit network
fi
