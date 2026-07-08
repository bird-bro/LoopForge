---
name: loop-eng-codex
description: Loop Engineering (Codex edition) — scaffold, audit, and restructure an AI-collaboration project against the OpenSpec + Superpowers + Harness (LoopEng) paradigm, adapted for Codex. AGENTS.md is the live entry file; the propose→verify→archive loop is driven by `$skill-name` invocation (`$openspec-propose` / `$openspec-apply-change` / `$openspec-verify` / `$openspec-archive-change`) + the `openspec` CLI; skills are invoked via `$skill-name` (e.g. `$loop-eng-codex`). Three modes — scaffold (generate a complete framework via scaffold.sh), audit (32-check maturity scoring), restructure (split a monolithic AGENTS.md/CLAUDE.md into per-stack agents + optimize). Use when the user asks to "set up loop engineering", "scaffold a LoopEng project", "audit project structure", "split AGENTS.md", or "optimize AI collaboration structure" in Codex.
---

# Loop Engineering — Scaffold · Audit · Restructure (Codex Edition)

**OpenSpec defines direction (WHAT), Superpowers enforces discipline (HOW), Harness orchestrates collaboration (WHO).**

> **Codex edition.** `openspec init --tools codex` generates project-local `.codex/skills/openspec-*` skills — `openspec-propose`, `openspec-apply-change`, `openspec-archive-change`, `openspec-explore`, `openspec-sync-specs` — invoked via `$skill-name`. Loop-eng adds `openspec-verify` (three-layer verification: L1 build / L2 spec alignment / L3 tests) + injects verify triggers/gates into the apply/archive skills. Codex drives the propose → verify → archive loop via `$` skills + the `openspec` CLI + natural language. Skills also auto-trigger by their `description`. The Superpowers 5-step discipline is encoded as instructions inside `AGENTS.md`. `AGENTS.md` is Codex's live entry file; `CLAUDE.md` is the Claude Code mirror (also generated, but Codex does not read it).

## Core Paradigm

| Layer | Tool | Responsibility |
|:--|:--|:--|
| Spec | OpenSpec / `openspec/` | WHAT — shared truth |
| Discipline | Superpowers → encoded in `AGENTS.md` | HOW — TDD, review, quality gates |
| Harness | `AGENTS.md` (+ `CLAUDE.md` mirror) + per-stack agents | WHO — roles, boundaries |

> **Multi-tool harness:** `CLAUDE.md` (Claude Code) and `AGENTS.md` (Codex) are parallel live entry files. scaffold.sh always generates both (mirrored). In a Codex-only project, edit `AGENTS.md`; `CLAUDE.md` may be kept for cross-tool use or deleted. Per-stack dirs carry both (`<stack>/CLAUDE.md` + `<stack>/AGENTS.md`); different tools load them, so mirroring is not duplication.

Key principles: Spec as Code. TDD enforced (not a slogan). Discipline baked into AGENTS.md. No cross-domain. Single source of truth. English for auto-loaded files (saves 30–50% tokens vs Chinese).

## Three Modes

| Mode | When to use | How |
|:--|:--|:--|
| **scaffold** | New project, no structure yet | Run `scaffold.sh --tools codex` → complete framework |
| **audit** | Existing project, check health | Run 32 checks, score maturity, report gaps |
| **restructure** | Monolithic `AGENTS.md` (or `CLAUDE.md`) or low audit score | Split into per-stack agents + apply Phase 5 order |

## Execution Instructions

1. Determine mode from user intent (scaffold / audit / restructure).
2. Run the matching section below.
3. Always finish with the Verification Checklist.

## CLI Subcommands (`scaffold.sh`)

The generator ships with four subcommands (run directly, or ask the AI to run them). In a globally-installed skill, scaffold.sh lives next to this SKILL.md (e.g. `~/.codex/skills/loop-eng-codex/scaffold.sh`); run it with an absolute path or copy it into the project.

| Subcommand | Purpose |
|:--|:--|
| `scaffold.sh <name> [opts]` | Generate the framework (default) |
| `scaffold.sh list [opts]` | Preview the file manifest without writing anything |
| `scaffold.sh check [project]` | Self-check (env + script) + LoopEng compliance audit; no arg = self-check only |
| `scaffold.sh tokens [project]` | Token audit of auto-loaded files — per-file tokens + CJK% (O7 overhead); no arg = cwd |

`check` prints PASS / PARTIAL / FAIL per check plus a maturity score (an automatable subset of the 32; use audit mode for the full set). It also auto-measures **O7** — CJK char ratio in auto-loaded files, threshold via the `CJK_THRESHOLD` env var (default 10). For per-file token counts and CJK breakdown, run `scaffold.sh tokens`. See `USAGE-PLAYBOOK-CODEX.md` for dialogue-style Codex usage.

> `check` (in scaffold.sh) is Codex-aware: its E3/E4/S4/S5/S6/S8/H1/H5/H9 lines probe `AGENTS.md` (Codex entry) and fall back to `.claude/` structures only when Claude Code is enabled (`--tools codex,claude`). In a Codex-only project they score against `AGENTS.md`, not `.claude/`. For the full 32-check semantic audit, use the criteria below.

---

## Mode: Scaffold

Generate a complete Loop Engineering framework from scratch.

### Prerequisites
- OpenSpec CLI: `openspec --version` (install: `npm i -g @fission-ai/openspec@latest`)
- Node/npm available

### Steps
1. Run the generator — it creates `openspec/`, per-stack `AGENTS.md` (+ `CLAUDE.md` mirror), and the root nav hub (`AGENTS.md` + `CLAUDE.md`):
   ```bash
   ./scaffold.sh <project-name> --stacks backend,frontend[,frontend-mobile] --tools codex
   ```
   `--tools codex` is passed to `openspec init` so OpenSpec generates Codex-flavored instruction files. Use `--tools codex,claude` if you also use Claude Code on the same project. `scaffold.sh` calls `openspec init` automatically (use `--no-init` to skip), then layers LoopEng templates on top. It is **non-destructive**: existing files are skipped.
2. On-demand components — **Codex adaptation**: the Superpowers 5-step discipline (brainstorm → writing-plans → executing-plans → code-review → verification-before-completion) is **already encoded as instructions in each generated `AGENTS.md`** — no separate skill install needed. For frontend projects, fold frontend-design guidance into the frontend `AGENTS.md` (there is no `.claude/skills/frontend-design` in Codex).
3. Fill `[BRACKETS]` placeholders in `openspec/project.md`, `openspec/specs/*`, and per-stack `AGENTS.md`.
4. Run **Mode: Audit** to verify maturity.

> All file templates live in `scaffold.sh` (single source of truth). Do not duplicate them here.

---

## Mode: Audit

### Phase 0: Environment Check (E1–E4)

| # | Check | Criteria (Codex) | Fix |
|:--|:--|:--|:--|
| E1 | OpenSpec CLI installed | `openspec --version` returns valid version | `npm i -g @fission-ai/openspec@latest` |
| E2 | Project initialized | `openspec/` exists with `specs/`, `changes/`, `archive/` | `openspec init --tools codex` |
| E3 | Codex harness entry present | Root `AGENTS.md` exists (Codex's live entry) | scaffold.sh / create `AGENTS.md` nav hub |
| E4 | Frontend design guidance | Frontend `AGENTS.md` carries design-system/UI guidance (frontend only) | Add a "Design Standards" section to frontend `AGENTS.md` |

Environment score = E_yes / 4. 0/4 → STOP; 1–3/4 → WARNING; 4/4 → PASS.

> Note: `scaffold.sh check` is Codex-aware — E3 probes root `AGENTS.md` and E4 probes the frontend `AGENTS.md` design guidance (Claude constructs are only checked when `--tools codex,claude`). E3+ checks for the verify skill (`.codex/skills/openspec-verify/` or `.claude/commands/opsx/verify.md`) — created by loop-eng, not `openspec init`. Use the criteria above for the full semantic audit.

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
| O7 | Language efficient | Auto-loaded files (root + per-stack `AGENTS.md`) in English. Auto-measured by `check` (CJK char ratio; `CJK_THRESHOLD` env, default 10%). `specs/`/`openspec/` assessed in full audit mode |
| O8 | WHEN/THEN scenarios | Every spec in `openspec/changes/` contains WHEN/THEN verification scenarios |

#### 1.2 Superpowers — "Enforce Discipline" (S1–S9)

| # | Check | Criteria (Codex) |
|:--|:--|:--|
| S1 | Agent role declared | Each `AGENTS.md` starts with "You are a [Stack] [Role] Agent. Your scope: [...]" |
| S2 | Cross-domain prohibition | Each agent states MUST NOT / "NEVER generate [opposite-domain] code" |
| S3 | Discipline workflow | 5 steps present as instructions in `AGENTS.md`: brainstorm → writing-plans → executing-plans → code-review → verification. Driven by `$skill-name` (`$openspec-propose` / `$openspec-apply-change` / `$openspec-verify` / `$openspec-archive-change`) or `openspec` CLI |
| S4 | Project rules | Universal conventions documented in root `AGENTS.md` and/or `openspec/specs/` (Codex has no `.claude/rules/` auto-load) |
| S5 | Domain guidance | Stack-specific deep guidance lives in the per-stack `AGENTS.md`; global Codex skills may live in `~/.codex/skills/` |
| S6 | Permissions configured | Codex sandbox/permission profile + `config.toml` `[projects.*]` trust set; dangerous ops gated by sandbox |
| S7 | Lifecycle hooks | Codex `notify` / app hooks configured as needed (Codex has no `.claude` SessionStart/PreToolUse/Stop hooks) |
| S8 | Reviewer / Coordinator roles | Reviewer (read+execute only, no edits) + Coordinator encoded as role instructions in `AGENTS.md` or Codex subagents |
| S9 | Context budget | Agent `AGENTS.md` < 3K tokens; deep details in `openspec/` for on-demand load |

#### 1.3 Harness — "Orchestrate Collaboration" (H1–H11)

| # | Check | Criteria (Codex) |
|:--|:--|:--|
| H1 | Workspace separation | One subdirectory per tech stack, each with its own `AGENTS.md` (+ `CLAUDE.md` mirror if cross-tool) |
| H2 | Shared spec accessible | All agents reference `../openspec/specs/` |
| H3 | Mock-first frontend | Frontend mocks APIs from the contract (MSW) |
| H4 | Git worktree isolation | Features developed in isolated worktrees/branches |
| H5 | Root `AGENTS.md` is nav hub | ≤ 120 lines; project map + build + workflow |
| H6 | Session continuity | Codex goal/plan tracking + session history keep continuity (no `/resume` `/branch` `/rewind`) |
| H7 | No dead files | Every `.md` has a clear load path (`AGENTS.md`→Codex, `CLAUDE.md`→Claude Code, specs→all). `CLAUDE.md` is NOT dead if Claude Code is used; in Codex-only it is optional |
| H8 | Zero duplication | No rule in two files the SAME tool loads. `AGENTS.md` & `CLAUDE.md` are different tools — mirroring is allowed |
| H9 | Dangerous commands gated | `rm -rf`, `git push --force`, `git reset --hard` denied by Codex sandbox / approval policy |
| H10 | Lifecycle hooks | Codex notify/app hooks configured as needed |
| H11 | Reviewer / Coordinator defined | Reviewer (read+execute only) + Coordinator as role instructions or subagents |

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

Use when a monolithic `AGENTS.md` (or `CLAUDE.md`) exists or the audit score is low.

### Phase 1: Discover
Read the root `AGENTS.md` completely and classify every section per stack:

| Content type | Belongs in |
|:--|:--|
| Business context | Root `AGENTS.md` (nav) + `openspec/project.md` |
| Build commands (mvn/gradle) | Backend Agent `AGENTS.md` |
| Build commands (pnpm/npm/yarn) | Frontend Agent `AGENTS.md` |
| Backend patterns (Java/Spring/MyBatis) | Backend Agent `AGENTS.md` |
| Frontend patterns (Vue/React/Element Plus) | Frontend Agent `AGENTS.md` |
| API paths | `openspec/specs/api/spec.md` (NOT agent files) |
| Shared naming conventions | Root `AGENTS.md` or `openspec/specs/` |

Present findings to the user and confirm stacks before generating files.

### Phase 2: Generate Agent `AGENTS.md` (per stack)
Each agent file must contain: Role, Project Overview, Before You Code, Module Structure, Coding Standards, Superpowers Workflow (as instructions), TDD, Build Commands. Explicit cross-domain prohibition in every file.

> For new files, reuse `scaffold.sh` templates (they already match this structure). For splitting an existing monolith, follow the Content Extraction Rules below.

**Content Extraction Rules:**
1. Code examples stay with their stack (Java → backend, Vue/SCSS → frontend).
2. API paths go to `openspec/specs/api/spec.md`, never agent files.
3. Response format / error codes are shared — minimal reference in both agents, authoritative definition in `specs/`.
4. Build commands split by tool (`mvn*` → backend, `pnpm*`/`npm*` → frontend).
5. Universal conventions → root `AGENTS.md` or `specs/`; domain-specific → one agent only.
6. Business context → root `AGENTS.md` only; each agent gets a one-line "System".

**Edge cases:** single stack → don't split, just add Role + NEVER + Superpowers + TDD. Already split → verify all sections present, add missing ones. Mobile + desktop frontends → separate files (different UI paradigms).

### Phase 3: Rewrite Root `AGENTS.md` (nav hub, ≤120 lines)
Project map + business context (1–3 sentences) + tech-stack table + development workflow + AI coding rules + session workflow + minimal build & test. If it exceeds 120 lines, move content to `openspec/project.md` or agent files.

### Phase 4: Verify
1. No content lost — every example/convention/command is in exactly one file.
2. No duplication — no rule in two auto-loaded files.
3. All required sections present in each agent file.
4. Cross-domain prohibition explicit in every agent file.
5. Path references correct (`../openspec/specs/` relative to each agent's dir).
6. Root `AGENTS.md` is a hub (≤120 lines, no agent instructions, no coding standards).

### Phase 5: Execute Restructuring (do not reorder)
```
1. CREATE openspec/         ← unified entry (specs/ inside)
2. CREATE agent AGENTS.md   ← one per tech stack, inside its code dir (+ CLAUDE.md mirror if cross-tool)
3. REWRITE root AGENTS.md   ← nav hub only, after all pieces exist
4. DELETE dead files        ← duplicates & orphaned docs ONLY. Never delete AGENTS.md (Codex entry); keep CLAUDE.md only if Claude Code is used
5. VERIFY no duplication    ← re-read every auto-loaded file
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
| `AGENTS.md` deleted / treated as dead | Keep it — Codex harness entry; mirror nav hub |
| Monolith `AGENTS.md` (250+ lines, multi-stack) | Split into per-directory `AGENTS.md` |
| Specs inline in `AGENTS.md` | Extract to `openspec/specs/` |
| API paths in agent files | Move to `openspec/specs/api/spec.md` |
| Duplicate rules in root + agent `AGENTS.md` | Keep in one place only |
| No role declaration | "## Role: You are a [X] Agent" |
| No cross-domain ban | Add "NEVER generate [X] code" |
| TDD as plain text | Add Superpowers 5-step workflow as explicit instructions |
| Reviewer can edit code | Reviewer role = read + execute only |
| Specs in Chinese (auto-loaded) | English — saves 30–50% tokens |
| Root `AGENTS.md` has agent rules | Root = nav hub; rules in per-stack `AGENTS.md` |
| No dangerous-command gating | Gate `rm -rf`, `git push --force` via Codex sandbox/approval |
| specs/ at root level | Move to `openspec/specs/` (unified entry) |
| Using `/opsx:` slash commands in Codex | Invoke loop skills via `$skill-name` (`$openspec-apply-change`, `$openspec-propose`, `$openspec-archive-change`) or the `openspec` CLI |

## Verification Checklist

- [ ] Auto-loaded files are English
- [ ] Root `AGENTS.md` ≤ 120 lines, nav hub only
- [ ] Each sub-`AGENTS.md` has Role + Overview + Before You Code + Standards + Superpowers + TDD + Build
- [ ] Cross-domain prohibition explicit in every sub-`AGENTS.md`
- [ ] `openspec/specs/api/spec.md` authoritative for all agents
- [ ] `openspec/changes/_template/` has `proposal.md` + `spec.md`
- [ ] Codex sandbox/approval gates dangerous commands
- [ ] Reviewer role = read + execute only
- [ ] Zero duplication across auto-loaded files
- [ ] Each sub-`AGENTS.md` < 3K tokens
- [ ] (Cross-tool) `CLAUDE.md` mirrors `AGENTS.md` and is in sync

## Multi-Stack Coordination (Cross-Stack Features)

When a feature spans >=2 stacks (e.g. frontend + backend in separate repos), a single-stack `spec-driven` change is insufficient: the agent correctly excludes the other stack via the cross-domain ban, but the "declared dependency" then has no home and is silently lost (nobody creates the sibling change). OpenSpec 1.4.1 solves this natively — scaffold.sh now auto-sets it up for >=2 stacks:

- **`openspec workspace setup --link`** — registers the independent repos as coordinated areas.
- **`openspec context-store setup`** — creates the home for initiatives.
- **`openspec initiative create`** — the **parent**: durable cross-repo intent (requirements / design / decisions / tasks). This is the "sub-process" parent tracking the whole feature.
- **`openspec new change <name> --initiative <id>`** — each repo's **child** change, linked to the parent (visible in `openspec status --change`).

Stable pattern (CLI-driven; works in Codex and Claude Code):
```
1. (once) scaffold created <project>-store + workspace <project>
2. Parent : openspec initiative create <feature> --store <project>-store --title "..."
3. Per stack (parallel), each linked to the parent:
     cd <stack-dir> && openspec new change <name> --initiative <feature> --store <project>-store
4. Implement each in its own repo (cross-domain ban unchanged; frontend mocks first).
   Cross-stack handoffs/sequencing live in the initiative's design.md / decisions.md.
5. Gate: feature done = ALL linked changes verify PASS (openspec/verify.config.yaml) -> archive each.
   Coordinator session: openspec workspace open --agent <codex-cli|claude> (neutral ground, no domain code).
```

> `--schema workspace-planning --areas ...` (a single cross-area change) is a **beta** alternative; the initiative + repo-local-change pattern above is the stable recommendation.

## OpenSpec ⇄ Discipline Loop (Codex)

OpenSpec ships Codex-native drivers: `.codex/skills/openspec-*` skills (invoked via `$`) and the `openspec` CLI. Drive the loop with `$openspec-propose` / `$openspec-apply-change` / `$openspec-verify` / `$openspec-archive-change` or the CLI, plus `AGENTS.md` discipline:

```
propose:  openspec new change <name>  →  fill proposal.md + spec.md (WHEN/THEN)
                                     (AGENTS.md tells AI to brainstorm/clarify first)
design:   (UI/page work only — before apply) build an HTML prototype first. Two paths:
          ① code-first: write HTML/CSS (or React+Tailwind/shadcn) directly → render in `browser` → `screenshot` self-check (fastest for simple pages/prototypes)
          ② `frontend-app-builder` skill: Codex as senior designer → Image Gen visual concept → user confirms → faithful code impl → `browser` + `view_image` compare to 10/10 (no Figma)
          Main stack: `build-web-apps` (`frontend-app-builder` + `shadcn-best-practices`) + `browser` + `screenshot`; default HTML/CSS for static/single-file, React+Vite only for complex apps
apply:    implement tasks.md via TDD (red→green→refactor); per-task build check
verify:   L1 build + L2 `openspec validate <name>` + L3 tests  →  write verify.md
archive:  check verify.md (overall: PASS)  →  `openspec archive <name>`
```

This is the "loop" in Loop Engineering: propose → plan → design(UI) → execute → review → verify → archive. The Superpowers discipline is not a separate installable skill here — it is the workflow encoded in `AGENTS.md` that the AI follows each cycle.
