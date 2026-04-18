# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TODO: 一段話說明 PROJECT_NAME_PLACEHOLDER 的目的、核心設計、主要使用場景。

## Common Commands

主要指令定義在 `Makefile`，`make help` 看完整列表。常用：

```bash
make build           # 首次或 deps 變更時重建 image
make up              # 啟動 container
make terminal        # 進入 container
make format / lint   # ruff format / check
make worktree name=feat-xxx    # 建立平行 worktree
make worktree-rm name=feat-xxx # 清理 worktree
```

容器內：

```bash
source /venv/bin/activate    # 啟動 uv 建好的虛擬環境
uv sync --active             # 安裝/更新依賴
pytest                        # 跑測試
```

## Architecture

TODO: 主要模組、資料流、關鍵設計模式

## Coding Conventions

- `from __future__ import annotations` 放每個 module 頂端
- Type hints 所有 signature；`X | None`（PEP 604），不要 `Optional[X]`
- Google-style docstrings 寫在 public interface
- `logging` module only — 不要在 library code 用 `print()`
- Pydantic models 集中在 `models.py`（如果用 Pydantic）
- 不要 hardcode 路徑或 model 名稱；用 config / env vars

## Testing Conventions

- Test 檔對應 source: `tests/test_<module>.py`
- Class: `class Test<XXX>:`；method: `test_<behavior>` 或 `test_<behavior>_<condition>`
- Mock 外部依賴（API、subprocess、SSH）
- Fixtures 放 `tests/fixtures/`

## Git Workflow

**這些是強制規則，不是建議。每個 task 都要遵守。**

### Branch First

- **絕不直接在 `main` 工作。** 開新功能前從 `main` 分支：
  ```bash
  git checkout main && git pull
  git checkout -b feat/<feature-name>   # 新功能
  git checkout -b fix/<bug-name>        # 修 bug
  ```
- Branch prefix: `feat/` / `fix/` / `refactor/` / `chore/`

### Commit After Every Change

- **每個邏輯獨立的改動立刻 commit** — 不要批次塞多個無關改動進一個 commit
- Commit message 簡潔且說明 *what + why*

### Worktree Isolation

- 實驗或測試新想法時用 `git worktree` 避免污染主目錄：
  ```bash
  make worktree name=feat-xxx       # 建
  make worktree-rm name=feat-xxx    # 清
  ```
- Worktree 放 `../<branch-name>/`（sibling），透過 symlink 共用 `.env`

## Worktree Workflow

本 template 支援兩種目錄結構：

**Flat**（小專案 / 新手）：
```
my-project/     ← git clone 到這，直接工作
```

**Workspace wrapper**（多 worktree 平行開發）：
```
my-project/
├── main/       ← primary worktree（clone 到這）
├── feat-xxx/   ← make worktree name=feat-xxx
└── shared/     ← datasets / ckpts 等跨 worktree 共用資源
```

兩種結構用同一份 Makefile。Shared 資源路徑透過 `.env` 設定。

## 語言風格

回覆繁體中文時，請用台灣口語語氣，像跟朋友聊天。
避免翻譯腔（「需要注意的是」、「值得一提的是」）和過度書面的連接詞（「然而」「綜上所述」）。
句子保持短，一個意思說完換句。
