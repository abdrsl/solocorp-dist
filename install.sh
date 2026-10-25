#!/usr/bin/env bash
# ============================================================================
# solocorp One-Command Installer (wheel-only, 源码仓库保持私有)
# ============================================================================
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/abdrsl/solocorp-dist/main/install.sh | bash
#
# 环境变量覆盖:
#   SOLOCORP_WHEEL=/path/to.whl   # 用本地 wheel (离线/测试), 默认拉 GitHub 最新 Release
#   SOLOCORP_VENV=~/.solocorp-venv
#   SOLOCORP_BIN=~/.local/bin
# ============================================================================
set -euo pipefail

REPO="abdrsl/solocorp-dist"
VENV="${SOLOCORP_VENV:-$HOME/.solocorp-venv}"
BIN_DIR="${SOLOCORP_BIN:-$HOME/.local/bin}"
WHEEL="${SOLOCORP_WHEEL:-}"

say()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN:\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# ── 1. Python ≥ 3.11 ────────────────────────────────────────────────────────
command -v python3 >/dev/null || die "未找到 python3 — 请先安装 Python 3.11+ (Ubuntu: sudo apt install python3 python3-venv)"
PYVER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PYMIN=$(python3 -c 'import sys; print(sys.version_info.minor)')
PYMAJ=$(python3 -c 'import sys; print(sys.version_info.major)')
{ [ "$PYMAJ" -eq 3 ] && [ "$PYMIN" -ge 11 ]; } || die "需要 Python ≥ 3.11, 当前 $PYVER (Ubuntu 24.04 自带 3.12 满足)"

# ── 2. venv 能力 (Debian/Ubuntu 需要 python3-venv 包) ───────────────────────
if ! python3 -m venv --help >/dev/null 2>&1; then
  say "缺 venv 模块, 尝试 apt 安装 python3-venv (需要 sudo 密码)..."
  if command -v apt-get >/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq python3-venv python3-full \
      || die "自动安装失败 — 请手动执行: sudo apt install python3-venv python3-full 后重跑本脚本"
  else
    die "非 apt 系统: 请确保 python3 自带 venv (Debian 系: python3-venv; Fedora: python3 自带)"
  fi
fi

# ── 3. 建独立 venv (不碰系统 Python, PEP 668 友好) ──────────────────────────
[ -e "$VENV" ] || { say "创建虚拟环境 $VENV"; python3 -m venv "$VENV"; }
PY="$VENV/bin/python"
"$PY" -m pip --version >/dev/null 2>&1 || "$PY" -m ensurepip --upgrade >/dev/null
say "升级 pip"
"$PY" -m pip install --upgrade pip -q

# ── 4. 取 wheel: 本地覆盖 或 GitHub 最新 Release ────────────────────────────
if [ -n "$WHEEL" ]; then
  [ -f "$WHEEL" ] || die "SOLOCORP_WHEEL 指定的文件不存在: $WHEEL"
  say "安装本地 wheel: $WHEEL"
  TARGET="$WHEEL"
else
  say "解析最新 Release wheel 地址..."
  URL=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | python3 -c 'import json,sys
assets=[a for a in json.load(sys.stdin).get("assets",[]) if a["name"].endswith(".whl")]
print(assets[0]["browser_download_url"] if assets else "")') \
    || die "无法访问 GitHub API — 检查网络后重试, 或直接下载 wheel 后: SOLOCORP_WHEEL=./文件名 bash install.sh"
  [ -n "$URL" ] || die "最新 Release 里没有 wheel 资产"
  say "安装 $URL"
  TARGET="$URL"
fi
"$PY" -m pip install -q "$TARGET"

# ── 5. solocorp 命令挂到 PATH ───────────────────────────────────────────────
mkdir -p "$BIN_DIR"
ln -sf "$VENV/bin/solocorp" "$BIN_DIR/solocorp"
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    RC="$HOME/.bashrc"; [ -n "${ZSH_VERSION:-}" ] && RC="$HOME/.zshrc"
    touch "$RC"
    grep -qs 'solocorp' "$RC" || echo "export PATH=\"$BIN_DIR:\$PATH\"  # solocorp" >> "$RC"
    warn "$BIN_DIR 不在当前 PATH — 新开终端或执行: source $RC"
    ;;
esac

# ── 6. 完成 ─────────────────────────────────────────────────────────────────
VERSION=$("$BIN_DIR/solocorp" version 2>/dev/null || "$VENV/bin/solocorp" version 2>/dev/null || echo "?")
say "$VERSION 安装完成 ✅"
echo
echo "下一步:"
echo "  1) 新开终端 (或: source ~/.bashrc)"
echo "  2) solocorp onboard    # 引导式初始化"
echo "  3) solocorp start      # 启动, 浏览器开 http://127.0.0.1:8000"
echo
echo "卸载: rm -rf $VENV $BIN_DIR/solocorp"
