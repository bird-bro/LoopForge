---
name: audit-osh
description: 检查项目结构是否符合 OSH 架构。Audit and optimize a project's AI collaboration structure (CLAUDE.md, specs, skills, rules, agents) against the industrial-grade three-layer paradigm (OpenSpec + Superpowers + Harness). 
---

# Project AI Architecture Audit & Optimization

**OpenSpec defines direction (WHAT), Superpowers enforces discipline (HOW), Harness orchestrates collaboration (WHO).**

## Execution Instructions

1. **Discover**: LS project root. Identify all CLAUDE.md, `.claude/`, `specs/`, `openspec/`.
2. **Read**: Every CLAUDE.md (root + subdirs), `.claude/settings.json`, `specs/` and `openspec/` files.
3. **Audit**: Score all 24 checks below as YES / PARTIAL / NO.
4. **Report**: Output per Phase 6 format. Reference Fix numbers for each gap.
5. **Apply** (after user confirms): Execute Phase 5 in exact order. Do not reorder.

## Core Paradigm

| Layer | Tool | Responsibility |
|:---|:---|:---|
| **Spec** | OpenSpec / `specs/` | "What to build" — shared truth |
| **Discipline** | Superpowers / `.claude/` | "How to build" — TDD, review, quality gates |
| **Harness** | Claude Code + agents | "Who builds what" — roles, boundaries |

Key principles: Spec as Code. TDD enforced (not a slogan). Skills on-demand. No cross-domain. Single source of truth. English for auto-loaded files (saves up to 30-50% token vs Chinese).

---

## Phase 1: Structure Audit (24 checks)

### 1.1 OpenSpec — "Define Direction" (O1–O7)

| # | Check | Criteria |
|:--|:---|:---|
| O1 | Shared spec docs | `specs/` has api-contract.md + data-model.md + error-codes.md |
| O2 | API contract authoritative | All agents reference it; frontend mocks from it; backend implements to it |
| O3 | Delta proposal templates | `openspec/changes/_template/` with proposal.md (Why/What/Scope/Success Criteria/Constraints/Risks) + spec.md (Data Model/API/Business Rules/Error Handling) |
| O4 | Change archive | `openspec/archive/` for completed proposals |
| O5 | Project overview | `openspec/project.md`: tech stack, module map, architecture — no coding conventions |
| O6 | Boundary clear | `openspec/README.md` explains structure: specs/ inside openspec/ for unified entry, changes/ for dynamic workflow, archive/ for history |
| O7 | Language efficient | CLAUDE.md, specs/, openspec/ files use English |

### 1.2 Superpowers — "Enforce Discipline" (S1–S9)

| # | Check | Criteria |
|:--|:---|:---|
| S1 | Agent role declared | Each CLAUDE.md starts with "You are a [Stack] [Role] Agent. Your scope: [...]" |
| S2 | Cross-domain prohibition | Each agent states MUST NOT generate ("NEVER generate frontend/backend code") |
| S3 | Superpowers command chain | 5 steps: brainstorm → writing-plans → executing-plans → code-review → verification-before-completion, PLUS `/superpowers:workflow activate tdd` |
| S4 | Project rules with globs | `.claude/rules/` auto-loaded by file path matching |
| S5 | Domain skills | `.claude/skills/` with YAML frontmatter; max 300 lines each |
| S6 | Permissions configured | `.claude/settings.json` with allow/deny lists |
| S7 | Hooks configured | SessionStart, PreToolUse, Stop hooks |
| S8 | Custom agents | Reviewer (Read+Bash only) + coordinator in settings.json |
| S9 | Context budget | Agent CLAUDE.md < 3K tokens; details in skills/ for on-demand load |

### 1.3 Harness — "Orchestrate Collaboration" (H1–H8)

| # | Check | Criteria |
|:--|:---|:---|
| H1 | Workspace separation | One subdir per tech stack with independent CLAUDE.md |
| H2 | Shared spec accessible | All agents reference `../specs/` from working directory |
| H3 | Mock-first frontend | Frontend mocks per API contract (MSW); never blocks on backend |
| H4 | Git worktree isolation | Features in isolated worktrees |
| H5 | Root CLAUDE.md is nav hub | ≤ 120 lines; project map + build + session commands |
| H6 | Session management | `/resume`, `/branch`, `/rewind` for continuity |
| H7 | No dead files | Every .md has clear load/trigger path |
| H8 | Zero duplication | No rule in two auto-loaded files |

---

## Phase 2: Gap Scoring

```
OpenSpec score    = O_yes / 7
Superpowers score = S_yes / 9
Harness score     = H_yes / 8

Overall = (O_yes + S_yes + H_yes) / 24

  < 33%  → Pre-foundation
  33–66% → Foundation
  66–90% → Quality
  > 90%  → Industrial

Context efficiency = (total lines loaded per session before) / (agent CLAUDE.md + auto-loaded rules + shared specs per session after)
Target: > 3x reduction. Single Agent context: < 150 lines (~3K tokens)
```

---

## Phase 3: Target Structure

### Decision Table

| Decision | Recommendation |
|:---|:---|
| Monorepo vs single? | Monorepo: multi-stack, multi-agent. Single: one stack only |
| Agent files location? | Inside code dir (e.g., `backend/CLAUDE.md`) |
| `AGENTS.md`? | **Delete** — Claude Code reads CLAUDE.md only |
| `openspec/` needed? | Yes for multi-feature; No for simple single-repo |
| Style guides? | `.claude/skills/` for auto-trigger; `docs/` for humans |

### Monorepo Target

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

---

## Phase 4: Optimization Playbook

| Fix | Action | Closes | Key Files |
|:--|:---|:---|:---|
| 1 | Create `openspec/` with `specs/` inside + templates + project.md + READMEs | O1–O7 | See below |
| 2 | Translate auto-loaded files to English | O7 | — |
| 3 | Write Agent CLAUDE.md per tech stack | S1–S3,S9,H1–H3 | See below |
| 4 | Add `.claude/rules/` with globs frontmatter | S4,S5 | See below |
| 5 | Write `.claude/settings.json` | S6–S8 | See below |
| 6 | Verify: re-run Phase 1, test hooks, test reviewer | All | — |

### Fix 1: OpenSpec Structure (specs inside openspec)

**`openspec/README.md`** — Structure explanation + responsibility separation:
- Explains: specs/ (static), changes/ (dynamic), archive/ (completed)
- Clarifies: "openspec/ has everything about specs" — unified entry
- Links to: project.md, specs/README.md, changes/_template/

**`openspec/project.md`** — Business context (NO coding conventions):
- Tech stack, module map, architecture
- Success metrics, evolution plan
- Constraints, risks

**`openspec/specs/README.md`** — Shared truth explanation:
- Authority: "All agents reference these files"
- Change process: proposal → review → implementation → verification → archive
- Language: English required (saves 30-50% tokens)

**`openspec/specs/api-contract.md`**:
```markdown
# API Contract
> Single source of truth for frontend-backend integration.

## Conventions
- RESTful, Content-Type: application/json
- Auth: Header `Authorization: Bearer <token>`
- Response: `{ "code": 200, "msg": "success", "data": {}, "timestamp": 0 }`

## Status Codes
| code | meaning | frontend action |
| 200 | Success | Display normally |
| 203 | Token Expired | Redirect to login |
| 400 | Bad Request | Show error message |
| 500 | Server Error | Show system error |

## Pagination
Request: `{ pageNum: 1, pageSize: 20 }`
Response data: `{ records: [], total: 100, size: 20, current: 1 }`

## Module APIs
| method | path | description | request schema | response schema |
```
> Fill per project. Status codes and pagination format are project conventions — adjust as needed.

**`openspec/specs/data-model.md`**: Core entities, fields, constraints, relationships.

**`openspec/specs/error-codes.md`**: Unified error code table (enum, HTTP status, message, usage).

**`openspec/changes/_template/proposal.md`**:
```markdown
# Proposal: <feature>

## Why / What
[1-2 sentences]

## Scope
In: [ ] | Out: [ ]

## Success Criteria
- [ ] Measurable criterion

## Constraints
Technical / Performance / Security / Compatibility

## Affected Components
| Component | Impact | Owner |

## Risks
- [Risk — likelihood + mitigation]
```

**`openspec/changes/_template/spec.md`**:
```markdown
# Spec: <feature>

## 1. Data Model — new/modified entities (ref openspec/specs/data-model.md)
## 2. API Contract — new endpoints (ref openspec/specs/api-contract.md)
## 3. Business Rules — condition → action, edge cases
## 4. Error Handling — scenario, error code, HTTP, user message
## 5. Frontend Pages (if applicable) — route, components, mocks
## 6. Validation Checklist — contract match, data model match, error codes registered
## 7. Implementation Plan — backend, frontend, integration test, archive
```

### Fix 3: Agent CLAUDE.md Template

```markdown
# CLAUDE.md — [Project] [Role]

## Role
You are a **[Stack] [Role] Agent**. Scope: [responsibilities].
**NEVER generate [opposite-domain] code**. **NEVER modify `openspec/specs/`**.

## Project Overview
System / Stack / Database / Config (4-6 lines)

## Before You Code
1. Read specs: `openspec/specs/`
2. Mock first (frontend): MSW per API contract
3. Never modify existing classes: use overloading (backend)

## Coding Standards
Naming / Error Handling / Query Pattern / Response Format (≤30 lines)

## Superpowers Workflow
/superpowers:brainstorm → /superpowers:writing-plans → /superpowers:executing-plans → /superpowers:code-review → /superpowers:verification-before-completion
/superpowers:workflow activate tdd — mandatory
Pre-commit: [test command]

## Build Commands
[3-5 most-used commands]
```

> Slash commands are Claude Code native, NOT bash. Do not wrap in code blocks. If Superpowers not installed, apply same discipline manually.

### Fix 4: Rules with Globs

```markdown
---
globs: backend/**
---
# Backend Rules
- Never modify existing Service methods — use overloads
- Constructor injection via @RequiredArgsConstructor
- Assert.notNull() for validation
- Exception codes: Axxxx/Bxxxx/Cxxxx
```

### Fix 5: settings.json

```json
{
  "permissions": {
    "allow": ["Bash(npm test:*)", "Bash(pnpm test:*)", "Bash(mvn test:*)",
              "Bash(git diff:*)", "Bash(git status:*)", "Bash(git log:*)",
              "Bash(git add:*)", "Bash(git commit:*)"],
    "deny": ["Bash(rm -rf:*)", "Bash(git push --force:*)", "Bash(git reset --hard:*)"]
  },
  "hooks": {
    "SessionStart": [{"command": "echo '[project] Specs: specs/ | TDD | No cross-domain'"}],
    "PreToolUse": [{"matcher": "Bash",
      "command": "grep -qE 'rm -rf|git push --force|git reset --hard' 2>/dev/null && echo '⚠️ Destructive' || true"}],
    "Stop": [{"command": "echo '[project] Verify all changes committed.'"}]
  },
  "agents": {
    "coordinator": {
      "description": "Read OpenSpec proposals, break into tasks, assign to agents",
      "tools": ["Read", "Bash", "Write", "Edit", "Agent"]
    },
    "reviewer": {
      "description": "Code review against specs/ + rules. Output BLOCKER/MAJOR/MINOR.",
      "tools": ["Read", "Bash"]
    }
  }
}
```
> Adjust test commands and project name placeholders per project.

### Fix 6: Verify and Iterate

After applying fixes, re-run Phase 1 audit. Also test:
1. Start new session in each agent dir — confirm correct CLAUDE.md loads
2. Ask reviewer agent to review a change — confirm it catches issues
3. Test PreToolUse: ask agent to `rm -rf /tmp/test` — warning should trigger
4. Create a test proposal using `_template/proposal.md` — confirm workflow works

---

## Phase 5: Execute Restructuring

**Do not reorder:**

```
1. CREATE openspec/         ← Unified entry (includes specs/ inside)
   - openspec/README.md     ← Structure explanation + responsibility separation
   - openspec/project.md    ← Business context
   - openspec/specs/        ← Static contracts (inside openspec)
     - README.md, api-contract.md, data-model.md, error-codes.md
   - openspec/changes/_template/  ← proposal.md + spec.md
   - openspec/archive/
2. CREATE .claude/          ← Rules + skills + settings.json
3. CREATE agent CLAUDE.md   ← One per tech stack, inside its code dir
4. REWRITE root CLAUDE.md   ← Nav hub only, after all pieces exist
5. DELETE dead files        ← AGENTS.md, duplicates, orphaned docs/
6. VERIFY no duplication    ← Re-read every auto-loaded file
```

---

## Anti-Pattern Quick Reference

| Anti-pattern | Fix |
|:---|:---|
| Monolith CLAUDE.md (250+ lines, multi-stack) | Split into per-directory CLAUDE.md |
| AGENTS.md exists | Delete it (Claude Code never reads it) |
| Specs inline in CLAUDE.md | Extract to `openspec/specs/` |
| CSS/SCSS in CLAUDE.md | Move to `.claude/skills/` |
| Duplicate rules in CLAUDE.md + rules/ | Keep in rules/ only |
| Style guides in docs/ for AI | Move to `.claude/skills/` for auto-trigger |
| No role declaration | "## Role: You are a [X] Agent" |
| No cross-domain ban | Add "NEVER generate [X] code" |
| TDD as plain text | Add Superpowers 5-step + `/superpowers:workflow activate tdd` |
| All skills active | Skills in `.claude/skills/` — on-demand only |
| Empty changes/ dir | Create `_template/proposal.md` + `spec.md` |
| Reviewer has Write/Edit | Reviewer tools = `["Read", "Bash"]` only |
| Specs in Chinese (auto-loaded) | English — saves up to 30-50% token |
| Root CLAUDE has agent rules | Root = nav hub; rules in sub-CLAUDE.md |
| Modifying existing code | Overloading or new methods only |
| Context window ignored | CLAUDE.md < 3K tokens; skills load on-demand |
| specs/ at root level (standard OSH) | Move to `openspec/specs/` for unified entry |

---

## Phase 6: Output Format

After audit, produce:

1. **Diagnostic table** — all 24 checks with YES/PARTIAL/NO + per-layer scores
2. **Maturity grade** — overall % + level label
3. **Before/after metrics** — context efficiency ratio (target > 3x)
4. **Top 3 issues** — root cause + Fix reference + impact estimate
5. **Target structure** — directory tree
6. **Action plan** — ordered per Phase 5

---

## Quick Start: New Project Bootstrap

```bash
mkdir -p project/openspec/{specs,changes/_template,archive}
mkdir -p project/.claude/{rules,skills}
mkdir -p project/backend project/frontend-web
# Then write all files per Fix 1 templates above
# Finally delete AGENTS.md, run Phase 1 audit to verify
```

## Verification Checklist

- [ ] Auto-loaded files are English
- [ ] Root CLAUDE.md ≤ 120 lines, nav hub only
- [ ] Each sub-CLAUDE.md: Role + Overview + Before You Code + Standards + Superpowers + TDD + Build
- [ ] Cross-domain prohibition explicit in every sub-CLAUDE.md
- [ ] openspec/specs/api-contract.md authoritative for all agents
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
