<<<<<<< HEAD
# audit-osh

检查项目结构是否符合 OSH 架构。Audit and optimize a project's AI collaboration structure (CLAUDE.md, specs, skills, rules, agents) against the industrial-grade three-layer paradigm (OpenSpec + Superpowers + Harness).

---

## 概述

`audit-osh` 是一个用于审计和优化项目 AI 协作结构的 Skill。它基于工业级的三层架构范式（OpenSpec + Superpowers + Harness），帮助团队建立规范化的 AI 协作流程。

**核心理念：**
- **OpenSpec** 定义方向（WHAT）
- **Superpowers** 强制执行规范（HOW）
- **Harness** 编排协作（WHO）

---

## 功能特性

### 1. 项目结构审计
对项目进行 24 项全面检查，覆盖三个核心层面：

| 层面 | 检查项 | 说明 |
|:---|:---|:---|
| **OpenSpec** (O1-O7) | 共享规范文档、API 契约权威性、变更提案模板、变更归档、项目概览、边界清晰、语言效率 | 确保"做什么"有明确的共享真相 |
| **Superpowers** (S1-S9) | 代理角色声明、跨域禁止、Superpowers 命令链、项目规则、领域技能、权限配置、钩子配置、自定义代理、上下文预算 | 确保"怎么做"有严格的纪律 |
| **Harness** (H1-H8) | 工作空间分离、共享规范可访问、前端 Mock 优先、Git 工作树隔离、根导航中心、会话管理、无死文件、零重复 | 确保"谁来做"有清晰的编排 |

### 2. 差距评分系统
- 计算各层得分和总体得分
- 成熟度等级划分：
  - `< 33%` → 基础建设前
  - `33-66%` → 基础级
  - `66-90%` → 质量级
  - `> 90%` → 工业级
- 上下文效率目标：> 3x 缩减，单代理上下文 < 150 行

### 3. 优化方案生成
根据审计结果，生成 7 步优化方案：
1. 创建 `specs/` + API 契约、数据模型、错误码文档
2. 创建 `openspec/` + 模板 + project.md + README
3. 将自动加载文件翻译为英文
4. 按技术栈编写 Agent CLAUDE.md
5. 添加 `.claude/rules/` 规则（带 globs 前置元数据）
6. 编写 `.claude/settings.json`
7. 验证：重新运行审计、测试钩子、测试审查器

### 4. 目标结构模板
提供完整的 Monorepo 目标结构：
```
project/
├── CLAUDE.md                     # 导航中心：≤120 行
├── openspec/                     # SDD 增量工作流
│   ├── README.md
│   ├── project.md
│   ├── changes/_template/        # proposal.md + spec.md
│   └── archive/
├── specs/                        # 共享真相
=======
# audit-osh-skill

[中文文档](README-CN.md) | English

---

## Overview

`audit-osh` is a Skill for auditing and optimizing a project's AI collaboration structure. It is based on the industrial-grade three-layer paradigm (OpenSpec + Superpowers + Harness), helping teams establish standardized AI collaboration workflows.

**Core Philosophy:**
- **OpenSpec** defines direction (WHAT)
- **Superpowers** enforces discipline (HOW)
- **Harness** orchestrates collaboration (WHO)

---

## Features

### 1. Project Structure Audit
Performs a comprehensive 24-check audit across three core layers:

| Layer | Checks | Description |
|:---|:---|:---|
| **OpenSpec** (O1–O7) | Shared spec docs, API contract authority, change proposal templates, change archive, project overview, boundary clarity, language efficiency | Ensures "what to build" has a clear shared truth |
| **Superpowers** (S1–S9) | Agent role declaration, cross-domain prohibition, Superpowers command chain, project rules, domain skills, permissions config, hooks config, custom agents, context budget | Ensures "how to build" follows strict discipline |
| **Harness** (H1–H8) | Workspace separation, shared spec accessibility, mock-first frontend, Git worktree isolation, root nav hub, session management, no dead files, zero duplication | Ensures "who builds what" has clear orchestration |

### 2. Gap Scoring System
- Calculates per-layer and overall scores
- Maturity grade classification:
  - `< 33%` → Pre-foundation
  - `33–66%` → Foundation
  - `66–90%` → Quality
  - `> 90%` → Industrial
- Context efficiency target: > 3x reduction, single agent context < 150 lines (~3K tokens)

### 3. Optimization Playbook
Generates a 7-step optimization plan based on audit results:
1. Create `specs/` + API contract, data model, error codes docs
2. Create `openspec/` + templates + project.md + READMEs
3. Translate auto-loaded files to English
4. Write Agent CLAUDE.md per tech stack
5. Add `.claude/rules/` with globs frontmatter
6. Write `.claude/settings.json`
7. Verify: re-run audit, test hooks, test reviewer

### 4. Target Structure Template
Provides a complete Monorepo target structure:
```
project/
├── CLAUDE.md                     ← Nav hub: ≤120 lines
├── openspec/                     ← SDD delta workflow
│   ├── README.md
│   ├── project.md                ← No coding conventions
│   ├── changes/_template/        ← proposal.md + spec.md
│   └── archive/
├── specs/                        ← Shared truth
>>>>>>> 904cd8e73b6df2f686ce20bddd973b4191e62055
│   ├── README.md
│   ├── api-contract.md
│   ├── data-model.md
│   └── error-codes.md
├── .claude/
<<<<<<< HEAD
│   ├── settings.json             # 权限 + 钩子 + 代理
│   ├── rules/                    # 自动加载（globs）
│   └── skills/<name>/SKILL.md    # ≤300 行
├── {backend}/CLAUDE.md           # 后端代理
├── {frontend}/CLAUDE.md          # 前端代理
└── {mobile}/CLAUDE.md            # 移动端代理
```

### 5. 反模式快速参考
识别并修复常见反模式：
- 单体 CLAUDE.md（250+ 行，多技术栈）→ 拆分为按目录的 CLAUDE.md
- AGENTS.md 存在 → 删除
- 规范内联在 CLAUDE.md 中 → 提取到 `specs/`
- 重复规则 → 仅保留在 rules/ 中
- 无角色声明 → 添加 "## Role: You are a [X] Agent"
- 无跨域禁止 → 添加 "NEVER generate [X] code"
- 自动加载文件使用中文 → 使用英文（节省 30-50% token）

---

## 使用方法

### 审计现有项目

1. **发现**：列出项目根目录，识别所有 CLAUDE.md、`.claude/`、`specs/`、`openspec/`
2. **读取**：读取每个 CLAUDE.md（根目录 + 子目录）、`.claude/settings.json`、`specs/` 和 `openspec/` 文件
3. **审计**：对以下 24 项检查进行评分（YES / PARTIAL / NO）
4. **报告**：按 Phase 6 格式输出，为每个差距引用修复编号
5. **应用**（用户确认后）：按确切顺序执行 Phase 5，不要重新排序

### 新项目快速启动
=======
│   ├── settings.json             ← Permissions + hooks + agents
│   ├── rules/                    ← Auto-loaded (globs)
│   └── skills/<name>/SKILL.md    ← ≤300 lines each
├── {backend}/CLAUDE.md           ← Backend Agent
├── {frontend}/CLAUDE.md          ← Frontend Agent
└── {mobile}/CLAUDE.md            ← Mobile Agent (if applicable)
```

### 5. Anti-Pattern Quick Reference
Identifies and fixes common anti-patterns:
- Monolith CLAUDE.md (250+ lines, multi-stack) → Split into per-directory CLAUDE.md
- AGENTS.md exists → Delete it (Claude Code never reads it)
- Specs inline in CLAUDE.md → Extract to `specs/`
- Duplicate rules in CLAUDE.md + rules/ → Keep in rules/ only
- No role declaration → Add "## Role: You are a [X] Agent"
- No cross-domain ban → Add "NEVER generate [X] code"
- Auto-loaded files in Chinese → Use English (saves 30–50% tokens)

---

## Usage

### Auditing an Existing Project

1. **Discover**: LS project root. Identify all CLAUDE.md, `.claude/`, `specs/`, `openspec/`.
2. **Read**: Every CLAUDE.md (root + subdirs), `.claude/settings.json`, `specs/` and `openspec/` files.
3. **Audit**: Score all 24 checks as YES / PARTIAL / NO.
4. **Report**: Output per Phase 6 format. Reference Fix numbers for each gap.
5. **Apply** (after user confirms): Execute Phase 5 in exact order. Do not reorder.

### New Project Bootstrap
>>>>>>> 904cd8e73b6df2f686ce20bddd973b4191e62055

```bash
mkdir -p project/{specs,openspec/{changes/_template,archive},.claude/{rules,skills}}
mkdir -p project/backend project/frontend-web
<<<<<<< HEAD
# 然后按 Phase 4 模板写入所有文件
# 最后删除 AGENTS.md，运行 Phase 1 审计验证
=======
# Then write all files per Phase 4 templates above
# Finally delete AGENTS.md, run Phase 1 audit to verify
>>>>>>> 904cd8e73b6df2f686ce20bddd973b4191e62055
```

---

<<<<<<< HEAD
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
- [ ] 根 CLAUDE.md ≤ 120 行，仅导航中心
- [ ] 每个子 CLAUDE.md：角色 + 概览 + 编码前 + 标准 + Superpowers + TDD + 构建
- [ ] 每个子 CLAUDE.md 中明确禁止跨域
- [ ] specs/api-contract.md 对所有代理具有权威性
- [ ] openspec/changes/_template/ 包含 proposal.md + spec.md
- [ ] .claude/settings.json 包含权限 + 钩子 + 代理
- [ ] 审查器工具 = `["Read", "Bash"]` 仅
- [ ] 规则使用 globs；技能 ≤ 300 行
- [ ] 配置 Git 工作树隔离
- [ ] 记录会话管理（`/resume`, `/branch`, `/rewind`）
- [ ] 删除 AGENTS.md
- [ ] 自动加载文件间零重复
- [ ] 每个子 CLAUDE.md < 3K token

---

## 关键原则

- **规范即代码**：将规范视为代码的一部分
- **强制执行 TDD**：不只是口号，而是强制流程
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
=======
## Output Format

After audit, the following output is produced:

1. **Diagnostic table** — All 24 checks with YES/PARTIAL/NO scores + per-layer scores
2. **Maturity grade** — Overall percentage + level label
3. **Before/after metrics** — Context efficiency ratio (target > 3x)
4. **Top 3 issues** — Root cause + Fix reference + impact estimate
5. **Target structure** — Directory tree
6. **Action plan** — Ordered per Phase 5

---

## Verification Checklist

- [ ] Auto-loaded files are in English
- [ ] Root CLAUDE.md ≤ 120 lines, nav hub only
- [ ] Each sub-CLAUDE.md: Role + Overview + Before You Code + Standards + Superpowers + TDD + Build
- [ ] Cross-domain prohibition explicit in every sub-CLAUDE.md
- [ ] specs/api-contract.md authoritative for all agents
- [ ] openspec/changes/_template/ has proposal.md + spec.md
- [ ] .claude/settings.json has permissions + hooks + agents
- [ ] Reviewer tools = `["Read", "Bash"]` only
- [ ] Rules use globs; skills ≤ 300 lines each
- [ ] Git worktree isolation configured
- [ ] Session management (`/resume`, `/branch`, `/rewind`) documented
- [ ] AGENTS.md deleted
- [ ] Zero duplication across auto-loaded files
- [ ] Each sub-CLAUDE.md < 3K tokens

---

## Key Principles

- **Spec as Code**: Treat specifications as part of the codebase
- **TDD Enforced**: Not just a slogan, but a mandatory workflow
- **Skills On-Demand**: Avoid activating all skills simultaneously
- **No Cross-Domain**: Frontend must not generate backend code, and vice versa
- **Single Source of Truth**: All agents reference the same specification documents
- **English for Auto-Loaded Files**: Saves 30–50% tokens compared to Chinese

---

## Use Cases

- **New project bootstrap**: Establish a standardized AI collaboration structure from day one
- **Existing project optimization**: Audit and improve current collaboration workflows
- **Team collaboration standardization**: Ensure consistency across multiple agents
- **Code quality improvement**: Reduce errors and rework through structured specifications
>>>>>>> 904cd8e73b6df2f686ce20bddd973b4191e62055
