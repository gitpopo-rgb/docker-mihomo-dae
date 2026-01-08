#!/bin/bash
# 本地测试脚本

set -e

echo "========================================"
echo "开始构建 Docker 镜像..."
echo "========================================"

# 构建镜像
docker build -t mihomo-dae:test .

echo ""
echo "========================================"
echo "镜像构建成功！"
echo "========================================"

# 显示镜像信息
echo ""
echo "镜像信息："
docker images mihomo-dae:test

echo ""
echo "========================================"
echo "检查镜像内容..."
echo "========================================"

# 检查二进制文件
echo "检查 mihomo 二进制："
docker run --rm mihomo-dae:test /usr/local/bin/mihomo -v || true

echo ""
echo "检查 dae 二进制："
docker run --rm mihomo-dae:test /usr/local/bin/dae version || true

echo ""
echo "========================================"
echo "测试完成！"
echo "========================================"
echo ""
echo "运行容器："
echo "  docker run -d --name mihomo-dae-test --privileged --network host mihomo-dae:test"
echo ""
echo "查看日志："
echo "  docker logs -f mihomo-dae-test"
echo ""
echo "停止并删除："
echo "  docker stop mihomo-dae-test && docker rm mihomo-dae-test"
