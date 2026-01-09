#!/bin/sh
set -e

echo "=========================================="
echo "Starting mihomo + dae integrated proxy"
echo "=========================================="

# 检查配置文件
if [ ! -f /root/.config/mihomo/config.yaml ]; then
    echo "Warning: Mihomo config not found at /root/.config/mihomo/config.yaml"
    echo "Using default configuration..."
fi

if [ ! -f /root/.config/dae/config.dae ]; then
    echo "Warning: dae config not found at /root/.config/dae/config.dae"
    echo "Using default configuration..."
fi

# 显示版本信息
echo "Mihomo version:"
/usr/local/bin/mihomo -v || echo "Failed to get mihomo version"

echo ""
echo "dae version:"
/usr/local/bin/dae version || echo "Failed to get dae version"

echo ""
echo "=========================================="
echo "Configuration loaded, starting services..."
echo "=========================================="

# 设置必要的内核参数（如果需要）
if [ -w /proc/sys/net/ipv4/ip_forward ]; then
    echo "Enabling IP forwarding..."
    echo 1 > /proc/sys/net/ipv4/ip_forward
fi

if [ -w /proc/sys/net/ipv6/conf/all/forwarding ]; then
    echo "Enabling IPv6 forwarding..."
    echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
fi

# 执行传入的命令
exec "$@"
