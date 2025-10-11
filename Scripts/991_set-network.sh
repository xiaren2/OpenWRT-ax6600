#!/bin/bash
# 在构建阶段修改 package/base-files/files/etc/config/network 文件，为系统设置固定或随机 ULA

NETWORK_FILE="package/base-files/files/etc/config/network"

if [ ! -f "$NETWORK_FILE" ]; then
    echo "Error: $NETWORK_FILE not found!"
    exit 1
fi

# 检查是否已有 ula_prefix
if grep -q "option ula_prefix" "$NETWORK_FILE"; then
    echo "ULA prefix already exists, skipping..."
    exit 0
fi

# 生成随机 ULA（fd00::/8）
random_hex=$(hexdump -n 5 -e '1/1 "fd%02x:"' /dev/urandom 2>/dev/null | sed 's/:$//')
ula_prefix="${random_hex}::/48"

# 插入到 globals 段
sed -i "/config globals 'globals'/,/^$/{
    /option ula_prefix/d
    a\        option ula_prefix '${ula_prefix}'
}" "$NETWORK_FILE"

echo "✅ Added ULA prefix: ${ula_prefix} to $NETWORK_FILE"
