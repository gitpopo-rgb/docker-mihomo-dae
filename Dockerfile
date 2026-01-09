FROM ghcr.io/vernesong/mihomo:alpha as mihomo

FROM daeuniverse/dae:latest as dae

FROM alpine:latest

# 安装必要的运行时依赖和工具
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    supervisor \
    iptables \
    iproute2 \
    curl \
    && rm -rf /var/cache/apk/*

# 从mihomo镜像复制二进制文件
COPY --from=mihomo /mihomo /usr/local/bin/mihomo

# 从dae镜像复制二进制文件和配置
COPY --from=dae /usr/local/bin/dae /usr/local/bin/dae

# 创建必要的目录
RUN mkdir -p /root/.config/mihomo /root/.config/dae /var/log/supervisor /var/run

# 设置权限
RUN chmod +x /usr/local/bin/mihomo /usr/local/bin/dae

# 复制配置文件
COPY config/mihomo-config.yaml /root/.config/mihomo/config.yaml
COPY config/dae-config.dae /root/.config/dae/config.dae
COPY config/supervisord.conf /etc/supervisord.conf

# 创建启动脚本
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 暴露端口
# Mihomo ports
EXPOSE 7890 7891 9090
# Dae ports (根据配置调整)
EXPOSE 12345

# 设置工作目录
WORKDIR /root

# 使用supervisor管理多个进程
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
