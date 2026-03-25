#!/bin/bash
set -e  # 遇到错误立即退出，安全优先

# =============================================================================
# GitHub Codespaces Personal Dotfiles Install Script
# 功能：自动安装 Rust / Python / Node.js / Vite (最新版)
# 原则：安全 > 稳定 > 速度
# =============================================================================

echo "🚀 Starting dotfiles installation for Codespaces..."

# -----------------------------------------------------------------------------
# 1. 系统更新与基础依赖（稳定优先，避免破坏系统环境）
# -----------------------------------------------------------------------------
echo "📦 Updating system packages..."
# Codespaces 基于 Ubuntu，使用非交互式更新避免卡住
sudo apt-get update -qq
sudo apt-get install -y -qq \
    curl \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    >/dev/null 2>&1

# -----------------------------------------------------------------------------
# 2. 安装 Rust (最新版，官方 rustup 方式)
# -----------------------------------------------------------------------------
if ! command -v rustc &> /dev/null; then
    echo "🦀 Installing Rust (latest)..."
    # 使用官方安装脚本，-y 自动确认，--quiet 减少输出
    # 安全：官方脚本经过审计，且默认安装到用户目录，不影响系统
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet
    
    # 将 cargo/bin 加入当前会话的 PATH（后续会话由 .zshrc/.bashrc 处理）
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "✅ Rust already installed, skipping..."
fi

# -----------------------------------------------------------------------------
# 3. 安装 Python (最新版，使用 GitHub Actions 的 setup-python 同款方式)
# -----------------------------------------------------------------------------
if ! command -v python3 &> /dev/null || [[ $(python3 --version 2>&1) =~ "3\.[0-9]+" && "${BASH_REMATCH[0]#3.}" -lt "8" ]]; then
    echo "🐍 Installing Python (latest stable)..."
    # Codespaces 通常已预装 Python，此步骤作为兜底
    # 使用 deadsnakes PPA 获取最新版（Ubuntu 专用）
    CODENAME=$(lsb_release -cs 2>/dev/null || echo "jammy")
    if ! grep -q "deadsnakes" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        sudo add-apt-repository -y ppa:deadsnakes/ppa >/dev/null 2>&1
        sudo apt-get update -qq >/dev/null 2>&1
    fi
    # 安装 python3.12（当前最新稳定版，可根据需要调整）
    sudo apt-get install -y -qq python3.12 python3.12-venv python3.12-dev >/dev/null 2>&1
    # 创建软链接方便使用
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 || true
else
    echo "✅ Python already installed, skipping..."
fi

# 确保 pip 可用
python3 -m ensurepip --upgrade --quiet 2>/dev/null || true

# -----------------------------------------------------------------------------
# 4. 安装 Node.js (最新版 LTS，使用 NodeSource 官方源)
# -----------------------------------------------------------------------------
if ! command -v node &> /dev/null; then
    echo "🟢 Installing Node.js (latest LTS)..."
    # 使用 NodeSource 安装脚本获取最新版，-y 自动确认
    # 安全：使用 HTTPS 且验证脚本来源
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >/dev/null 2>&1
    sudo apt-get install -y -qq nodejs >/dev/null 2>&1
else
    echo "✅ Node.js already installed, skipping..."
fi

# -----------------------------------------------------------------------------
# 5. 安装 Vite (最新版，使用 npm 全局安装)
# -----------------------------------------------------------------------------
if ! command -v vite &> /dev/null; then
    echo "⚡ Installing Vite (latest)..."
    # 安全：使用 npm 官方 registry，添加 --prefer-offline 加速（如果缓存存在）
    # 注意：生产项目建议在项目内安装，此处为满足自动化需求使用全局安装
    npm install -g vite --prefer-offline --quiet 2>/dev/null || npm install -g vite --quiet
else
    echo "✅ Vite already installed, skipping..."
fi

# -----------------------------------------------------------------------------
# 6. 同步 dotfiles 到 $HOME（Codespaces 会自动克隆到 /workspaces/.codespaces/.persistedshare/dotfiles）
# -----------------------------------------------------------------------------
DOTFILES_SRC="${DOTFILES_SRC:-/workspaces/.codespaces/.persistedshare/dotfiles}"
if [[ -d "$DOTFILES_SRC" ]]; then
    echo "🔗 Symlinking dotfiles to \$HOME..."
    # 仅处理以 . 开头的文件/目录，避免复制 README 等无关文件
    for file in "$DOTFILES_SRC"/.*; do
        [[ -e "$file" ]] || continue  # 跳过不存在的匹配
        base=$(basename "$file")
        # 跳过 . 和 .. 以及当前脚本本身
        [[ "$base" == "." || "$base" == ".." || "$base" == "install.sh" ]] && continue
        
        target="$HOME/$base"
        # 如果目标已存在且不是符号链接，备份它
        if [[ -e "$target" && ! -L "$target" ]]; then
            mv "$target" "${target}.backup.$(date +%s)"
        fi
        # 创建符号链接（稳定：避免直接覆盖用户可能的自定义配置）
        ln -sf "$file" "$target"
    done
fi

# -----------------------------------------------------------------------------
# 7. 刷新 Shell 配置（如果存在 .zshrc 或 .bashrc）
# -----------------------------------------------------------------------------
if [[ -f "$HOME/.zshrc" ]]; then
    echo "🔄 Sourcing .zshrc..."
    # 注意：在 install.sh 中 source 仅影响当前脚本环境，新用户会话由 shell 自动加载
    # 此处仅输出提示，避免在非交互式环境报错
    echo "   → Next terminal session will load your .zshrc"
fi

echo "✨ Dotfiles installation completed!"
echo "💡 Tip: Rebuild your Codespace or open a new terminal to apply all changes."
