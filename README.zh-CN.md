# Docker Mihomo + dae 集成代理镜像

[![Build and Push Docker Image](https://github.com/gitpopo-rgb/docker-mihomo-dae/actions/workflows/build.yml/badge.svg)](https://github.com/gitpopo-rgb/docker-mihomo-dae/actions/workflows/build.yml)

一个集成了 [mihomo](https://github.com/vernesong/mihomo) 和 [dae](https://github.com/daeuniverse/dae) 的 Docker 镜像，提供高性能的透明代理解决方案。

## 特性

- ✅ **mihomo (Clash Meta)**：强大的代理内核，支持多种协议
- ✅ **dae**：基于 eBPF 的高性能透明代理
- ✅ **自动构建**：通过 GitHub Actions 自动构建最新版本
- ✅ **多架构支持**：支持 amd64 和 arm64 架构
- ✅ **进程管理**：使用 supervisord 管理多个服务
- ✅ **灵活配置**：支持自定义配置文件

## 版本信息

- **mihomo 版本**: v1.19.9
- **dae 版本**: latest (v1.0.0)
- **基础镜像**: Alpine Linux

## 快速开始

### 使用 Docker

```bash
docker run -d \\
  --name mihomo-dae \\
  --privileged \\
  --network host \\
  -v /path/to/your/mihomo-config.yaml:/etc/mihomo/config.yaml \\
  -v /path/to/your/dae-config.dae:/etc/dae/config.dae \\
  ghcr.io/gitpopo-rgb/docker-mihomo-dae:latest
```

### 使用 Docker Compose

创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  mihomo-dae:
    image: ghcr.io/gitpopo-rgb/docker-mihomo-dae:latest
    container_name: mihomo-dae
    privileged: true
    network_mode: host
    restart: unless-stopped
    volumes:
      - ./config/mihomo-config.yaml:/etc/mihomo/config.yaml
      - ./config/dae-config.dae:/etc/dae/config.dae
      - ./logs:/var/log/supervisor
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
```

启动服务：

```bash
docker-compose up -d
```

## 配置说明

### Mihomo 配置

Mihomo 配置文件位于 `/etc/mihomo/config.yaml`。请参考 [示例配置](config/mihomo-config.yaml)。

主要配置项：
- `port`: HTTP 代理端口（默认：7890）
- `socks-port`: SOCKS5 代理端口（默认：7891）
- `external-controller`: Web UI 端口（默认：9090）
- `dns`: DNS 配置
- `proxies`: 代理节点配置
- `proxy-groups`: 代理组配置
- `rules`: 路由规则

### dae 配置

dae 配置文件位于 `/etc/dae/config.dae`。请参考 [示例配置](config/dae-config.dae)。

主要配置项：
- `tproxy_port`: 透明代理端口（默认：12345）
- `lan_interface`: LAN 接口
- `wan_interface`: WAN 接口
- `dns`: DNS 配置
- `routing`: 路由规则

## 端口说明

| 服务 | 端口 | 协议 | 说明 |
|------|------|------|------|
| Mihomo | 7890 | HTTP | HTTP 代理 |
| Mihomo | 7891 | SOCKS5 | SOCKS5 代理 |
| Mihomo | 9090 | HTTP | Web 控制面板 |
| Mihomo | 53 | DNS | DNS 服务 |
| dae | 12345 | TProxy | 透明代理 |

## 工作原理

1. **mihomo** 作为代理后端，负责处理各种代理协议（Shadowsocks、VMess、Trojan 等）
2. **dae** 使用 eBPF 技术在内核层面拦截流量，实现透明代理
3. 两者协同工作：dae 负责流量拦截和分流，mihomo 负责实际的代理连接
4. **supervisord** 管理两个进程的生命周期，确保服务稳定运行

## 系统要求

### 内核要求

dae 需要 Linux 内核版本 >= 5.17，并启用以下内核配置：

```
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_CGROUPS=y
CONFIG_KPROBES=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y
CONFIG_NET_SCH_INGRESS=m
CONFIG_NET_CLS_BPF=m
CONFIG_NET_CLS_ACT=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_BTF=y
CONFIG_KPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y
```

### Docker 权限

容器需要以下权限：
- `--privileged` 或 `--cap-add=NET_ADMIN --cap-add=SYS_ADMIN`
- `--network host` 或适当的网络配置

## 高级用法

### 查看日志

```bash
# 查看所有日志
docker logs mihomo-dae

# 查看 mihomo 日志
docker exec mihomo-dae tail -f /var/log/supervisor/mihomo.out.log

# 查看 dae 日志
docker exec mihomo-dae tail -f /var/log/supervisor/dae.out.log
```

### 重启服务

```bash
# 重启容器
docker restart mihomo-dae

# 重启 mihomo 服务
docker exec mihomo-dae supervisorctl restart mihomo

# 重启 dae 服务
docker exec mihomo-dae supervisorctl restart dae
```

### 检查服务状态

```bash
docker exec mihomo-dae supervisorctl status
```

## 构建镜像

如需自行构建镜像：

```bash
# 克隆仓库
git clone https://github.com/gitpopo-rgb/docker-mihomo-dae.git
cd docker-mihomo-dae

# 构建镜像
docker build -t mihomo-dae:custom .

# 或使用 docker-compose 构建
docker-compose build
```

## 故障排除

### dae 启动失败

1. 检查内核版本和配置：
```bash
uname -r
zcat /proc/config.gz | grep -E 'CONFIG_(BPF|KPROBES)'
```

2. 确保容器有足够的权限：
```bash
docker run --privileged ...
```

### 无法访问网络

1. 检查防火墙规则
2. 确认配置文件正确
3. 查看服务日志定位问题

### 性能问题

1. 考虑禁用不必要的功能
2. 优化代理节点配置
3. 调整 dae 的检查间隔

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目基于以下开源项目：
- [mihomo](https://github.com/vernesong/mihomo) - GPLv3
- [dae](https://github.com/daeuniverse/dae) - AGPL-3.0

## 相关链接

- [mihomo 文档](https://wiki.metacubex.one/)
- [dae 文档](https://github.com/daeuniverse/dae/tree/main/docs)
- [GitHub Container Registry](https://github.com/gitpopo-rgb/docker-mihomo-dae/pkgs/container/docker-mihomo-dae)

## 免责声明

本项目仅供学习和研究使用，请遵守当地法律法规。用户需对使用本软件产生的任何后果负责。
