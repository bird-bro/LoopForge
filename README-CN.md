#audit-osh-skill

中文文档 | [English](README.md) 
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
│   ├── README.md
│   ├── api-contract.md
│   ├── data-model.md
│   └── error-codes.md
├── .claude/
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

```bash
mkdir -p project/{specs,openspec/{changes/_template,archive},.claude/{rules,skills}}
mkdir -p project/backend project/frontend-web
# 然后按 Phase 4 模板写入所有文件
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
