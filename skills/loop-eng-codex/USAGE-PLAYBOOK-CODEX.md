# loop-eng-codex 对话剧本 · Codex 版操作手册

> 本手册以「**用户说 → AI 做**」的对话形式,说明在 Codex 中如何用 `loop-eng-codex` skill 搭建 / 接入 Loop 工程(OpenSpec + Superpowers + Harness)。
>
> 它是 [USAGE-PLAYBOOK.md](../loop-eng-cc/USAGE-PLAYBOOK.md)(Claude Code 版)的 Codex 对应版。两者骨架一致,差异在于入口文件与命令形态:`openspec init --tools codex` 为 Codex 生成项目内 `.codex/skills/openspec-*` 技能,用 `$skill-name` 调用(如 `$openspec-propose` / `$openspec-apply-change` / `$openspec-archive-change`)+ `openspec` CLI + 自然语言;Superpowers 纪律则写进 `AGENTS.md` 作为指令。
>
> 关键心法不变:**OpenSpec 定方向(WHAT)、Superpowers 强纪律(HOW)、Harness 编协作(WHO)**;每个功能走闭环 `propose → apply → verify → archive`(页面/UI 开发时,apply 前先 `design` HTML 原型),这就是 "Loop"。
>
> 剧本约定:**用户** = 看本手册并下指令的人;**AI** = 执行指令的 Codex(即 loop-eng-codex skill 的承载者)。

---

## Codex 与 Claude 版差异速查

| 维度 | Claude Code 版 | Codex 版(本手册) |
|:--|:--|:--|
| 触发 skill | `/loop-eng-cc` 斜杠命令 或 自然语言 | `$loop-eng-codex` 显式调用 或 按 `description` 自动触发 |
| 入口文件 | `CLAUDE.md` | `AGENTS.md`(`CLAUDE.md` 是镜像,Codex 不读) |
| 提案/应用/验证/归档 | `/opsx:propose` / `apply` / `verify` / `archive` 斜杠命令 | 用 `$openspec-propose` / `$openspec-apply-change` / `$openspec-verify` / `$openspec-archive-change`(`$` 技能)或 `openspec` CLI |
| 纪律(Superpowers) | `.claude/skills/` 里五个技能,由斜杠命令自动触发 | 纪律写进 `AGENTS.md` 作为指令(不依赖插件),AI 按上下文遵循 |
| 会话续接 | `/resume` `/branch` `/rewind` | Codex 自身 goal/plan + 自然对话续接 |
| openspec init | `--tools claude`(默认) | `--tools codex`(默认) |
| 工具目录 | `.claude/`(rules / skills / agents / settings) | `.codex/`(skills / openspec-*) |

> scaffold.sh **总会**同时生成 `CLAUDE.md` 与 `AGENTS.md`(内容镜像)。纯 Codex 项目里 `CLAUDE.md` 是死文件,可留着备用或删;编辑只动 `AGENTS.md`。
>
> Codex 版 scaffold **只创建 `.codex/`**(openspec 技能 + verify skill + trigger 注入),不创建 `.claude/` 目录。两版 scaffold 各管各的工具目录,不交叉创建。
>
> `openspec init` 不含 verify——loop-eng 脚手架额外创建 `$openspec-verify` 技能(三层验证)并注入到 apply/archive 的触发链,使闭环 `propose → apply → verify → archive` 自动衔接。

---

## 三种模式速查

| 用户想做的事 | CLI 命令 | 或对 AI 说 |
|:--|:--|:--|
| 预览会生成哪些文件 | `./scaffold.sh list` | "预览脚手架会生成什么" |
| 生成完整框架(Codex 入口) | `./scaffold.sh myapp --tools codex` | "给 myapp 搭 loop 脚手架,Codex 优先" |
| 自检环境 | `./scaffold.sh check` | "自检 loop-eng-codex 环境" |
| 审计项目合规度 | `./scaffold.sh check ./myapp` | "审计 ./myapp 的 OSH 合规度" |
| 拆分单体入口文件 | skill restructure 模式 | "把 AGENTS.md 拆成按栈的 agent" |
| 全量 32 项审计 | skill audit 模式 | "对项目做完整 32 项审计" |

> **如何触发:** 把 `loop-eng-codex/` 放进 `~/.codex/skills/loop-eng-codex/` 后重启 Codex,skill 会按 `description` 自动激活。也可用 `$loop-eng-codex` 显式调用,或直接说"用 loop-eng-codex 给 X 搭脚手架",AI 会选对应模式或 CLI 执行。

---

## 场景一:新项目(从零搭建)

### 对话 1 · 生成脚手架

**用户**:
> 新项目 myapp,技术栈后端 Spring Boot 3 + 前端 Vue3,搭一个 loop 工程框架,放到 `./myapp`,Codex 优先。

**AI**:确认技术栈后执行:
```bash
./scaffold.sh myapp --stacks backend,frontend --dir ./myapp --tools codex
```
自动跑 `openspec init --tools codex` 并生成 `openspec/`、`.codex/skills/`(openspec 技能 + verify skill + trigger 注入)、各栈 `AGENTS.md`(Codex 入口)+ `CLAUDE.md`(Claude 镜像)、根 `AGENTS.md` 导航中心。然后 AI 列出待填占位符与需另装的组件。

> 只想看不落地:`./scaffold.sh list --stacks backend,frontend`
> 双工具(同一项目同时用 Claude + Codex):`--tools codex,claude` 让 `openspec init` 生成两套指令文件,但本 scaffold 只往 `.codex/` 注入 LoopEng 增强(trigger / verify)。`.claude/` 的完整增强需另跑 CC 版 scaffold。

### 对话 2 · 填业务内容

**用户**:
> myapp 是图书借阅系统:后端 Java17 + MyBatis + MySQL8,前端 Vue3 + Element Plus。请把 `openspec/project.md` 和各栈 `AGENTS.md` 的占位符填了。

**AI**:读取用户提供的信息,填充 `openspec/project.md`(系统说明 / 技术栈表 / 模块图 / 架构)、`backend/AGENTS.md` 与 `frontend-web/AGENTS.md` 的 `[方括号]` 占位,并把业务上下文与技术栈写入根 `AGENTS.md`。

> 纯 Codex 项目:只改 `AGENTS.md`;若你也在 Claude Code 里开同一项目,记得把镜像的 `CLAUDE.md` 同步(scaffold 已镜像,后续手动改动需自己保持一致)。

### 对话 3 · 审计校验

**用户**:
> 审计 `./myapp` 合规度。

**AI**:跑 `./scaffold.sh check ./myapp`(快速审计)。要更细则进 skill audit 模式跑全量 32 项(E1–E4 / O1–O8 / S1–S9 / H1–H11),给出成熟度等级 + 修复清单。

> **`check` 是 Codex-aware 的**:E3 探测根 `AGENTS.md`、E4 探测前端 `AGENTS.md` 的设计指引、H9 探测 `AGENTS.md` 里的 sandbox/approval 关键词;S4/S5/S6/S8 同理——`.claude/` 路径(`settings.json`/`rules`/`skills`/`agents`)只是 Claude 的可选加分项。纯 Codex 项目只要 `AGENTS.md` 写到位,这些项都能 PASS,不存在 `.claude` 误报,分数如实看即可。

### 对话 4 · 开始第一个功能(进入 Loop 循环)

Claude 版用 `/opsx:propose` 斜杠命令;**Codex 版用 `$openspec-propose`(`$` 技能)或 `openspec` CLI + 自然语言**:

**用户**(在 `backend/` 目录起会话):
> 给 myapp 提一个"图书借阅"功能变更,走 loop 流程。

**AI**:
1. **提案(propose)** —— 先澄清需求(遵循 AGENTS.md 里的 brainstorm 纪律),然后:
   ```bash
   openspec new change add-book-borrow      # 生成 changes/add-book-borrow/ 目录与模板
   openspec instructions --change add-book-borrow   # 输出该 artifact 的富化指引
   ```
   填写 `proposal.md`、`spec.md`,写明 WHEN/THEN 场景(它们就是后面 verify 的 L2 用例)。
2. **实现(apply)** —— 按 `tasks.md` 用 TDD(红→绿→重构)实现,前后端跨域隔离、mock 优先;每完成一个任务跑该栈构建命令做 L1 快检。
3. **验证(verify)** —— 调 `$openspec-verify` 技能(或手动三层):
   - L1 构建:跑各栈 build 命令(配置在 `openspec/verify.config.yaml`)
   - L2 spec 对齐:`openspec validate add-book-borrow`
   - L3 测试:跑测试套件
   - 把结果写入 `verify.md`(用 `openspec/verify-result.template.md` 模板,YAML frontmatter 里 `overall` 字段须可机读,归档门禁会查它)
4. **归档(archive)** —— `verify.md` 显示 `PASS` 后:
   ```bash
   openspec archive add-book-borrow         # 归档并更新主 specs
   ```

> 没有 Superpowers 技能自动触发,但 AGENTS.md 已把"brainstorm → 写计划 → 执行 → code review → 完成前验证"写成指令,AI 按上下文遵循即可。你也可直接喊"先 brainstorm 一下需求"来强化。

---

## 场景二:老项目(接入 / 重构)

### 对话 1 · 先自检 + 审计现状

**用户**:
> 老项目在 `./legacy`,有个单体 `AGENTS.md`(或 `CLAUDE.md`),想接入 loop 工程。先看现状。

**AI**:① `./scaffold.sh check`(环境自检);② `./scaffold.sh check ./legacy`(结构合规度);③ 进 skill audit 模式做全量 32 项审计。产出:诊断表 + 成熟度 + Top 问题 + 行动计划(按 Phase 5 顺序)。

> `check` 对纯 Codex 项目同样适用:E3/E4/H9 经 `AGENTS.md` 判定,不依赖 `.claude/`(见场景一对话 3)。

### 对话 2 · 拆分单体入口文件

**用户**:
> 把 `./legacy` 的单体 `AGENTS.md` 拆成按技术栈的 agent 文件。

**AI**:进入 skill **restructure** 模式:
1. 读单体 `AGENTS.md`,按栈分类段落(Java 段落→backend、Vue 段落→frontend、API 路径→`openspec/specs/`、构建命令按工具分流);
2. 跟用户确认技术栈与目录映射;
3. 生成各栈 `AGENTS.md`(含 Role / `NEVER` 跨域禁令 / Superpowers 五步纪律 / TDD / Build);
4. 重写根 `AGENTS.md` 为导航中心(≤120 行);
5. 删重复、校验无内容丢失、无死文件。

> 纯 Codex:以 `AGENTS.md` 为主拆分对象;若同时用 Claude,再镜像出对应 `CLAUDE.md`。

### 对话 3 · 为已有代码补 spec

**用户**:
> `legacy` 里已有 user 模块后端代码,但没 spec。请把它的 API 契约反向补进 `openspec/specs/`。

**AI**:读现有 user 模块代码与接口,抽取为 `openspec/specs/api/spec.md`、`data/spec.md`、`errors/spec.md`(补 WHEN/THEN 场景),让 spec 成为前后端共同真相。后续改动一律走 `openspec new change` 增量,不再裸改代码。

### 对话 4 · 审计验证

**用户**:
> 重构完再审计一次 `./legacy`。

**AI**:重跑 `./scaffold.sh check ./legacy` + 全量审计,对比前后成熟度,确认:无重复、无死文件、各 agent 含必备 8 段、跨域禁令显式、根 `AGENTS.md` ≤120 行。

---

## 场景三:日常 Loop 循环(新 / 老通用)

每个功能都走闭环。Codex 版用 `$` 技能(`$openspec-propose`/`$openspec-apply-change`/`$openspec-verify`/`$openspec-archive-change`)或 `openspec` CLI 驱动,纪律由 AGENTS.md 承载:

| 阶段 | 用户输入 | AI 做 |
|:--|:--|:--|
| 提案 | "提一个 X 变更" | 澄清需求 → `openspec new change <name>` → 填 proposal + spec(WHEN/THEN) |
| 设计 | "页面要做成什么样" | (仅页面/UI 开发,apply 前)先做 HTML 原型,两条路:① 纯代码优先 — 直接写 HTML/CSS(或 React+Tailwind/shadcn)→ `browser` 渲染 → `screenshot` 自检(简单页/快速原型最快);② `frontend-app-builder` skill — Codex 当资深前端设计师 → Image Gen 出视觉概念稿 → 用户确认 → 忠实实现成代码 → `browser` + `view_image` 对比到 10/10 还原(全程不碰 Figma)。主力栈:`build-web-apps`(`frontend-app-builder` + `shadcn-best-practices`)+ `browser` + `screenshot`;静态/单文件默认 HTML/CSS,复杂 app 才上 React+Vite |
| 实现 | "实现这个变更" | 按 tasks 用 TDD:红→绿→重构,前后端跨域隔离、mock 优先 |
| 验证 | "验证 <name>" | `$openspec-verify`(三层:L1 构建 + L2 spec 对齐 + L3 测试)→ 写 `verify.md` 凭证 |
| 归档 | "归档 <name>" | 查 `verify.md` 门禁(`overall: PASS`)→ `openspec archive <name>` |

常用 CLI 辅助:
```bash
openspec list                       # 列出活跃 changes
openspec show <name>                # 查看某个 change
openspec status --change <name>     # 看完成度
openspec validate --all             # 全量校验 changes + specs
openspec instructions --change <n>  # 取该 artifact 富化指引
```

> 会话续接:Codex 没有 `/resume` `/branch` `/rewind`。用 Codex 自身的 goal/plan 体系跟踪多步任务,普通对话天然续接;要"回到某状态"就开新会话并让 AI 先读 `openspec/` 与 `AGENTS.md` 恢复上下文。

---

## 场景四:跨栈功能协调(前后端联动)

当一个功能跨多个栈(如前端小程序 + 后端 Java,分属独立 git 仓库),单栈 change 不够:前端 agent 按跨域禁令正确排除后端,但"声明的后端依赖"没有归属,会被静默丢失(没人创建对应的兄弟 change)。scaffold.sh 对 ≥2 栈已自动建好协调层(context-store + workspace),用 OpenSpec 1.4.1 原生的 **initiative(父级)+ per-stack change(子级)** 模式解决。

### 对话 · 跨栈功能

**用户**:
> 技师任务详情页:前端小程序(ops_wechat)要调后端(ops_sev)的新接口。前端先做,后端另开提案。

**AI**:
1. **建父级 initiative**(跨仓库持久意图,= "子流程"的父):
   ```bash
   openspec initiative create task-flow --store ops-store --title "技师任务详情/历史全链路"
   ```
2. **前端 change**(ops_wechat 仓库内,挂到父级):
   ```bash
   cd ops_wechat
   openspec new change wechat-task-detail --initiative task-flow --store ops-store
   # proposal.md "后端依赖"节声明所需接口(POST /api/wechat/task/detail 等)
   # Scope Out: 后端接口实现(由 Backend Agent 另行提案)
   ```
3. **后端 change**(ops_sev 仓库内,兄弟提案):
   ```bash
   cd ops_sev
   openspec new change sev-task-detail-api --initiative task-flow --store ops-store
   # proposal.md 实现前端声明的接口
   ```
4. **各自实现**(跨域禁令不变;前端 mock 优先)→ 各自 `$openspec-verify` → 各自 `$openspec-archive-change`
5. **完成门禁**:`openspec status` 可见两个 change 都挂载到同一 initiative;全部 verify PASS → 功能才算完

> 协调会话(中立地,不写领域代码):`openspec workspace open --agent codex-cli`
> 跨栈的接口契约/设计决策放在 initiative 的 `design.md` / `decisions.md` 里,双方共享。

---

## 速查:可直接复制的命令

```bash
# 新建(Codex 优先,默认 backend+frontend,自动 openspec init)
./scaffold.sh <name> --dir ./<name> --tools codex

# 三栈(web + mobile)
./scaffold.sh <name> --stacks backend,frontend,frontend-mobile --tools codex

# 双工具(openspec init 生成 .codex/ + .claude/ 指令文件;LoopEng 增强只注入 .codex/)
./scaffold.sh <name> --tools codex,claude

# 预览不落地
./scaffold.sh list --stacks backend,frontend

# 自检环境
./scaffold.sh check

# 审计项目
./scaffold.sh check ./<project>

# 跳过 init(稍后手动 openspec init)
./scaffold.sh <name> --no-init

# 日常 loop($ 技能方式;或用 openspec CLI 对应命令)
$openspec-propose                    # 提案:澄清需求 → 写 proposal + spec
$openspec-apply-change               # 实现:按 tasks TDD
$openspec-verify                     # 三层验证(L1 构建/L2 spec 对齐/L3 测试)→ 写 verify.md
$openspec-archive-change             # verify.md overall=PASS → 归档
```

**让 AI 代劳**:直接说"用 loop-eng-codex 给 X 搭脚手架 / 审计 X / 把 X 的 AGENTS.md 拆开 / 提一个 X 变更并走 loop",AI 会选对应模式或 CLI 执行。

---

## 成熟度评分参考

`check` 输出 `通过/总数 (百分比)`,对应等级:

| 百分比 | 等级 |
|:--|:--|
| < 33% | 基础建设前 |
| 33–66% | 基础级 |
| 66–90% | 质量级 |
| > 90% | 工业级 |

> `check` 是 CLI 快照(含 O7 CJK 扫描、S5 Superpowers 检测、O4 归档错位检测等可自动判定项);完整 32 项审计(含 S3 工作流、H4 工作树等需语义判断的项)请让 AI 进 skill audit 模式。
>
> Codex 提示:`check` 是 Codex-aware 的——E3/E4/H9 经 `AGENTS.md` 判定(非 `.claude` 误报),S5 也优先看各栈 `AGENTS.md` 的深度指引(`.claude/skills/` 仅 Claude 加分项)。纯 Codex 项目无需扣项,分数如实反映 `AGENTS.md` 是否写到位。

---

## 附:把 skill 装进 Codex

```bash
cp -R skills/loop-eng-codex ~/.codex/skills/loop-eng-codex
```
`scaffold.sh` 已是 skill 目录内的实体文件,普通拷贝即可。重启 Codex 即可按 `description` 自动触发,或用 `$loop-eng-codex` 显式调用。`loop-eng-codex/` 目录里有 `SKILL.md`(必需,frontmatter `name`+`description`)+ `scaffold.sh`(CLI)。可选补 `agents/openai.yaml` 拿到界面显示名,不影响触发。
