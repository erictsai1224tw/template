#!/usr/bin/env bash
# 一次性初始化腳本：新 project clone 下來後執行一次
# 用法: ./bootstrap.sh [project-name]
set -euo pipefail

# Resolve real script path (follow symlinks) — portable POSIX-ish (no readlink -f)
_resolve_script_path() {
    local src="$1"
    while [ -L "$src" ]; do
        local dir
        dir="$(cd -P -- "$(dirname -- "$src")" && pwd)"
        src="$(readlink -- "$src")"
        case "$src" in
            /*) ;;                      # absolute, use as-is
            *)  src="$dir/$src" ;;      # relative, prepend dir
        esac
    done
    printf '%s' "$src"
}

SCRIPT_PATH="$(_resolve_script_path "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$SCRIPT_PATH")" && pwd)"
cd "$SCRIPT_DIR"

PROJECT_NAME="${1:-}"
if [[ -z "$PROJECT_NAME" ]]; then
    read -rp "Project name: " PROJECT_NAME
fi

if [[ -z "$PROJECT_NAME" ]]; then
    echo "ERROR: project name is required" >&2
    exit 1
fi

# Preflight: git config (檢查 key 存在且非空)
GIT_USER_NAME="$(git config --global user.name 2>/dev/null || true)"
GIT_USER_EMAIL="$(git config --global user.email 2>/dev/null || true)"
if [[ -z "$GIT_USER_NAME" || -z "$GIT_USER_EMAIL" ]]; then
    echo "ERROR: git user.name / user.email 尚未設定（或為空）。請先跑：" >&2
    echo "  git config --global user.name  \"Your Name\"" >&2
    echo "  git config --global user.email \"you@example.com\"" >&2
    exit 1
fi

echo "🚀 Bootstrapping project: $PROJECT_NAME"

# 1. 重置 git history
rm -rf .git
git init -b main > /dev/null

# 2. 用 child-project 骨架覆寫 README.md（原本描述 template 本身）
cat > README.md <<EOF
# $PROJECT_NAME

TODO: 一段話描述你的專案。

## Quick Start

\`\`\`bash
make build && make up && make terminal
\`\`\`

進 container 後：

\`\`\`bash
source /venv/bin/activate
uv sync --active
\`\`\`

## Docs
- [CLAUDE.md](./CLAUDE.md) — coding conventions、architecture、git workflow
EOF
echo "  ✔ rewrote README.md"

# 3. 替換 PROJECT_NAME_PLACEHOLDER（escape sed replacement metachars: \ & /）
ESCAPED_NAME=$(printf '%s' "$PROJECT_NAME" | sed -e 's/[\\/&]/\\&/g')
FILES_TO_PATCH=(
    "pyproject.toml"
    ".devcontainer/devcontainer.json"
    "CLAUDE.md"
)
for f in "${FILES_TO_PATCH[@]}"; do
    if [[ -f "$f" ]] && grep -q "PROJECT_NAME_PLACEHOLDER" "$f"; then
        sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/${ESCAPED_NAME}/g" "$f"
        rm -f "${f}.bak"
        echo "  ✔ patched $f"
    fi
done

# 4. 建立 .env
if [[ ! -f .env ]]; then
    cp .env.example .env
    echo "  ✔ created .env (請編輯 GIT_NAME / GIT_EMAIL)"
fi

# 4. Initial commit
git add .
git commit -m "chore: bootstrap $PROJECT_NAME from template" > /dev/null

# 5. Self-delete (the resolved real script, not a symlink)
rm -- "$SCRIPT_PATH"

echo ""
echo "✅ Bootstrap 完成！"
echo ""
echo "下一步："
echo "  1. 編輯 .env，填入 GIT_NAME / GIT_EMAIL"
echo "  2. make build && make up && make terminal"
