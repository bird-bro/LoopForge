# loopEng-skills

中文文档 | [English](README.md)

> 操作手册(对话剧本):[USAGE-PLAYBOOK.md](USAGE-PLAYBOOK.md)

---

## 概述

基于工业级三层范式(**OpenSpec + Superpowers + Harness**,即 OSH / 循环工程)的单个 AI 协作优化 Skill:

**`loop-eng`** — 对项目的 AI 协作结构进行**脚手架生成、审计、重构**,符合 OSH 标准。一个 skill 三种模式:

| 模式 | 用途 |
|:--|:--|
| **scaffold(脚手架)** | 通过 `scaffold.sh` 从零生成完整框架 |
| **audit(审计)** | 32 项检查的成熟度评分(E1–E4、O1–O8、S1–S9、H1–H11) |
| **restructure(重构)** | 将单体 `CLAUDE.md` 拆分为按技术栈分离的 Agent + 优化 |

> v2:原 `loop-guard` + `split-help` 两个 skill 已合并为 `loop-eng`。文件模板统一收进 `scaffold.sh`(单一来源),SKILL.md 不再重复模板。

**核心理念:**
- **OpenSpec** 定义方向(WHAT)
- **Superpowers** 强制纪律(HOW)
- **Harness** 编排协作(WHO)

## 安装

把 skill 复制进项目(或任何要用它的项目):

```bash
cp -r skills/loop-eng /path/to/project/.claude/skills/loop-eng
```

Claude Code 会从 `.claude/skills/` 自动加载。

## 脚手架生成新项目

```bash
# 默认:backend + frontend web,自动运行 `openspec init`
./skills/loop-eng/scaffold.sh myapp

# 三栈(web + mobile)
./skills/loop-eng/scaffold.sh myapp --stacks backend,frontend,frontend-mobile

# 自定义目标目录 + 跳过 init
./skills/loop-eng/scaffold.sh myapp --dir ./projects/myapp --no-init
```

选项:`--stacks`、`--dir`、`--backend-dir`、`--frontend-dir`、`--mobile-dir`、`--tools`(默认 `claude`)、`--no-init`。

### `scaffold.sh` 生成内容

```
myapp/
├── CLAUDE.md                 ← 导航中心(≤120 行)
├── AGENTS.md                 ← Codex 导航中心(与 CLAUDE.md 镜像)
├── openspec/                 ← WHAT:README、project.md、specs/{api,data,errors}、changes/_template、archive
├── .claude/                  ← HOW:settings.json(权限+钩子)、rules/、agents/{reviewer,coordinator}
│   └── (commands/ 与 openspec-* skill 由 `openspec init` 生成)
├── backend/{CLAUDE,AGENTS}.md   ← Backend Agent(Claude Code / Codex)
└── frontend-web/{CLAUDE,AGENTS}.md ← Frontend Agent(Claude Code / Codex)
```

> `CLAUDE.md` 是 Claude Code 的入口;`AGENTS.md` 是 Codex 的入口。脚手架会同时生成两者(内容镜像),同一项目可在两种工具中使用。`loop-eng` SKILL 本身属于 Claude Code 侧;在 Codex 中通过 `scaffold.sh` CLI 与生成的 `AGENTS.md` 文件来驱动。

非破坏性:已存在的文件会被跳过,可安全重跑。

### 需另外安装的组件(审计会检查,但脚本不生成)

- **OpenSpec CLI**:`npm i -g @fission-ai/openspec@latest`(脚手架会自动跑 `openspec init`)
- **Superpowers 技能集**:brainstorm、writing-plans、executing-plans、code-review、verification-before-completion
- **`frontend-design` skill**(仅前端项目)

随后填写 `openspec/project.md`、`openspec/specs/*` 及各栈 `CLAUDE.md` / `AGENTS.md` 中的 `[方括号]` 占位符。

## 审计现有项目

触发 skill(如"审计我的项目结构")。它会执行 Phase 0(环境 E1–E4)+ Phase 1(32 项检查),输出诊断表、成熟度等级、Top 问题与行动计划。

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

当单个 `CLAUDE.md` 混合多个技术栈,或审计分数偏低时:触发 skill 把它拆分为按栈分离的 Agent `CLAUDE.md`,根文件重写为导航中心,并按 Phase 5 顺序执行重构。

## 许可证

见 [LICENSE](LICENSE)。
