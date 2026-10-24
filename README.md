# solocorp — 发行包仓库

> AI multi-agent Company-as-a-Service — 10-agent autonomous runtime, MCP skills, LLM routing, FastAPI + React WebUI.
> 源码仓库私有，本仓库只发布可安装的 wheel 发行包。

## 安装（Python ≥ 3.11）

```bash
pip install https://github.com/abdrsl/solocorp-dist/releases/download/v1.0.0/solocorp-1.0.0-py3-none-any.whl
```

## 初始化与启动

```bash
solocorp onboard    # 引导式初始化（主密钥 / 首家公司 / 健康探活）
solocorp start      # 启动服务，默认 127.0.0.1:8000
```

## 验证

```bash
solocorp version
curl http://127.0.0.1:8000/api/v1/health/readyz
```

## 说明

- wheel 内含 WebUI 前端构建产物与 DB 迁移脚本，装完即用，无需 pnpm / git
- 生产部署建议 PostgreSQL（`SOLOCORP_DATABASE_URL`）；单机试用可 `SOLOCORP_ALLOW_SQLITE_FALLBACK=1`
- License: Apache-2.0
