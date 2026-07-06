# loop-eng-cc 对话剧本 · 新项目 & 老项目操作手册

> 本手册以「**用户说 → AI 做**」的对话形式,说明在新项目和老项目中如何用 `loop-eng-cc` skill 搭建 / 接入 Loop 工程(OpenSpec + Superpowers + Harness)。
>
> 三种触发方式:① **直接跑 CLI**(`scaffold.sh`);② **自然语言让 AI(Claude)代劳**——AI 会调用对应 skill 模式或 CLI;③ **Claude Code 直接 `/loop-eng-cc`**——skill 装在 `~/.claude/skills/loop-eng-cc/`(或项目 `.claude/skills/`)后即可用,激活后再说明任务(scaffold/audit/restructure),模式由意图自动判定。
>
> 关键心法:**OpenSpec 定方向(WHAT)、Superpowers 强纪律(HOW)、Harness 编协作(WHO)**;每个功能走闭环 `propose → apply → verify → archive`,这就是 "Loop"。
>
> 剧本约定:**用户** = 看本手册并下指令的人;**AI** = 执行指令的 Claude(即 loop-eng-cc skill 的承载者)。

## 三种模式速查

| 用户想做的事 | CLI 命令 | 或对 AI 说 |
|:--|:--|:--|
| 预览会生成哪些文件 | `./scaffold.sh list` | "预览脚手架会生成什么" |
| 生成完整框架 | `./scaffold.sh myapp` | "给 myapp 搭 loop 脚手架" |
| 自检环境 | `./scaffold.sh check` | "自检 loop-eng-cc 环境" |
| 审计项目合规度 | `./scaffold.sh check ./myapp` | "审计 ./myapp 的 OSH 合规度" |
| 拆分单体 CLAUDE.md | skill restructure 模式 | "把 CLAUDE.md 拆成按栈的 agent" |
| 全量 32 项审计 | skill audit 模式 | "对项目做完整 32 项审计" |

---

## 场景一:新项目(从零搭建)

### 对话 1 · 生成脚手架

**用户**:
> 新项目 myapp,技术栈后端 Spring Boot 3 + 前端 Vue3,搭一个 loop 工程框架,放到 `./myapp`。

**AI**:确认技术栈后执行:
```bash
./scaffold.sh myapp --stacks backend,frontend --dir ./myapp
```
自动跑 `openspec init` 并生成 `openspec/`、`.claude/`、`backend/CLAUDE.md`、`frontend-web/CLAUDE.md`、根 `CLAUDE.md`。然后 AI 列出待填占位符与需另装的组件(Superpowers 技能集 `brainstorming`/`writing-plans`/`executing-plans`/`requesting-code-review`/`verification-before-completion` 复制到 `.claude/skills/`、`frontend-design` skill)。scaffold 同时生成 `CLAUDE.md`(Claude Code)与 `AGENTS.md`(Codex)双入口镜像。

> 只想看不落地:`./scaffold.sh list --stacks backend,frontend`

### 对话 2 · 填业务内容

**用户**:
> myapp 是图书借阅系统:后端 Java17 + MyBatis + MySQL8,前端 Vue3 + Element Plus。请把 `openspec/project.md` 和各栈 `CLAUDE.md` 的占位符填了。

**AI**:读取用户提供的信息,填充 `openspec/project.md`(系统说明 / 技术栈表 / 模块图 / 架构)、`backend/CLAUDE.md` 与 `frontend-web/CLAUDE.md` 的 `[方括号]` 占位,并把业务上下文与技术栈写入根 `CLAUDE.md`。

### 对话 3 · 审计校验

**用户**:
> 审计 `./myapp` 合规度。

**AI**:跑 `./scaffold.sh check ./myapp`(快速审计,22 项 = 3 环境自检 + 19 结构合规);要更细则进 skill audit 模式跑全量 32 项(E1–E4 / O1–O8 / S1–S9 / H1–H11),给出成熟度等级 + 修复清单。

### 对话 4 · 开始第一个功能(进入 Loop 循环)

**用户**(在 `backend/` 目录起会话):
> `/opsx:propose add-book-borrow`

**AI**:自动触发 Superpowers brainstorm → 向用户澄清需求 → 写 `openspec/changes/add-book-borrow/{proposal,spec}.md`(含 WHEN/THEN)→ 用户确认后 `/opsx:apply` 按 TDD 实现 → `/opsx:verify` 三层验证(L1 构建/L2 spec 对齐/L3 测试,写 `verify.md` 凭证)→ `/opsx:archive` 凭证门禁归档。无需用户手动喊 Superpowers,斜杠命令已预置触发。

---

## 场景二:老项目(接入 / 重构)

### 对话 1 · 先自检 + 审计现状

**用户**:
> 老项目在 `./legacy`,有个单体 `CLAUDE.md`,想接入 loop 工程。先看现状。

**AI**:① `./scaffold.sh check`(环境自检);② `./scaffold.sh check ./legacy`(结构合规度);③ 进 skill audit 模式做全量 32 项审计。产出:诊断表 + 成熟度 + Top 问题 + 行动计划(按 Phase 5 顺序)。

### 对话 2 · 拆分单体 CLAUDE.md

**用户**:
> 把 `./legacy` 的单体 `CLAUDE.md` 拆成按技术栈的 agent 文件。

**AI**:进入 skill **restructure** 模式:
1. 读单体 `CLAUDE.md`,按栈分类段落(Java 段落→backend、Vue 段落→frontend、API 路径→`openspec/specs/`、构建命令按工具分流);
2. 跟用户确认技术栈与目录映射;
3. 生成各栈 `CLAUDE.md`(含 Role / `NEVER` 跨域禁令 / Superpowers 五步 / TDD / Build);
4. 重写根 `CLAUDE.md` 为导航中心(≤120 行);
5. 删重复、校验无内容丢失、无死文件。

### 对话 3 · 为已有代码补 spec

**用户**:
> `legacy` 里已有 user 模块后端代码,但没 spec。请把它的 API 契约反向补进 `openspec/specs/`。

**AI**:读现有 user 模块代码与接口,抽取为 `openspec/specs/api/spec.md`、`data/spec.md`、`errors/spec.md`(补 WHEN/THEN 场景),让 spec 成为前后端共同真相。后续改动一律走 `/opsx:propose` 增量,不再裸改代码。

### 对话 4 · 审计验证

**用户**:
> 重构完再审计一次 `./legacy`。

**AI**:重跑 `./scaffold.sh check ./legacy` + 全量审计,对比前后成熟度,确认:无重复、无死文件、各 agent 含必备 8 段、跨域禁令显式、根 `CLAUDE.md` ≤120 行。

---

## 场景三:日常 Loop 循环(新 / 老通用)

每个功能都走闭环,Superpowers 由 OpenSpec 命令自动触发:

| 阶段 | 用户输入 | AI 做 |
|:--|:--|:--|
| 提案 | `/opsx:propose <change>` | brainstorm 澄清 → 写 proposal + spec(WHEN/THEN) |
| 实现 | `/opsx:apply` | TDD:红→绿→重构,前后端跨域隔离、mock 优先 |
| 验证 | `/opsx:verify` | 三层验证(L1 构建 / L2 spec 对齐 / L3 测试),写 `verify.md` 凭证 |
| 归档 | `/opsx:archive` | 检查 `verify.md` 门禁后移入 `openspec/archive/` |

会话保持:`/resume`、`/branch`、`/rewind`。

---

## 速查:可直接复制的命令

```bash
# 新建(默认 backend+frontend,自动 openspec init)
./scaffold.sh <name> --dir ./<name>

# 三栈(web + mobile)
./scaffold.sh <name> --stacks backend,frontend,frontend-mobile

# 预览不落地
./scaffold.sh list --stacks backend,frontend

# 自检环境
./scaffold.sh check

# 审计项目
./scaffold.sh check ./<project>

# 跳过 init(稍后手动 openspec init)
./scaffold.sh <name> --no-init
```

**让 AI 代劳**:直接说"用 loop-eng-cc 给 X 搭脚手架 / 审计 X / 把 X 的 CLAUDE.md 拆开",AI 会选对应模式或 CLI 执行。

## 成熟度评分参考

`check` 输出 `通过/总数 (百分比)`,对应等级:

| 百分比 | 等级 |
|:--|:--|
| < 33% | 基础建设前 |
| 33–66% | 基础级 |
| 66–90% | 质量级 |
| > 90% | 工业级 |

> `check` 是 CLI 快照(22 项可自动判定:3 环境自检 + 19 结构合规,含 O7 CJK 扫描、S5 Superpowers 检测、O4 归档错位检测);完整 32 项审计(含 S3 工作流、H4 工作树等需语义判断的项)请让 AI 进 skill audit 模式。
