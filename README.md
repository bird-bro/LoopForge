# audit-osh

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
│   ├── README.md
│   ├── api-contract.md
│   ├── data-model.md
│   └── error-codes.md
├── .claude/
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

```bash
mkdir -p project/{specs,openspec/{changes/_template,archive},.claude/{rules,skills}}
mkdir -p project/backend project/frontend-web
# Then write all files per Phase 4 templates above
# Finally delete AGENTS.md, run Phase 1 audit to verify
```

---

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
