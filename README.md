# template

一個通用、最小的 Docker 開發環境 template，clone 下來跑一行就能開始新專案。

預裝 Python 3.12（uv）、Node 22、`gh`、Claude Code、Gemini CLI、Copilot CLI、`ruff`、`pytest`。支援 git worktree 平行開發流程。

---

## 一鍵啟動

```bash
git clone https://github.com/erictsai1224tw/template.git my-project \
  && cd my-project \
  && ./bootstrap.sh my-project \
  && make build && make up && make terminal
```

跑完你就坐在新 project 的 container terminal 裡，可以開工。

> ⚠️ 第一次使用前，host 機器必須先設定 git：
> ```bash
> git config --global user.name  "Your Name"
> git config --global user.email "you@example.com"
> ```

---

## 操作指令

### `./bootstrap.sh <project-name>` — 一次性初始化

| 參數 | 必填 | 說明 |
|------|------|------|
| `<project-name>` | 是 | 新專案名稱。會被寫進 `pyproject.toml`、`CLAUDE.md`、`.devcontainer/devcontainer.json` |

做的事：
1. 重置 git history（刪原本的 `.git`，重新 `git init`）
2. 用 `sed` 把各檔案裡的 `PROJECT_NAME_PLACEHOLDER` 換成你的專案名
3. 從 `.env.example` 複製出 `.env`
4. 建立一個 initial commit
5. 把 `bootstrap.sh` 自己刪掉（只跑一次）

執行後**記得編輯 `.env`** 填入你的 `GIT_NAME` / `GIT_EMAIL`，這兩個會在 container 裡自動設定 git identity。

### `make <target>` — 日常開發

| Target | 用途 |
|--------|------|
| `make build` | 建 image（deps 變更時才需要重跑）|
| `make up` | 啟動 container（背景） |
| `make down` | 停 container |
| `make terminal` | 進 container shell |
| `make logs` | 看 container log（follow） |
| `make format` | container 內跑 `ruff format .` |
| `make lint` | container 內跑 `ruff check . --fix` |
| `make lock` | 更新 `uv.lock` |
| `make clean` | 清掉 container + volumes（重置環境） |
| `make help` | 印完整指令表 |

### Worktree 平行開發

| Target | 範例 | 用途 |
|--------|------|------|
| `make worktree name=<x>` | `make worktree name=feat-api` | 在 `../feat-api/` 建 worktree，branch 為 `feat/feat-api`，`.env` 會自動 symlink |
| `make worktree-rm name=<x>` | `make worktree-rm name=feat-api` | 移除 worktree + 刪 branch |
| `make worktree-list` | — | 列出所有 worktree |

---

## 目錄結構

Template 支援兩種用法：

**Flat**（小專案、新手）：
```
my-project/        ← clone + bootstrap 在這
├── Dockerfile
├── Makefile
└── ...
```

**Workspace wrapper**（多 worktree 平行跑 AI agent）：
```
my-project/
├── main/          ← clone + bootstrap 在這
├── feat-xxx/      ← make worktree name=feat-xxx 建
└── shared/        ← 跨 worktree 共用資料（datasets / ckpts）
```

兩種用同一份 Makefile，差別只在外層包不包 workspace 資料夾。

---

## 裡面有什麼

| 類別 | 內容 |
|------|------|
| **Base image** | `ubuntu:22.04` |
| **Python** | 3.12 via [uv](https://github.com/astral-sh/uv) |
| **Node** | 22.x（給 AI CLI 用） |
| **CLI tools** | `gh`, Claude Code, Gemini CLI, Copilot CLI |
| **Lint / format** | `ruff` |
| **Test** | `pytest` |
| **CI** | GitHub Actions（`ruff check` + `ruff format --check` + `pytest`）|
| **AI 文件** | `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`（single source of truth = `CLAUDE.md`） |

---

## 客製化後自己的 repo 需要改什麼

Bootstrap 完之後，你通常會想：

1. 編輯 `README.md`（已被 bootstrap 替換成骨架）— 描述你的專案
2. 編輯 `CLAUDE.md` 的 `Project Overview` 和 `Architecture` 段
3. 在 `pyproject.toml` 加真正的 dependencies
4. 視需要編輯 `.gitignore`（底部有 dataset/ckpt 的註解範例，按需取消註解）
5. `docker-compose.yml` 取消註解需要 forward 的 port

---

## FAQ

**Q: `docker: command not found` 怎麼辦？**
A: 先裝 Docker 跟 Docker Compose v2。template 本身不包含 Docker 安裝。

**Q: 我不用 Python，只要 Docker 環境怎麼辦？**
A: 刪掉 `pyproject.toml` 跟 Dockerfile 裡 uv / venv 相關的 layer 就行。template 保留是因為多數新專案都會用 Python。

**Q: 可以不用 AI CLI tools 嗎？**
A: 可以。Dockerfile 裡最後一段 `npm install -g @google/gemini-cli @github/copilot` 跟 `curl claude.ai/install.sh` 都刪掉即可。

---

## License

MIT
