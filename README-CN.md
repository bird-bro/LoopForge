# loopEng-skills

中文文档 | [English](README.md)

> 对话剧本(操作手册):Claude Code 版 [USAGE-PLAYBOOK.md](skills/loop-eng-cc/USAGE-PLAYBOOK.md) · Codex 版 [USAGE-PLAYBOOK-CODEX.md](skills/loop-eng-codex/USAGE-PLAYBOOK-CODEX.md)

---

## 概述

基于工业级三层范式(**OpenSpec + Superpowers + Harness**,即 OSH / 循环工程)的 AI 协作优化 Skill。两个并列版本,各有独立的 `scaffold.sh`(CC 版创建 `.claude/`;Codex 版创建 `.codex/`):

| 版本 | Skill | AI 工具 | 活入口文件 | 纪律(HOW) | Loop 驱动方式 |
|:--|:--|:--|:--|:--|:--|
| Claude Code | `loop-eng-cc` | Claude Code | `CLAUDE.md` | `.claude/skills/` 里的 Superpowers 技能 | `/opsx:` 斜杠命令 |
| Codex | `loop-eng-codex` | Codex | `AGENTS.md` | 作为指令写进 `AGENTS.md` | `openspec` CLI + 自然语言 |

两个版本都对项目的 AI 协作结构进行**脚手架生成、审计、重构**,符合 OSH 标准。每个版本三种模式:

| 模式 | 用途 |
|:--|:--|
| **scaffold(脚手架)** | 通过 `scaffold.sh` 从零生成完整框架 |
| **audit(审计)** | 32 项检查的成熟度评分(E1–E4、O1–O8、S1–S9、H1–H11) |
| **restructure(重构)** | 将单体 `CLAUDE.md` / `AGENTS.md` 拆分为按技术栈分离的 Agent + 优化 |

> v2:原 `loop-guard` + `split-help` 两个 skill 已合并为 `loop-eng-cc`(Claude Code 版);`loop-eng-codex` 为 Codex 版。文件模板收进各自版本的 `scaffold.sh`,SKILL.md 不再重复模板。

**核心理念:**
- **OpenSpec** 定义方向(WHAT)
- **Superpowers** 强制纪律(HOW)
- **Harness** 编排协作(WHO)

## 安装

### Claude Code —— `loop-eng-cc`

把 skill 复制进项目(Claude Code 从 `.claude/skills/` 自动加载):

```bash
cp -r skills/loop-eng-cc /path/to/project/.claude/skills/loop-eng-cc
```

通过 `/loop-eng-cc` 斜杠命令触发,或直接用自然语言描述任务。

### Codex —— `loop-eng-codex`

全局安装进 Codex 的 skills 目录,然后重启 Codex:

```bash
cp -R skills/loop-eng-codex ~/.codex/skills/loop-eng-codex
```

`scaffold.sh` 已是 skill 目录内的实体文件,普通拷贝即可。重启后 skill 按 `description` 自动触发,也可用 `$loop-eng-codex` 显式调用;`openspec init --tools codex` 还会为 Codex 生成 `/opsx:` 斜杠命令(`/opsx:propose`、`/opsx:apply`、`/opsx:archive`、`/opsx:explore`、`/opsx:sync`)。

> 若你之前把旧 Claude 版拷进了 `~/.codex/skills/loop-eng`,先删掉以免两个 skill 抢同一意图:`rm -rf ~/.codex/skills/loop-eng`。

## 脚手架生成新项目

每个版本有自己的 `scaffold.sh`。CC 版创建 `.claude/`;Codex 版创建 `.codex/`。两者都生成 `CLAUDE.md` + `AGENTS.md` 镜像:

```bash
# Claude Code(创建 .claude/)
./skills/loop-eng-cc/scaffold.sh myapp

# Codex(创建 .codex/)
./skills/loop-eng-codex/scaffold.sh myapp --tools codex

# 三栈(web + mobile)
./skills/loop-eng-codex/scaffold.sh myapp --stacks backend,frontend,frontend-mobile --tools codex

# 自定义目标目录 + 跳过 init
./skills/loop-eng-cc/scaffold.sh myapp --dir ./projects/myapp --no-init
```

选项:`--stacks`、`--dir`、`--backend-dir`、`--frontend-dir`、`--mobile-dir`、`--tools`(CC 版默认 `claude`,Codex 版默认 `codex`;仅影响 `openspec init`)、`--no-init`。

### `scaffold.sh` 生成内容

```
myapp/
├── CLAUDE.md                 ← 导航中心(≤120 行)—— Claude Code 入口
├── AGENTS.md                 ← Codex 导航中心(与 CLAUDE.md 镜像)
├── openspec/                 ← WHAT:README、project.md、specs/{api,data,errors}、changes/_template、archive
├── .claude/  (CC 版)         ← HOW:settings.json(权限+钩子)、rules/、agents/{reviewer,coordinator}
├── .codex/   (Codex 版)      ← HOW:skills/openspec-*(propose/apply/verify/archive + trigger 注入)
├── backend/{CLAUDE,AGENTS}.md   ← Backend Agent(Claude Code / Codex)
└── frontend-web/{CLAUDE,AGENTS}.md ← Frontend Agent(Claude Code / Codex)
```

`CLAUDE.md` 与 `AGENTS.md` 总是一起生成(内容镜像),同一项目可在两种工具中使用。CC 版创建 `.claude/`;Codex 版创建 `.codex/` -- 各自只创建自己工具的目录,不交叉创建。非破坏性:已存在的文件会被跳过,可安全重跑。

### 需另外安装的组件(按版本)

**两者皆需:** OpenSpec CLI —— `npm i -g @fission-ai/openspec@latest`(脚手架会自动跑 `openspec init`)。

**仅 Claude Code:** Superpowers 技能集(`brainstorm`、`writing-plans`、`executing-plans`、`code-review`、`verification-before-completion`)与 `frontend-design`(仅前端项目)。它们位于 `.claude/skills/`,由 `/opsx:` 命令自动触发。

**Codex:** 无需额外安装 —— Superpowers 五步纪律已作为指令写进生成的 `AGENTS.md`,Loop 由 `openspec` CLI 驱动。

随后填写 `openspec/project.md`、`openspec/specs/*` 及各栈 `CLAUDE.md` / `AGENTS.md` 中的 `[方括号]` 占位符。

## 审计现有项目

触发 skill(如"审计我的项目结构")。它会执行 Phase 0(环境 E1–E4)+ Phase 1(32 项检查),输出诊断表、成熟度等级、Top 问题与行动计划。

> Codex 注意:`scaffold.sh check` 是双源的 -- 先查 `AGENTS.md`,再查 `.claude/` 作为回退。纯 Codex 项目(无 `.claude/`)通过 `AGENTS.md` 通过 E3/E4/S4/S5/S6/S8/H9,不会误报 PARTIAL/FAIL。

### 成熟度评分

```
环境 = E/4 · OpenSpec = O/8 · Superpowers = S/9 · Harness = H/11
总体 = (E + O + S + H) / 32
```

| 得分 | 等级 |
|:--|:--|
| < 33% | 基础建设前 |
| 33–66% | 基础级 |
| 66–90% | 质量级 |
| > 90% | 工业级 |

## 重构单体项目

当单个 `CLAUDE.md`(Claude)或 `AGENTS.md`(Codex)混合多个技术栈,或审计分数偏低时:触发 skill 把它拆分为按栈分离的 Agent 文件,根文件重写为导航中心,并按 Phase 5 顺序执行重构。

## 许可证

见 [LICENSE](LICENSE)。
