# LoopForge

[中文文档](README-CN.md) | English

> **Solo dev juggling several legacy codebases - no specs, no tests, a pile of spaghetti - and blocked by TDD?** 【LoopForge】One command delivers an “AI-collaboration maturity” report + action plan, then scaffolds a structured Claude Code / Codex workflow - so spec-driven development runs on legacy code instead of being blocked by TDD’s iron law.

---

## Overview

LoopForge starts from a simple question: how do you keep moving when you're a solo developer maintaining multiple legacy projects in production — no spec docs, no tests, a pile of legacy spaghetti code — without getting stuck?

Excellent frameworks spec-superflow assume a greenfield or test-backed baseline; on untested legacy code they would correctly block every change. LoopForge learned from them and took a different path: a lightweight generator approach (shell + Python) that audits what's missing first, restructures without disrupting existing code, and safely degrades TDD with characterization tests and debt logging where strict rules would otherwise stall.

Built around the industrial-grade three-layer paradigm (**OpenSpec + Superpowers + Harness**, a.k.a. OSH / Loop Engineering), LoopForge ships as an AI-collaboration optimization skill in two parallel editions — each with its own `scaffold.sh` (CC edition creates `.claude/`, Codex edition creates `.codex/`):

| Edition | Skill | AI tool | Live entry file | Discipline (HOW) | Loop driver |
|:--|:--|:--|:--|:--|:--|
| Claude Code | `loopforge-cc` | Claude Code | `CLAUDE.md` | Superpowers skills in `.claude/skills/` | `/opsx:` slash commands |
| Codex | `loopforge-codex` | Codex | `AGENTS.md` | Encoded as instructions in `AGENTS.md` | `openspec` CLI + natural language |

Both editions scaffold, audit, and restructure a project's AI-collaboration structure against the OSH standard. Three modes in each:

| Mode | Purpose |
|:--|:--|
| **scaffold** | Generate a complete new framework from scratch via `scaffold.sh` |
| **audit** | 30-check maturity scoring (E1–E4, O1–O8, S1–S9, H1–H8) |
| **restructure** | Split a monolithic `CLAUDE.md` / `AGENTS.md` into per-stack agents + optimize |

**Core Philosophy:**
- **OpenSpec** defines direction (WHAT)
- **Superpowers** enforces discipline (HOW)
- **Harness** orchestrates collaboration (WHO)

**Primary use case: one-person team (OPC) taking over multiple frontend-backend separated legacy projects already in production.** The skill set provides:

- **30-check audit** to diagnose what each legacy project is missing (specs? tests? agent separation? build verification?)
- **Restructure mode** to split a monolithic `CLAUDE.md`/`AGENTS.md` into per-stack agents without disrupting existing code
- **Legacy-aware TDD** (characterization tests + debt logging) so you can safely modify untested code without freezing
- **Cross-stack coordination** (LoopForge coordination docs + workset + OpenSpec `--goal` tags) so a one-person team can orchestrate frontend + backend changes across separate repos
- **SDD (Subagent-Driven Development)** to dispatch implementer/reviewer subagents per task, preventing context bloat when juggling multiple projects
- **Compile-gated verification** via `openspec/verify.config.yaml` -- the local `/opsx:verify` L1 build check confirms each stack compiles before push. The three-layer verify produces a `verify.md` credential that gates archival

## Positioning

The differences are about **fit for the scenario, not superiority**:

| Dimension | spec-superflow | LoopForge |
|:--|:--|:--|
| Approach | Runtime (npm + Node.js hooks, always-on) | Generator (`scaffold.sh` -> static files, zero runtime dep) |
| Gate enforcement | Node.js code + unit tests (testable, robust) | shell + Python (lightweight, readable; no unit-test coverage) |
| State machine | 8 named states + unit tests | 4 phases (key paths mirrored, less granular) |
| Platform support | 17 | 2 (Claude Code + Codex) |
| Self-contained | ✅ source-level fusion | ❌ depends on OpenSpec CLI (+ Superpowers for CC) |
| Token efficiency | systematic baseline (-60.3%) | per-file budget gates |
| Legacy migration | ❌ none | ✅ audit -> restructure -> characterization tests -> debt logging |
| Cross-stack orchestration | ❌ none | ✅ per-stack agents + coordination docs |
| Compile-gated verification | ❌ none | ✅ verify.config L1 build check + verify.md |

**Where spec-superflow is the better choice (and we'd recommend it without hesitation):** greenfield projects, multi-person teams, multi-platform toolchains, projects with an existing test baseline, and anywhere strict planning→execution consistency matters. Its engineering quality — typed schemas, unit-tested gates, independently testable skills — is genuinely impressive, and we make no claim to match it.

**Where LoopForge simply happens to fit our corner:** a one-person team rescuing untested, undocumented legacy codebases — the six capabilities listed in the Overview above. spec-superflow's TDD "iron law" would *correctly* block real-code changes on a testless 5-year-old project — LoopForge adds a characterization-test + debt-logging degradation path so you can move forward safely instead of freezing.

> spec-superflow is the polished, general-purpose solution; LoopForge is a humble, scenario-specific adaptation that learned from it. If your project is already disciplined, use spec-superflow. If you're rescuing legacy code, LoopForge was built for that.

## Install

### Claude Code - `loopforge-cc`

Copy the skill into your project (auto-loaded from `.claude/skills/`):

```bash
cp -r skills/loopforge-cc /path/to/project/.claude/skills/loopforge-cc
```

Trigger via the `/loopforge-cc` slash command, or just describe the task in natural language.

### Codex - `loopforge-codex`

Install globally into Codex's skills directory, then restart Codex:

```bash
cp -R skills/loopforge-codex ~/.codex/skills/loopforge-codex
```

`scaffold.sh` ships as a real file inside the skill directory, so a plain copy is enough. After restart, the skill auto-triggers from its `description` or can be invoked explicitly via `$loopforge-codex`; `openspec init --tools codex` additionally generates Codex `/opsx:` slash commands (`/opsx:propose`, `/opsx:apply`, `/opsx:archive`, `/opsx:explore`, `/opsx:sync`).

> If you previously copied the old version into `~/.codex/skills/loop-eng`, remove it first to avoid both skills triggering on the same intent: `rm -rf ~/.codex/skills/loop-eng`.

## Scaffold a new project

Each edition has its own `scaffold.sh`. CC creates `.claude/`; Codex creates `.codex/`. Both generate `CLAUDE.md` + `AGENTS.md` mirrors:

```bash
# Claude Code (creates .claude/)
./skills/loopforge-cc/scaffold.sh myapp

# Codex (creates .codex/)
./skills/loopforge-codex/scaffold.sh myapp --tools codex

# three stacks (web + mobile)
./skills/loopforge-codex/scaffold.sh myapp --stacks backend,frontend,frontend-mobile --tools codex

# custom target dir + skip init
./skills/loopforge-cc/scaffold.sh myapp --dir ./projects/myapp --no-init
```

Options: `--stacks`, `--dir`, `--backend-dir`, `--frontend-dir`, `--mobile-dir`, `--tools` (CC defaults `claude`, Codex defaults `codex`; affects `openspec init` only), `--no-init`.

### `scaffold.sh` CLI subcommands

Beyond the default scaffold, `scaffold.sh` ships nine more subcommands (run directly or ask the AI to run them):

| Subcommand | Purpose |
|:--|:--|
| `list [opts]` | Preview the file manifest without writing anything |
| `check [project]` | Self-check (env + script) + LoopForge compliance audit; no arg = self-check only |
| `tokens [project]` | Token audit of auto-loaded files - per-file tokens + CJK% (O7 overhead) |
| `validate <change-dir>` | Validate a change's artifact structure (proposal/spec/design/tasks) |
| `changes [project]` | List all changes and their phase/status |
| `doctor [project]` | Health check: deps, scaffold, guard, verify config |
| `version` | Print LoopForge version + environment |
| `contract [--force] <change-dir>` | Auto-generate `execution-contract.md` from planning artifacts |
| `restructure [project]` | Analyze a monolithic entry file and plan a per-stack split |

> `check` runs an automatable subset (24 items: 3 env self-check + 21 structure) and prints PASS/PARTIAL/FAIL + a maturity score; ask the skill for the full 30-check semantic audit. `tokens` measures the O7 CJK overhead per file (`CJK_THRESHOLD` env, default 10%).

### What `scaffold.sh` generates

```
myapp/
├── CLAUDE.md                 ← nav hub (≤120 lines) - Claude Code entry
├── AGENTS.md                 ← nav hub for Codex (mirrors CLAUDE.md)
├── openspec/                 ← WHAT: README, project.md, specs/{api,data,errors}, changes/_template, archive
│   ├── sdd/                  ← SDD: implementer-prompt.md, reviewer-prompt.md, progress.md
│   ├── guard.sh              ← Phase gate: proposing→applying→verifying→archived
│   ├── ensure-branch.sh      ← Worktree isolation (legacy-aware git resilience)
│   ├── ensure-contract-fresh.sh ← Execution-contract freshness check
│   ├── loop-state.yaml       ← Phase state machine (phase/change/retry_count/execution_mode)
│   └── verify.config.yaml    ← Per-stack build/test commands (local /opsx:verify L1/L3)
├── .claude/  (CC edition)    ← HOW: settings.json (perms+hooks), rules/, agents/{reviewer,coordinator,implementer}
├── .codex/   (Codex edition) ← HOW: skills/openspec-* (propose/apply/verify/archive + triggers)
├── backend/{CLAUDE,AGENTS}.md   ← Backend Agent (Claude Code / Codex)
└── frontend-web/{CLAUDE,AGENTS}.md ← Frontend Agent (Claude Code / Codex)
```

`CLAUDE.md` and `AGENTS.md` are always generated together (mirrored), so the same project works in either tool. The CC edition creates `.claude/`; the Codex edition creates `.codex/` - each only creates its own tool directory. Non-destructive: existing files are skipped, safe to re-run.

### What you must install separately (per edition)

**Both:** OpenSpec CLI - `npm i -g @fission-ai/openspec@latest` (scaffold runs `openspec init` for you).

**Claude Code only:** Superpowers skills (`brainstorm`, `writing-plans`, `executing-plans`, `code-review`, `verification-before-completion`) and `frontend-design` (frontend projects). These live in `.claude/skills/` and are auto-triggered by the `/opsx:` commands.

**Codex:** nothing extra - the Superpowers 5-step discipline is already encoded as instructions in each generated `AGENTS.md`, and the loop is driven by the `openspec` CLI.

Then fill `[BRACKETS]` placeholders in `openspec/project.md`, `openspec/specs/*`, and per-stack `CLAUDE.md` / `AGENTS.md`.

## Audit an existing project

Trigger the skill (e.g. "audit my project structure"). It runs Phase 0 (environment E1–E4) + Phase 1 (30 checks) and outputs a diagnostic table, maturity grade, top issues, and an action plan.

> Codex note: `scaffold.sh check` is dual-source - it checks `AGENTS.md` first, then `.claude/` as fallback. A Codex-only project (no `.claude/`) passes E3/E4/S4/S5/S6/S8/S8b via `AGENTS.md`, no false PARTIAL/FAIL.

### Maturity scoring

```
Environment = E/4 · OpenSpec = O/8 · Superpowers = S/9 · Harness = H/8
Overall = (E + O + S + H) / 29
```

| Score | Level |
|:--|:--|
| < 33% | Pre-build |
| 33–66% | Basic |
| 66–90% | Quality |
| > 90% | Industrial |

## Restructure a monolith

When a single `CLAUDE.md` (Claude) or `AGENTS.md` (Codex) covers multiple stacks, or the audit score is low: trigger the skill to split it into per-stack Agent files, rewrite the root as a nav hub, and apply the Phase 5 restructuring order.

## License

See [LICENSE](LICENSE).

> Conversation playbook (manual): Claude Code edition [USAGE-PLAYBOOK.md](skills/loopforge-cc/USAGE-PLAYBOOK.md) · Codex edition [USAGE-PLAYBOOK-CODEX.md](skills/loopforge-codex/USAGE-PLAYBOOK-CODEX.md)
