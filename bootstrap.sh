#!/usr/bin/env bash
# 一次性初始化腳本：新 project clone 下來後執行一次
# 用法: ./bootstrap.sh [project-name]
set -euo pipefail

# Resolve script dir and cd there (CWD safety — 不會影響 caller 的其他 repo)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PROJECT_NAME="${1:-}"
if [[ -z "$PROJECT_NAME" ]]; then
    read -rp "Project name: " PROJECT_NAME
fi

if [[ -z "$PROJECT_NAME" ]]; then
    echo "ERROR: project name is required" >&2
    exit 1
fi

# Preflight: git config
if ! git config --global user.name > /dev/null 2>&1 || ! git config --global user.email > /dev/null 2>&1; then
    echo "ERROR: git user.name / user.email 尚未設定。請先跑：" >&2
    echo "  git config --global user.name  \"Your Name\"" >&2
    echo "  git config --global user.email \"you@example.com\"" >&2
    exit 1
fi

echo "🚀 Bootstrapping project: $PROJECT_NAME"

# 1. 重置 git history
rm -rf .git
git init -b main > /dev/null

# 2. 替換 PROJECT_NAME_PLACEHOLDER（escape 掉 sed replacement metachars: \ & /）
ESCAPED_NAME=$(printf '%s' "$PROJECT_NAME" | sed -e 's/[\/&]/\\&/g')
FILES_TO_PATCH=(
    "pyproject.toml"
    ".devcontainer/devcontainer.json"
    "README.md"
    "CLAUDE.md"
)
for f in "${FILES_TO_PATCH[@]}"; do
    if [[ -f "$f" ]] && grep -q "PROJECT_NAME_PLACEHOLDER" "$f"; then
        sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/${ESCAPED_NAME}/g" "$f"
        rm -f "${f}.bak"
        echo "  ✔ patched $f"
    fi
done

# 3. 建立 .env
if [[ ! -f .env ]]; then
    cp .env.example .env
    echo "  ✔ created .env (請編輯 GIT_NAME / GIT_EMAIL)"
fi

# 4. Initial commit
git add .
git commit -m "chore: bootstrap $PROJECT_NAME from template" > /dev/null

# 5. Self-delete
SCRIPT_PATH="$0"
rm -- "$SCRIPT_PATH"

echo ""
echo "✅ Bootstrap 完成！"
echo ""
echo "下一步："
echo "  1. 編輯 .env，填入 GIT_NAME / GIT_EMAIL"
echo "  2. make build && make up && make terminal"
