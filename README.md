# PROJECT_NAME_PLACEHOLDER

TODO: 一段話說明專案。

## Quick Start

```bash
git clone <repo-url> my-project
cd my-project
./bootstrap.sh my-project
# 編輯 .env 填入 GIT_NAME / GIT_EMAIL
make build && make up && make terminal
```

進 container 後：

```bash
source /venv/bin/activate
uv sync --active
```

## Worktree Workflow

需要平行 worktree 開發時：

```bash
make worktree name=feat-xxx       # 建立 ../feat-xxx，branch: feat/feat-xxx
make worktree-rm name=feat-xxx    # 清理
make worktree-list                # 列出
```

Worktree 會放在 sibling 目錄（`../feat-xxx/`），`.env` 自動 symlink。

若要 workspace-wrapper 結構（多 worktree 平行）：

```
my-project/
├── main/       ← git clone 到這，primary worktree
├── feat-xxx/   ← 用 make worktree 建
└── shared/     ← datasets / ckpts 共用
```

## Docs

- [CLAUDE.md](./CLAUDE.md) — Coding conventions、architecture、git workflow
- [AGENTS.md](./AGENTS.md) — Codex / 其他 agent 工具備註
- [GEMINI.md](./GEMINI.md) — Gemini CLI 備註

## Stack

- **Base image**: `ubuntu:22.04`
- **Python**: 3.12 via [uv](https://github.com/astral-sh/uv)
- **Node**: 22.x（給 AI CLI tools 用）
- **Pre-installed**: `gh`, Claude Code, Gemini CLI, Copilot CLI
- **Lint/format**: `ruff`
- **Test**: `pytest`
- **CI**: GitHub Actions
