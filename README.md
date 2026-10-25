# solocorp — 发行包仓库

> AI multi-agent Company-as-a-Service — 10-agent autonomous runtime, MCP skills, LLM routing, FastAPI + React WebUI.
> 源码仓库私有，本仓库只发布可安装的 wheel 发行包与一键安装脚本。

## 一键安装（Python ≥ 3.11）

```bash
curl -fsSL https://raw.githubusercontent.com/abdrsl/solocorp-dist/main/install.sh | bash
```

脚本自动完成：独立 venv 创建（不碰系统 Python）→ 最新 Release wheel 下载安装 → `solocorp` 命令挂 PATH。
装完按提示 `solocorp onboard` 初始化、`solocorp start` 启动。

## 手动安装（任意 wheel 直链）

```bash
pip install https://github.com/abdrsl/solocorp-dist/releases/download/v1.0.1/solocorp-1.0.1-py3-none-any.whl
```

## 验证

```bash
solocorp version
curl http://127.0.0.1:8000/api/v1/health/readyz
```

## 说明

- wheel 内含 WebUI 前端构建产物与 DB 迁移脚本，装完即用，无需 pnpm / git
- 生产部署建议 PostgreSQL（`SOLOCORP_DATA_DIR` 下配置或环境变量）；单机试用默认本地 SQLite
- License: Apache-2.0
