# =============================================================================
# .zshrc - GitHub Codespaces Personal Configuration
# 目标：安全、稳定、高效 (Python & Rust 优化)
# =============================================================================

# -----------------------------------------------------------------------------
# 1. 基础安全与稳定性设置
# -----------------------------------------------------------------------------
# 防止文件被意外覆盖 (安全优先)
setopt NO_CLOBBER

# 历史记录配置 (稳定其二)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS

# 纠错功能 (避免打错命令)
setopt CORRECT

# -----------------------------------------------------------------------------
# 2. 环境变量与路径 (适配 Codespaces 及安装脚本)
# -----------------------------------------------------------------------------
# 编辑器默认使用 VS Code (Codespaces 环境)
export EDITOR="code"

# Rust Cargo 路径 (确保 install.sh 安装后可持久化)
if [[ -d "$HOME/.cargo/bin" ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Node.js 全局包路径 (确保 npm install -g 的命令可用)
if [[ -d "$HOME/.npm-global/bin" ]]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi
# 如果没有配置 npm prefix，默认使用系统路径，此处仅为保险

# Python 用户脚本路径
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# 代理设置 (可选：如果您在国内访问 GitHub 慢，可取消注释并配置)
# export https_proxy="http://127.0.0.1:7890"
# export http_proxy="http://127.0.0.1:7890"
# export no_proxy="localhost,127.0.0.1,0.0.0.0"

# -----------------------------------------------------------------------------
# 3. 常用别名 (效率与安全平衡)
# -----------------------------------------------------------------------------
# 系统命令安全别名
alias rm='rm -i'           # 删除前确认 (安全优先)
alias mv='mv -i'           # 覆盖前确认
alias cp='cp -i'           # 覆盖前确认
alias grep='grep --color=auto'
alias ls='ls --color=auto -h' # 人类可读格式

# Git 安全别名 (防止误操作)
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
# 安全推送：使用 --force-with-lease 而不是 --force
alias gpf='git push --force-with-lease' 
alias gl='git pull'
alias gco='git checkout'
alias gb='git branch'

# Python 开发者别名
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
# 快速创建虚拟环境并激活
alias mkvenv='python3 -m venv .venv && source .venv/bin/activate'

# Rust 开发者别名
alias rs='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias cc='cargo check'
alias ci='cargo init'
alias cn='cargo new'

# 快速清理 (安全版)
alias clean='rm -rf node_modules dist target __pycache__ .pytest_cache .venv'

# -----------------------------------------------------------------------------
# 4. 提示符 (Prompt) 设置
# 简洁显示：用户@主机 当前目录 (Git 分支)
# -----------------------------------------------------------------------------
autoload -Uz vcs_info
precmd() { vcs_info }

# 设置 Git 信息显示格式
zstyle ':vcs_info:git:*' formats ' %F{green}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}(%b|%a)%f'

# 设置提示符
# %n: 用户名 %m: 主机名 %~: 当前目录 %F{color}: 颜色 %f: 重置颜色
PROMPT='%F{cyan}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_} %F{white}❯%f '
RPROMPT='%F{yellow}%(?..%?)%f' # 右侧显示错误码（如果有）

# -----------------------------------------------------------------------------
# 5. Codespaces 特定优化
# -----------------------------------------------------------------------------
# 如果是 Codespaces 环境，设置一些特定变量
if [[ -n "$CODESPACES" ]]; then
    export GIT_EDITOR="code --wait"
    # 自动打开浏览器端口转发提示 (可选)
    # echo "🚀 Codespaces Environment Detected."
fi

# -----------------------------------------------------------------------------
# 6. 补全增强
# -----------------------------------------------------------------------------
autoload -Uz compinit
# 安全：只每天检查一次补偿文件，避免启动慢
compinit -C
