# audit-osh-skills

[中文文档](README-CN.md) | English

---

## Overview

This repository contains two Skills for AI collaboration optimization based on the industrial-grade three-layer paradigm (OpenSpec + Superpowers + Harness):

1. **`audit-osh`** — Audit and optimize existing project structure against OSH standards
2. **`split-help`** — Split monolithic CLAUDE.md into per-stack Agent files

**Core Philosophy:**
- **OpenSpec** defines direction (WHAT)
- **Superpowers** enforces discipline (HOW)
- **Harness** orchestrates collaboration (WHO)

---

## 1. Project Structure Audit (24 Checks)

Performs a comprehensive audit across three core layers:

### 1.1 OpenSpec — "Define Direction" (O1–O7)

| # | Check | Criteria |
|:--|:---|:---|
| O1 | Shared spec docs | `openspec/specs/` has api/spec.md + data/spec.md + errors/spec.md |
| O2 | API contract authoritative | All agents reference it; frontend mocks from it; backend implements to it |
| O3 | Delta proposal templates | `openspec/changes/_template/` with proposal.md + spec.md |
| O4 | Change archive | `openspec/archive/` for completed proposals |
| O5 | Project overview | `openspec/project.md`: tech stack, module map, architecture |
| O6 | Boundary clear | `openspec/README.md` explains structure: specs/ inside openspec/ for unified entry |
| O7 | Language efficient | CLAUDE.md, specs/, openspec/ files use English |

### 1.2 Superpowers — "Enforce Discipline" (S1–S9)

| # | Check | Criteria |
|:--|:---|:---|
| S1 | Agent role declared | Each CLAUDE.md starts with "You are a [Stack] [Role] Agent" |
| S2 | Cross-domain prohibition | Each agent states "NEVER generate frontend/backend code" |
| S3 | Superpowers workflow | 5 steps: brainstorm → writing-plans → executing-plans → code-review → verification. **Auto-triggered** |
| S4 | Project rules with globs | `.claude/rules/` auto-loaded by file path matching |
| S5 | Domain skills | `.claude/skills/` with YAML frontmatter; max 300 lines each |
| S6 | Permissions configured | `.claude/settings.json` with allow/deny lists |
| S7 | Hooks configured | SessionStart, PreToolUse, Stop hooks |
| S8 | Custom agents | Reviewer (Read+Bash only) + coordinator in settings.json |
| S9 | Context budget | Agent CLAUDE.md < 3K tokens; details in skills/ |

### 1.3 Harness — "Orchestrate Collaboration" (H1–H11)

| # | Check | Criteria |
|:--|:---|:---|
| H1 | Workspace separation | One subdir per tech stack with independent CLAUDE.md |
| H2 | Shared spec accessible | All agents reference `../openspec/specs/` |
| H3 | Mock-first frontend | Frontend mocks per API contract (MSW) |
| H4 | Git worktree isolation | Features in isolated worktrees |
| H5 | Root CLAUDE.md is nav hub | ≤ 120 lines; project map + build + session commands |
| H6 | Session management | `/resume`, `/branch`, `/rewind` for continuity |
| H7 | No dead files | Every .md has clear load/trigger path |
| H8 | Zero duplication | No rule in two auto-loaded files |
| H9 | Dangerous commands denied | `rm -rf`, `git push --force`, `git reset --hard` in deny list |
| H10 | Hooks configured | SessionStart + PreToolUse + Stop hooks |
| H11 | Custom agents defined | Reviewer (Read+Bash only) + Coordinator in settings.json |

---

## 2. Maturity Scoring System

### Gap Calculation
```
OpenSpec score    = O_yes / 7
Superpowers score = S_yes / 9
Harness score     = H_yes / 11

Overall = (O_yes + S_yes + H_yes) / 27
```

### Maturity Levels
| Score Range | Level |
|:--|:---|
| < 33% | Pre-foundation |
| 33–66% | Foundation |
| 66–90% | Quality |
| > 90% | Industrial |

### Context Efficiency Target
- Reduction: > 3x (before vs after)
- Single Agent context: < 150 lines (~3K tokens)

### 3. Optimization Playbook (6 Fixes)

| Fix | Action | Closes |
|:--|:---|:---|
| 1 | Create `openspec/` with `specs/` inside + templates + project.md + READMEs | O1–O7 |
| 2 | Translate auto-loaded files to English | O7 |
| 3 | Write Agent CLAUDE.md per tech stack | S1–S3,S9,H1–H3 |
| 4 | Add `.claude/rules/` with globs frontmatter | S4,S5 |
| 5 | Write `.claude/settings.json` | S6–S8 |
| 6 | Verify: re-run audit, test hooks, test reviewer | All |

### Execution Order (Phase 5)
**Do not reorder:**
1. CREATE `openspec/` (includes specs/ inside)
2. CREATE `.claude/` (rules + skills + settings.json)
3. CREATE agent CLAUDE.md (one per tech stack)
4. REWRITE root CLAUDE.md (nav hub only)
5. DELETE dead files (AGENTS.md, duplicates)
6. VERIFY no duplication

### 4. Target Structure Template
Provides a complete Monorepo target structure:
```
project/
├── CLAUDE.md                     ← Nav hub: ≤120 lines
├── openspec/                     ← Unified spec management (specs inside for single entry)
│   ├── README.md                 ← Structure explanation + responsibility separation
│   ├── project.md                ← Business context, architecture (NO coding conventions)
│   ├── specs/                    ← STATIC: Shared truth (inside openspec)
│   │   ├── README.md             ← Explains role as shared truth
│   │   ├── api-contract.md
│   │   ├── data-model.md
│   │   └── error-codes.md
│   ├── changes/                  ← DYNAMIC: Active proposals
│   │   ├── _template/            ← proposal.md + spec.md
│   │   └── <active-change>/      ← In-progress work
│   └── archive/                  ← COMPLETED: Finished proposals
├── .claude/
│   ├── settings.json             ← Permissions + hooks + agents
│   ├── rules/                    ← Auto-loaded (globs)
│   └── skills/<name>/SKILL.md    ← ≤300 lines each
├── {backend}/CLAUDE.md           ← Backend Agent
├── {frontend}/CLAUDE.md          ← Frontend Agent
└── {mobile}/CLAUDE.md            ← Mobile Agent (if applicable)
```

**Key improvement:**
- `specs/` inside `openspec/` provides unified entry point
- `openspec/README.md` clearly explains responsibility separation
- Simpler mental model: "openspec/ has everything about specs"

### 5. Anti-Pattern Quick Reference

| Anti-pattern | Fix |
|:---|:---|
| Monolith CLAUDE.md (250+ lines, multi-stack) | Split into per-directory CLAUDE.md |
| AGENTS.md exists | Delete it (Claude Code never reads it) |
| Specs inline in CLAUDE.md | Extract to `openspec/specs/` |
| CSS/SCSS in CLAUDE.md | Move to `.claude/skills/` |
| Duplicate rules in CLAUDE.md + rules/ | Keep in rules/ only |
| Style guides in docs/ for AI | Move to `.claude/skills/` for auto-trigger |
| No role declaration | Add "## Role: You are a [X] Agent" |
| No cross-domain ban | Add "NEVER generate [X] code" |
| TDD as plain text | Add Superpowers 5-step workflow (auto-triggered) |
| All skills active | Skills in `.claude/skills/` — on-demand only |
| Empty changes/ dir | Create `_template/proposal.md` + `spec.md` |
| Reviewer has Write/Edit | Reviewer tools = `["Read", "Bash"]` only |
| Specs in Chinese (auto-loaded) | English — saves up to 30–50% token |
| Root CLAUDE has agent rules | Root = nav hub; rules in sub-CLAUDE.md |
| Modifying existing code | Overloading or new methods only |
| Context window ignored | CLAUDE.md < 3K tokens; skills load on-demand |
| specs/ at root level (standard OSH) | Move to `openspec/specs/` for unified entry |
| No dangerous command deny | Add `rm -rf`, `git push --force` to permissions.deny (H9) |
| No hooks configured | Add SessionStart + PreToolUse + Stop hooks (H10) |
| No custom agents defined | Add reviewer + coordinator to settings.json agents (H11) |
| Reviewer can modify code | Reviewer tools must be `["Read", "Bash"]` only |

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
mkdir -p project/openspec/{specs,changes/_template,archive}
mkdir -p project/.claude/{rules,skills}
mkdir -p project/backend project/frontend-web
# Then write all files per Fix 1 templates above
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

- [ ] Auto-loaded files are English
- [ ] Root CLAUDE.md ≤ 120 lines, nav hub only
- [ ] Each sub-CLAUDE.md: Role + Overview + Before You Code + Standards + Superpowers + TDD + Build
- [ ] Cross-domain prohibition explicit in every sub-CLAUDE.md
- [ ] openspec/specs/api/spec.md authoritative for all agents
- [ ] openspec/README.md explains structure + responsibility separation
- [ ] openspec/changes/_template/ has proposal.md + spec.md
- [ ] .claude/settings.json has permissions + hooks + agents
- [ ] Reviewer tools = `["Read", "Bash"]` only
- [ ] Rules use globs; skills ≤ 300 lines each
- [ ] Git worktree isolation configured
- [ ] Session management (`/resume`, `/branch`, `/rewind`) documented
- [ ] AGENTS.md deleted
- [ ] Zero duplication across auto-loaded files
- [ ] Each sub-CLAUDE.md < 3K tokens
- [ ] specs/ inside openspec/ (unified entry point)
- [ ] Dangerous commands in permissions.deny (H9): `rm -rf`, `git push --force`, `git reset --hard`
- [ ] Hooks configured (H10): SessionStart + PreToolUse + Stop
- [ ] Custom agents defined (H11): reviewer + coordinator in settings.json

---

## Superpowers Workflow

The Superpowers workflow enforces TDD discipline and is **auto-triggered** when development requests are made:

1. **brainstorming** — AI asks clarifying questions
2. **writing-plans** — AI generates task list
3. **executing-plans** — AI implements tasks with TDD
4. **code-review** — AI reviews against specs
5. **verification-before-completion** — AI runs tests before marking done

**TDD enforced**: Write failing test first → Implement → Refactor

> **Note**: Superpowers has no slash commands. It auto-triggers when you make development requests or use OpenSpec commands (`/opsx:propose`, `/opsx:apply`).

### OpenSpec-Superpowers Integration

**How OpenSpec commands auto-trigger Superpowers:**

```
User: /opsx:propose add-login-feature
        │
        ▼
Harness reads .claude/commands/opsx:propose
        │
        ▼
Command file contains "activate Superpowers brainstorming"
        │
        ▼
Superpowers brainstorming skill auto-triggers
        │
        ▼
AI starts asking clarifying questions (TDD flow begins)
```

**Key insight**: `openspec init` generates command files that pre-wire the Superpowers trigger. This is the "integration protocol" between OpenSpec and Superpowers.

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

---

# Skill 2: split-help

## Overview

`split-help` is a Skill for splitting a monolithic CLAUDE.md (generated by `/init`) into per-directory Agent CLAUDE.md files — one per tech stack — with proper role declarations, NEVER cross-domain rules, Superpowers workflow, and TDD discipline.

## Why This Matters

`/init` treats the entire project as one workspace. It puts Java/MyBatis patterns next to Vue/Element Plus patterns. When AI reads this, it gets confused — Java DI patterns while fixing a CSS bug. Each Agent should only see its own domain.

## When to Use

- After running `/init` on a multi-stack monorepo
- When a single CLAUDE.md has 200+ lines covering multiple tech stacks
- When adding a new technology layer to an existing project

## Workflow

### Phase 1: Discovery

1. **Read the Monolith**: Read the root CLAUDE.md completely. Identify and classify every section:
   - Business context → Root CLAUDE.md (nav) + `openspec/project.md`
   - Build commands → Per-stack Agent files
   - Code patterns → Per-stack Agent files
   - API paths → `specs/api-contract.md`
   
2. **Confirm with User**: Present findings and ask for confirmation before proceeding

### Phase 2: Generate Agent CLAUDE.md Files

For each tech stack, generate `{code-directory}/CLAUDE.md` with:
- **Role**: Explicit declaration (e.g., "You are a Backend Agent")
- **NEVER rules**: Cross-domain prohibition
- **Project Overview**: One-line system description + stack
- **Before You Code**: Spec-first + mock-first workflow
- **Module Structure**: Directory tree for this stack only
- **Coding Standards**: Stack-specific patterns
- **Superpowers Workflow**: 5-step command sequence
- **TDD**: Mandatory, enforced by Superpowers
- **Build Commands**: Stack-specific commands

### Phase 3: Rewrite Root CLAUDE.md

After all Agent files are generated, rewrite root CLAUDE.md as navigation hub:
- Project map (directory tree)
- Business context (1-3 sentences)
- Tech stack (one-line table)
- Development workflow
- Build & test commands (minimal)

**Sizing rule**: Root CLAUDE.md ≤ 120 lines

### Phase 4: Verify

Verify after generation:
- No content lost
- No duplication across auto-loaded files
- All required sections present in each Agent file
- Cross-domain prohibition explicit
- Path references correct
- Root CLAUDE.md is hub (≤ 120 lines)

## Anti-Patterns Fixed

| Anti-pattern | Fix |
|:---|:---|
| Business context in every Agent file | One-line "System" only; full context in root |
| API paths in Agent files | Extract to `specs/api-contract.md` |
| Duplicate build commands | Each command in exactly one Agent file |
| Mobile + desktop in one Agent file | Separate them — different UI paradigms |
| No Role declaration | Must be "## Role: You are a [Stack] [Role] Agent" |
| No TDD section | Always add Superpowers Workflow + TDD section |
| Root CLAUDE.md > 120 lines | Move content to Agent files or `openspec/project.md` |