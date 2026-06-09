# audit-osh-skills

中文文档 | [English](README.md)

---

## 概述

本仓库包含两个用于优化AI协作的 Skills，基于工业级三层架构范式（OpenSpec + Superpowers + Harness）：

1. **`audit-osh`** — 审计和优化现有项目结构，符合OSH标准
2. **`split-help`** — 将单体 CLAUDE.md 拆分为按技术栈分离的 Agent 文件

**核心理念：**
- **OpenSpec** 定义方向（WHAT）
- **Superpowers** 强制执行规范（HOW）
- **Harness** 编排协作（WHO）

---

## 功能特性

## 1. 项目结构审计（24项检查）

对项目进行全面审计，覆盖三个核心层面：

### 1.1 OpenSpec — "定义方向" (O1–O7)

| 编号 | 检查项 | 标准 |
|:--|:---|:---|
| O1 | 共享规范文档 | `openspec/specs/` 包含 api/spec.md + data/spec.md + errors/spec.md |
| O2 | API契约权威性 | 所有代理引用它；前端基于它mock；后端实现它 |
| O3 | 变更提案模板 | `openspec/changes/_template/` 包含 proposal.md + spec.md |
| O4 | 变更归档 | `openspec/archive/` 用于完成的提案 |
| O5 | 项目概览 | `openspec/project.md`：技术栈、模块地图、架构 |
| O6 | 边界清晰 | `openspec/README.md` 说明结构：specs/ 在 openspec/ 内部统一入口 |
| O7 | 语言效率 | CLAUDE.md、specs/、openspec/ 文件使用英文 |

### 1.2 Superpowers — "强制纪律" (S1–S9)

| 编号 | 检查项 | 标准 |
|:--|:---|:---|
| S1 | 代理角色声明 | 每个 CLAUDE.md 以 "You are a [Stack] [Role] Agent" 开头 |
| S2 | 跨域禁止 | 每个代理声明 "NEVER generate frontend/backend code" |
| S3 | Superpowers工作流 | 5步：brainstorm → writing-plans → executing-plans → code-review → verification。**自动触发** |
| S4 | 项目规则with globs | `.claude/rules/` 通过文件路径匹配自动加载 |
| S5 | 领域技能 | `.claude/skills/` 带 YAML frontmatter；每个最多300行 |
| S6 | 权限配置 | `.claude/settings.json` 包含 allow/deny 列表 |
| S7 | 钩子配置 | SessionStart、PreToolUse、Stop 钩子 |
| S8 | 自定义代理 | Reviewer（仅Read+Bash）+ coordinator 在 settings.json |
| S9 | 上下文预算 | 代理 CLAUDE.md < 3K tokens；细节在 skills/ |

### 1.3 Harness — "编排协作" (H1–H11)

| 编号 | 检查项 | 标准 |
|:--|:---|:---|
| H1 | 工作空间分离 | 每个技术栈一个子目录，独立 CLAUDE.md |
| H2 | 共享规范可访问 | 所有代理引用 `../openspec/specs/` |
| H3 | Mock优先前端 | 前端基于API契约mock（MSW） |
| H4 | Git工作树隔离 | 功能在隔离的工作树中 |
| H5 | 根CLAUDE.md是导航中心 | ≤ 120行；项目地图 + 构建 + 会话命令 |
| H6 | 会话管理 | `/resume`、`/branch`、`/rewind` 保持连续性 |
| H7 | 无死文件 | 每个 .md 有明确的加载/触发路径 |
| H8 | 零重复 | 没有规则在两个自动加载文件中 |
| H9 | 危险命令禁止 | `rm -rf`、`git push --force`、`git reset --hard` 在 deny 列表 |
| H10 | 钩子配置 | SessionStart + PreToolUse + Stop 钩子 |
| H11 | 自定义代理定义 | Reviewer（仅Read+Bash）+ Coordinator 在 settings.json |

---

## 2. 成熟度评分系统

### 差距计算
```
OpenSpec得分    = O_yes / 7
Superpowers得分 = S_yes / 9
Harness得分     = H_yes / 11

总体得分 = (O_yes + S_yes + H_yes) / 27
```

### 成熟度等级
| 得分范围 | 等级 |
|:--|:---|
| < 33% | 基础建设前 |
| 33–66% | 基础级 |
| 66–90% | 质量级 |
| > 90% | 工业级 |

### 上下文效率目标
- 缩减率：> 3x（前后对比）
- 单代理上下文：< 150行（约3K tokens）

### 3. 优化方案（6个修复）

| 修复 | 行动 | 解决 |
|:--|:---|:---|
| 1 | 创建 `openspec/`（包含 `specs/` 在内部）+ 模板 + project.md + READMEs | O1–O7 |
| 2 | 将自动加载文件翻译为英文 | O7 |
| 3 | 按技术栈编写 Agent CLAUDE.md | S1–S3,S9,H1–H3 |
| 4 | 添加 `.claude/rules/`（带 globs frontmatter） | S4,S5 |
| 5 | 编写 `.claude/settings.json` | S6–S8 |
| 6 | 验证：重新审计、测试钩子、测试审查器 | 所有 |

### 执行顺序（Phase 5）
**不要重新排序：**
1. 创建 `openspec/`（包含 specs/ 在内部）
2. 创建 `.claude/`（rules + skills + settings.json）
3. 创建 agent CLAUDE.md（每个技术栈一个）
4. 重写根 CLAUDE.md（仅导航中心）
5. 删除死文件（AGENTS.md、重复文件）
6. 验证无重复

### 4. 目标结构模板
提供完整的 Monorepo 目标结构：
```
project/
├── CLAUDE.md                     # 导航中心：≤120 行
├── openspec/                     # 统一规范管理（specs 在内部，统一入口）
│   ├── README.md                 # 结构说明 + 职责分离
│   ├── project.md                # 业务背景、架构（无编码规范）
│   ├── specs/                    # 静态契约（在 openspec 内部）
│   │   ├── README.md             # 共享真相说明
│   │   ├── api-contract.md
│   │   ├── data-model.md
│   │   └── error-codes.md
│   ├── changes/                  # 动态变更
│   │   ├── _template/            # proposal.md + spec.md
│   │   └── <active-change>/      # 进行中的工作
│   └── archive/                  # 已完成的变更
├── .claude/
│   ├── settings.json             # 权限 + 钩子 + 代理
│   ├── rules/                    # 自动加载（globs）
│   └── skills/<name>/SKILL.md    # ≤300 行
├── {backend}/CLAUDE.md           # 后端代理
├── {frontend}/CLAUDE.md          # 前端代理
└── {mobile}/CLAUDE.md            # 移动端代理
```

**关键改进：**
- `specs/` 在 `openspec/` 内部，提供统一入口
- `openspec/README.md` 清晰说明职责分离
- 更简单的心理模型："openspec/ 包含所有规范相关内容"

### 5. 反模式快速参考

| 反模式 | 修复 |
|:---|:---|
| 单体 CLAUDE.md（250+行，多技术栈） | 拆分为按目录的 CLAUDE.md |
| AGENTS.md 存在 | 删除（Claude Code 从不读取它） |
| 规范内联在 CLAUDE.md 中 | 提取到 `openspec/specs/` |
| CSS/SCSS 在 CLAUDE.md 中 | 移到 `.claude/skills/` |
| 重复规则在 CLAUDE.md + rules/ | 仅保留在 rules/ |
| 风格指南在 docs/ 给AI | 移到 `.claude/skills/` 自动触发 |
| 无角色声明 | 添加 "## Role: You are a [X] Agent" |
| 无跨域禁止 | 添加 "NEVER generate [X] code" |
| TDD作为纯文本 | 添加 Superpowers 5步工作流（自动触发） |
| 所有技能激活 | 技能在 `.claude/skills/` — 仅按需 |
| 空 changes/ 目录 | 创建 `_template/proposal.md` + `spec.md` |
| Reviewer 有 Write/Edit | Reviewer 工具 = `["Read", "Bash"]` 仅 |
| 规范用中文（自动加载） | 使用英文 — 节省30–50% token |
| 根 CLAUDE 有代理规则 | 根 = 导航中心；规则在子 CLAUDE.md |
| 修改现有代码 | 仅重载或新方法 |
| 忽略上下文窗口 | CLAUDE.md < 3K tokens；技能按需加载 |
| specs/ 在根目录（标准OSH） | 移到 `openspec/specs/` 统一入口 |
| 无危险命令禁止 | 添加 `rm -rf`、`git push --force` 到 permissions.deny（H9） |
| 无钩子配置 | 添加 SessionStart + PreToolUse + Stop 钩子（H10） |
| 无自定义代理定义 | 添加 reviewer + coordinator 到 settings.json agents（H11） |
| Reviewer 可修改代码 | Reviewer 工具必须是 `["Read", "Bash"]` 仅 |

---

## 使用方法

### 审计现有项目

1. **发现**：列出项目根目录，识别所有 CLAUDE.md、`.claude/`、`specs/`、`openspec/`
2. **读取**：读取每个 CLAUDE.md（根目录 + 子目录）、`.claude/settings.json`、`specs/` 和 `openspec/` 文件
3. **审计**：对以下 24 项检查进行评分（YES / PARTIAL / NO）
4. **报告**：按 Phase 6 格式输出，为每个差距引用修复编号
5. **应用**（用户确认后）：按确切顺序执行 Phase 5，不要重新排序

### 新项目快速启动

```bash
mkdir -p project/openspec/{specs,changes/_template,archive}
mkdir -p project/.claude/{rules,skills}
mkdir -p project/backend project/frontend-web
# 然后按 Fix 1 模板写入所有文件
# 最后删除 AGENTS.md，运行 Phase 1 审计验证
```

---

## 输出格式

审计完成后，生成以下输出：

1. **诊断表** — 所有 24 项检查及 YES/PARTIAL/NO 评分 + 各层得分
2. **成熟度等级** — 总体百分比 + 等级标签
3. **前后指标** — 上下文效率比（目标 > 3x）
4. **前 3 个问题** — 根本原因 + 修复引用 + 影响估计
5. **目标结构** — 目录树
6. **行动计划** — 按 Phase 5 排序

---

## 验证清单

- [ ] 自动加载文件为英文
- [ ] 根 CLAUDE.md ≤ 120行，仅导航中心
- [ ] 每个子 CLAUDE.md：角色 + 概览 + 编码前 + 标准 + Superpowers + TDD + 构建
- [ ] 每个子 CLAUDE.md 中明确禁止跨域
- [ ] openspec/specs/api/spec.md 对所有代理具有权威性
- [ ] openspec/README.md 说明结构 + 职责分离
- [ ] openspec/changes/_template/ 包含 proposal.md + spec.md
- [ ] .claude/settings.json 包含权限 + 钩子 + 代理
- [ ] 审查器工具 = `["Read", "Bash"]` 仅
- [ ] 规则使用 globs；技能 ≤ 300行
- [ ] 配置 Git 工作树隔离
- [ ] 记录会话管理（`/resume`、`/branch`、`/rewind`）
- [ ] 删除 AGENTS.md
- [ ] 自动加载文件间零重复
- [ ] 每个子 CLAUDE.md < 3K token
- [ ] specs/ 在 openspec/ 内部（统一入口）
- [ ] 危险命令在 permissions.deny（H9）：`rm -rf`、`git push --force`、`git reset --hard`
- [ ] 钩子配置（H10）：SessionStart + PreToolUse + Stop
- [ ] 自定义代理定义（H11）：reviewer + coordinator 在 settings.json

---

## Superpowers 工作流

Superpowers 工作流强制执行 TDD 纪律，在发出开发请求时**自动触发**：

1. **brainstorming** — AI 提出澄清问题
2. **writing-plans** — AI 生成任务列表
3. **executing-plans** — AI 用 TDD 实现任务
4. **code-review** — AI 对照规范审查
5. **verification-before-completion** — AI 在标记完成前运行测试

**强制TDD**：先写失败的测试 → 实现 → 重构

> **注意**：Superpowers 没有 slash 命令。当你发出开发请求或使用 OpenSpec 命令（`/opsx:propose`、`/opsx:apply`）时，它会自动触发。

### OpenSpec-Superpowers 集成

**OpenSpec 命令如何自动触发 Superpowers：**

```
用户: /opsx:propose add-login-feature
        │
        ▼
Harness 读取 .claude/commands/opsx:propose
        │
        ▼
命令文件包含 "activate Superpowers brainstorming"
        │
        ▼
Superpowers brainstorming 技能自动触发
        │
        ▼
AI 开始提出澄清问题（TDD 流程开始）
```

**关键洞察**：`openspec init` 生成预置 Superpowers 触发器的命令文件。这是 OpenSpec 和 Superpowers 之间的"集成协议"。

---

## 关键原则

- **规范即代码**：将规范视为代码库的一部分
- **强制执行TDD**：不只是口号，而是强制流程
- **技能按需加载**：避免所有技能同时激活
- **禁止跨域**：前端不生成后端代码，反之亦然
- **单一真相源**：所有代理引用相同的规范文档
- **英文自动加载文件**：相比中文可节省 30-50% token

---

## 适用场景

- 新项目启动：建立规范的 AI 协作结构
- 现有项目优化：审计并改进现有协作流程
- 团队协作标准化：确保多代理间的协作一致性
- 代码质量提升：通过结构化规范减少错误和返工

---

# Skill 2: split-help

## 概述

`split-help` 是一个用于将单体 CLAUDE.md（由 `/init` 生成）拆分为按目录分离的 Agent CLAUDE.md 文件的 Skill，每个技术栈一个文件，包含正确的角色声明、跨域禁止规则、Superpowers 工作流和 TDD 纪律。

## 为什么重要

`/init` 将整个项目视为一个工作空间。它将 Java/MyBatis 模式和 Vue/Element Plus 模式放在一起。当 AI 读取时会产生混淆 —— 在修复 CSS bug 时看到 Java DI 模式。每个 Agent 应只看到自己的领域。

## 适用场景

- 在多技术栈 monorepo 上运行 `/init` 后
- 单个 CLAUDE.md 有 200+ 行涵盖多个技术栈
- 向现有项目添加新技术层时

## 工作流程

### Phase 1: 发现

1. **读取单体文件**：完整读取根 CLAUDE.md。识别并分类每个部分：
   - 业务背景 → 根 CLAUDE.md（导航）+ `openspec/project.md`
   - 构建命令 → 按栈分离的 Agent 文件
   - 代码模式 → 按栈分离的 Agent 文件
   - API路径 → `specs/api-contract.md`
   
2. **与用户确认**：呈现发现结果，在继续之前请求确认

### Phase 2: 生成 Agent CLAUDE.md 文件

为每个技术栈生成 `{code-directory}/CLAUDE.md`，包含：
- **角色**：明确声明（如 "You are a Backend Agent"）
- **NEVER规则**：跨域禁止
- **项目概览**：一行系统描述 + 技术栈
- **编码前**：规范优先 + mock 优先工作流
- **模块结构**：仅该栈的目录树
- **编码标准**：栈特定模式
- **Superpowers工作流**：5步命令序列
- **TDD**：强制执行，由 Superpowers 保证
- **构建命令**：栈特定命令

### Phase 3: 重写根 CLAUDE.md

生成所有 Agent 文件后，将根 CLAUDE.md 重写为导航中心：
- 项目地图（目录树）
- 业务背景（1-3 句）
- 技术栈（一行表格）
- 开发工作流
- 构建&测试命令（最小化）

**大小规则**：根 CLAUDE.md ≤ 120行

### Phase 4: 验证

生成后验证：
- 无内容丢失
- 自动加载文件间无重复
- 每个 Agent 文件包含所有必需部分
- 跨域禁止明确
- 路径引用正确
- 根 CLAUDE.md 是导航中心（≤ 120行）

## 反模式修复

| 反模式 | 修复 |
|:---|:---|
| 业务背景在每个 Agent 文件中 | 仅一行"System"；完整背景在根目录 |
| API路径在 Agent 文件中 | 提取到 `specs/api-contract.md` |
| 重复构建命令 | 每个命令在仅一个 Agent 文件中 |
| Mobile + desktop在一个Agent文件 | 分离 —— 不同UI范式 |
| 无角色声明 | 必须是 "## Role: You are a [Stack] [Role] Agent" |
| 无TDD部分 | 总是添加 Superpowers Workflow + TDD 部分 |
| 根 CLAUDE.md > 120行 | 将内容移到 Agent 文件或 `openspec/project.md` |
