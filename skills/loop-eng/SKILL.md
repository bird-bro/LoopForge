---
name: loop-eng
description: Loop Engineering — scaffold, audit, and restructure an AI-collaboration project against the OpenSpec + Superpowers + Harness (LoopEng) paradigm. Three modes — scaffold (generate a complete new framework via scaffold.sh), audit (32-check maturity scoring), restructure (split a monolithic CLAUDE.md into per-stack agents + optimize). Use when the user asks to "set up loop engineering", "scaffold a LoopEng project", "audit project structure", "split CLAUDE.md", or "optimize AI collaboration structure".
---

# Loop Engineering — Scaffold · Audit · Restructure

**OpenSpec defines direction (WHAT), Superpowers enforces discipline (HOW), Harness orchestrates collaboration (WHO).**

## Core Paradigm

| Layer | Tool | Responsibility |
|:--|:--|:--|
| Spec | OpenSpec / `openspec/` | WHAT — shared truth |
| Discipline | Superpowers / `.claude/` | HOW — TDD, review, quality gates |
| Harness | CLAUDE.md + agents | WHO — roles, boundaries |

> **Multi-tool harness:** `CLAUDE.md` and `AGENTS.md` are parallel **live** entry files — Claude Code reads `CLAUDE.md`, Codex reads `AGENTS.md`. Both are first-class, never "dead". Keep nav-hub content in sync. Per-stack dirs may carry both (`<stack>/CLAUDE.md` + `<stack>/AGENTS.md`); different tools load them, so mirroring is not duplication.

Key principles: Spec as Code. TDD enforced (not a slogan). Skills on-demand. No cross-domain. Single source of truth. English for auto-loaded files (saves 30–50% tokens vs Chinese).

## Three Modes

| Mode | When to use | How |
|:--|:--|:--|
| **scaffold** | New project, no structure yet | Run `scaffold.sh` → complete framework |
| **audit** | Existing project, check health | Run 32 checks, score maturity, report gaps |
| **restructure** | Monolithic CLAUDE.md or low audit score | Split into per-stack agents + apply Phase 5 order |

## Execution Instructions

1. Determine mode from user intent (scaffold / audit / restructure).
2. Run the matching section below.
3. Always finish with the Verification Checklist.

## CLI Subcommands (`scaffold.sh`)

The generator ships with four subcommands (run directly, or ask the AI to run them):

| Subcommand | Purpose |
|:--|:--|
| `scaffold.sh <name> [opts]` | Generate the framework (default) |
| `scaffold.sh list [opts]` | Preview the file manifest without writing anything |
| `scaffold.sh check [project]` | Self-check (env + script) + LoopEng compliance audit; no arg = self-check only |
| `scaffold.sh tokens [project]` | Token audit of auto-loaded files — per-file tokens + CJK% (O7 overhead); no arg = cwd |

`check` prints PASS / PARTIAL / FAIL per check plus a maturity score (an automatable subset of the 32; use audit mode for the full set). It also auto-measures **O7** — CJK char ratio in auto-loaded files, threshold via the `CJK_THRESHOLD` env var (default 10). For per-file token counts and CJK breakdown, run `scaffold.sh tokens`. See `USAGE-PLAYBOOK.md` for dialogue-style usage.

---

## Mode: Scaffold

Generate a complete Loop Engineering framework from scratch.

### Prerequisites
- OpenSpec CLI: `openspec --version` (install: `npm i -g @fission-ai/openspec@latest`)
- Node/npm available

### Steps
1. Run the generator — it creates `openspec/`, `.claude/`, per-stack `CLAUDE.md` (+ `AGENTS.md` for Codex), and the root nav hub (`CLAUDE.md` + `AGENTS.md`):
   ```bash
   ./scaffold.sh <project-name> --stacks backend,frontend[,frontend-mobile]
   ```
   `scaffold.sh` calls `openspec init` automatically (use `--no-init` to skip), then layers LoopEng templates on top. It is **non-destructive**: existing files are skipped.
2. Install on-demand components (referenced by audit but NOT generated — they are separate skills/agents):
   - Superpowers skills: brainstorm, writing-plans, executing-plans, code-review, verification-before-completion
   - `frontend-design` skill (frontend projects only)
3. Fill `[BRACKETS]` placeholders in `openspec/project.md`, `openspec/specs/*`, and per-stack `CLAUDE.md`.
4. Run **Mode: Audit** to verify maturity.

> All file templates live in `scaffold.sh` (single source of truth). Do not duplicate them here.

---

## Mode: Audit

### Phase 0: Environment Check (E1–E4)

| # | Check | Criteria | Fix |
|:--|:--|:--|:--|
| E1 | OpenSpec CLI installed | `openspec --version` returns valid version | `npm i -g @fission-ai/openspec@latest` |
| E2 | Project initialized | `openspec/` exists with `specs/`, `changes/`, `archive/` | `openspec init` |
| E3 | Slash commands generated | `.claude/commands/opsx:propose`, `opsx:apply`, `opsx:archive` exist | `openspec init` |
| E4 | frontend-design skill available | `.claude/skills/frontend-design/SKILL.md` exists (frontend only) | Install `frontend-design` skill |

Environment score = E_yes / 4. 0/4 → STOP; 1–3/4 → WARNING; 4/4 → PASS.

### Phase 1: 32 Checks

#### 1.1 OpenSpec — "Define Direction" (O1–O8)

| # | Check | Criteria |
|:--|:--|:--|
| O1 | Shared spec docs | `openspec/specs/` has `api/spec.md` + `data/spec.md` + `errors/spec.md` |
| O2 | API contract authoritative | All agents reference it; frontend mocks from it; backend implements to it |
| O3 | Delta proposal templates | `openspec/changes/_template/` with `proposal.md` + `spec.md` (WHEN/THEN) |
| O4 | Change archive | `openspec/archive/` for completed proposals |
| O5 | Project overview | `openspec/project.md`: tech stack, module map, architecture — no coding conventions |
| O6 | Boundary clear | `openspec/README.md` explains structure: `specs/` inside `openspec/`, unified entry |
| O7 | Language efficient | Auto-loaded files (root + per-stack `CLAUDE.md`/`AGENTS.md`, `.claude/rules/*.md`) in English. Auto-measured by `check` (CJK char ratio; `CJK_THRESHOLD` env, default 10%). `specs/`/`openspec/` assessed in full audit mode |
| O8 | WHEN/THEN scenarios | Every spec in `openspec/changes/` contains WHEN/THEN verification scenarios |

#### 1.2 Superpowers — "Enforce Discipline" (S1–S9)

| # | Check | Criteria |
|:--|:--|:--|
| S1 | Agent role declared | Each CLAUDE.md starts with "You are a [Stack] [Role] Agent. Your scope: [...]" |
| S2 | Cross-domain prohibition | Each agent states MUST NOT / "NEVER generate [opposite-domain] code" |
| S3 | Superpowers workflow | 5 steps: brainstorm → writing-plans → executing-plans → code-review → verification. Auto-triggered by `/opsx:propose`, `/opsx:apply` — no slash command needed |
| S4 | Project rules with globs | `.claude/rules/` auto-loaded by file-path matching |
| S5 | Domain skills | `.claude/skills/` with YAML frontmatter; max 300 lines each |
| S6 | Permissions configured | `.claude/settings.json` with allow/deny lists |
| S7 | Hooks configured | SessionStart, PreToolUse, Stop hooks |
| S8 | Custom agents | Reviewer (Read+Bash only) + Coordinator |
| S9 | Context budget | Agent CLAUDE.md < 3K tokens; details in `skills/` for on-demand load |

#### 1.3 Harness — "Orchestrate Collaboration" (H1–H11)

| # | Check | Criteria |
|:--|:--|:--|
| H1 | Workspace separation | One subdirectory per tech stack, each with its own CLAUDE.md (+ AGENTS.md for Codex) |
| H2 | Shared spec accessible | All agents reference `../openspec/specs/` |
| H3 | Mock-first frontend | Frontend mocks APIs from the contract (MSW) |
| H4 | Git worktree isolation | Features developed in isolated worktrees |
| H5 | Root CLAUDE.md is nav hub | ≤ 120 lines; project map + build + session commands |
| H6 | Session management | `/resume`, `/branch`, `/rewind` keep continuity |
| H7 | No dead files | Every `.md` has a clear load/trigger path (CLAUDE.md→Claude Code, AGENTS.md→Codex, specs→all). AGENTS.md is NOT dead |
| H8 | Zero duplication | No rule in two files the SAME tool loads. CLAUDE.md & AGENTS.md are different tools — mirroring is allowed |
| H9 | Dangerous commands denied | `rm -rf`, `git push --force`, `git reset --hard` in deny list |
| H10 | Hooks configured | SessionStart + PreToolUse + Stop hooks |
| H11 | Custom agents defined | Reviewer (Read+Bash only) + Coordinator |

### Scoring

```
Environment     = E_yes / 4
OpenSpec        = O_yes / 8
Superpowers     = S_yes / 9
Harness         = H_yes / 11
Overall         = (E + O + S + H) / 32
```

| Score | Level |
|:--|:--|
| < 33% | Pre-build |
| 33–66% | Basic |
| 66–90% | Quality |
| > 90% | Industrial |

Context-efficiency target: reduction ratio > 3x; per-agent context < 150 lines (~3K tokens).

---

## Mode: Restructure

Use when a monolithic CLAUDE.md exists or the audit score is low.

### Phase 1: Discover
Read the root CLAUDE.md completely and classify every section per stack:

| Content type | Belongs in |
|:--|:--|
| Business context | Root CLAUDE.md (nav) + `openspec/project.md` |
| Build commands (mvn/gradle) | Backend Agent CLAUDE.md |
| Build commands (pnpm/npm/yarn) | Frontend Agent CLAUDE.md |
| Backend patterns (Java/Spring/MyBatis) | Backend Agent CLAUDE.md |
| Frontend patterns (Vue/React/Element Plus) | Frontend Agent CLAUDE.md |
| API paths | `openspec/specs/api/spec.md` (NOT agent files) |
| Shared naming conventions | `.claude/rules/` or `specs/` |

Present findings to the user and confirm stacks before generating files.

### Phase 2: Generate Agent CLAUDE.md (per stack)
Each agent file must contain: Role, Project Overview, Before You Code, Module Structure, Coding Standards, Superpowers Workflow, TDD, Build Commands. Explicit cross-domain prohibition in every file.

> For new files, reuse `scaffold.sh` templates (they already match this structure). For splitting an existing monolith, follow the Content Extraction Rules below.

**Content Extraction Rules:**
1. Code examples stay with their stack (Java → backend, Vue/SCSS → frontend).
2. API paths go to `openspec/specs/api/spec.md`, never agent files.
3. Response format / error codes are shared — minimal reference in both agents, authoritative definition in `specs/`.
4. Build commands split by tool (`mvn*` → backend, `pnpm*`/`npm*` → frontend).
5. Universal conventions → `.claude/rules/` or `specs/`; domain-specific → one agent only.
6. Business context → root CLAUDE.md only; each agent gets a one-line "System".

**Edge cases:** single stack → don't split, just add Role + NEVER + Superpowers + TDD. Already split → verify all sections present, add missing ones. Mobile + desktop frontends → separate files (different UI paradigms).

### Phase 3: Rewrite Root CLAUDE.md (nav hub, ≤120 lines)
Project map + business context (1–3 sentences) + tech-stack table + development workflow + AI coding rules + session commands + minimal build & test. If it exceeds 120 lines, move content to `openspec/project.md` or agent files.

### Phase 4: Verify
1. No content lost — every example/convention/command is in exactly one file.
2. No duplication — no rule in two auto-loaded files.
3. All required sections present in each agent file.
4. Cross-domain prohibition explicit in every agent file.
5. Path references correct (`../openspec/specs/` relative to each agent's dir).
6. Root CLAUDE.md is a hub (≤120 lines, no agent instructions, no coding standards).

### Phase 5: Execute Restructuring (do not reorder)
```
1. CREATE openspec/         ← unified entry (specs/ inside)
2. CREATE .claude/          ← rules + skills + settings.json + agents
3. CREATE agent CLAUDE.md   ← one per tech stack, inside its code dir
4. REWRITE root CLAUDE.md   ← nav hub only, after all pieces exist
5. DELETE dead files        ← duplicates & orphaned docs ONLY. Never delete AGENTS.md — it is the Codex harness entry (≡ CLAUDE.md for Claude Code); keep in sync
6. VERIFY no duplication    ← re-read every auto-loaded file
```

---

## Output Format (Audit)

1. **Diagnostic table** — all 32 checks with YES / PARTIAL / NO + per-layer scores
2. **Maturity grade** — overall % + level label
3. **Before/after metrics** — context-efficiency ratio (target > 3x)
4. **Top 3 issues** — root cause + Fix reference + impact estimate
5. **Target structure** — directory tree
6. **Action plan** — ordered per Phase 5

## Anti-Pattern Quick Reference

| Anti-pattern | Fix |
|:--|:--|
| AGENTS.md deleted / treated as dead | Keep it — Codex harness entry (≡ CLAUDE.md); mirror nav hub, keep in sync |
| Monolith CLAUDE.md (250+ lines, multi-stack) | Split into per-directory CLAUDE.md |
| Specs inline in CLAUDE.md | Extract to `openspec/specs/` |
| API paths in agent files | Move to `openspec/specs/api/spec.md` |
| Duplicate rules in CLAUDE.md + rules/ | Keep in `rules/` only |
| No role declaration | "## Role: You are a [X] Agent" |
| No cross-domain ban | Add "NEVER generate [X] code" |
| TDD as plain text | Add Superpowers 5-step workflow (auto-triggered) |
| Reviewer can edit code | Reviewer tools = `["Read", "Bash"]` only |
| Specs in Chinese (auto-loaded) | English — saves 30–50% tokens |
| Root CLAUDE has agent rules | Root = nav hub; rules in sub-CLAUDE.md |
| No dangerous-command deny | Add `rm -rf`, `git push --force` to permissions.deny |
| specs/ at root level | Move to `openspec/specs/` (unified entry) |

## Verification Checklist

- [ ] Auto-loaded files are English
- [ ] Root CLAUDE.md ≤ 120 lines, nav hub only
- [ ] AGENTS.md mirrors CLAUDE.md as the Codex entry (live, in sync) — not deleted
- [ ] Each sub-CLAUDE.md has Role + Overview + Before You Code + Standards + Superpowers + TDD + Build
- [ ] Cross-domain prohibition explicit in every sub-CLAUDE.md
- [ ] `openspec/specs/api/spec.md` authoritative for all agents
- [ ] `openspec/changes/_template/` has `proposal.md` + `spec.md`
- [ ] `.claude/settings.json` has permissions + hooks
- [ ] Reviewer tools = `["Read", "Bash"]` only
- [ ] Rules use globs; skills ≤ 300 lines each
- [ ] Zero duplication across auto-loaded files
- [ ] Each sub-CLAUDE.md < 3K tokens

## OpenSpec ⇄ Superpowers Trigger

`openspec init` generates command files that pre-wire the Superpowers trigger:

```
/opsx:propose add-feature
  → Harness reads .claude/commands/opsx:propose
  → command file says "activate Superpowers brainstorming"
  → Superpowers brainstorm skill auto-triggers
  → AI asks clarifying questions (TDD flow begins)
```

This is the integration protocol between OpenSpec and Superpowers — the "loop" in Loop Engineering: propose → plan → execute → review → verify → archive.
