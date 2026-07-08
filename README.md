# loopEng-skills

[中文文档](README-CN.md) | English

> 对话剧本(操作手册):Claude Code 版 [USAGE-PLAYBOOK.md](skills/loop-eng-cc/USAGE-PLAYBOOK.md) · Codex 版 [USAGE-PLAYBOOK-CODEX.md](skills/loop-eng-codex/USAGE-PLAYBOOK-CODEX.md)

---

## Overview

AI collaboration optimization skills based on the industrial-grade three-layer paradigm (**OpenSpec + Superpowers + Harness**, a.k.a. OSH / Loop Engineering). Two parallel editions, each with its own `scaffold.sh` (CC edition creates `.claude/`; Codex edition creates `.codex/`):

| Edition | Skill | AI tool | Live entry file | Discipline (HOW) | Loop driver |
|:--|:--|:--|:--|:--|:--|
| Claude Code | `loop-eng-cc` | Claude Code | `CLAUDE.md` | Superpowers skills in `.claude/skills/` | `/opsx:` slash commands |
| Codex | `loop-eng-codex` | Codex | `AGENTS.md` | Encoded as instructions in `AGENTS.md` | `openspec` CLI + natural language |

Both editions scaffold, audit, and restructure a project's AI-collaboration structure against the OSH standard. Three modes in each:

| Mode | Purpose |
|:--|:--|
| **scaffold** | Generate a complete new framework from scratch via `scaffold.sh` |
| **audit** | 32-check maturity scoring (E1–E4, O1–O8, S1–S9, H1–H11) |
| **restructure** | Split a monolithic `CLAUDE.md` / `AGENTS.md` into per-stack agents + optimize |

> v2: the previous `loop-guard` + `split-help` skills are merged into `loop-eng-cc` (Claude Code edition); `loop-eng-codex` is the Codex edition. File templates live in each edition's `scaffold.sh` - the SKILL.md files no longer duplicate them.

**Core Philosophy:**
- **OpenSpec** defines direction (WHAT)
- **Superpowers** enforces discipline (HOW)
- **Harness** orchestrates collaboration (WHO)

## Install

### Claude Code — `loop-eng-cc`

Copy the skill into your project (auto-loaded from `.claude/skills/`):

```bash
cp -r skills/loop-eng-cc /path/to/project/.claude/skills/loop-eng-cc
```

Trigger via the `/loop-eng-cc` slash command, or just describe the task in natural language.

### Codex — `loop-eng-codex`

Install globally into Codex's skills directory, then restart Codex:

```bash
cp -R skills/loop-eng-codex ~/.codex/skills/loop-eng-codex
```

`scaffold.sh` ships as a real file inside the skill directory, so a plain copy is enough. After restart, the skill auto-triggers from its `description` or can be invoked explicitly via `$loop-eng-codex`; `openspec init --tools codex` additionally generates Codex `/opsx:` slash commands (`/opsx:propose`, `/opsx:apply`, `/opsx:archive`, `/opsx:explore`, `/opsx:sync`).

> If you previously copied the old Claude version into `~/.codex/skills/loop-eng`, remove it first to avoid both skills triggering on the same intent: `rm -rf ~/.codex/skills/loop-eng`.

## Scaffold a new project

Each edition has its own `scaffold.sh`. CC creates `.claude/`; Codex creates `.codex/`. Both generate `CLAUDE.md` + `AGENTS.md` mirrors:

```bash
# Claude Code (creates .claude/)
./skills/loop-eng-cc/scaffold.sh myapp

# Codex (creates .codex/)
./skills/loop-eng-codex/scaffold.sh myapp --tools codex

# three stacks (web + mobile)
./skills/loop-eng-codex/scaffold.sh myapp --stacks backend,frontend,frontend-mobile --tools codex

# custom target dir + skip init
./skills/loop-eng-cc/scaffold.sh myapp --dir ./projects/myapp --no-init
```

Options: `--stacks`, `--dir`, `--backend-dir`, `--frontend-dir`, `--mobile-dir`, `--tools` (CC defaults `claude`, Codex defaults `codex`; affects `openspec init` only), `--no-init`.

### What `scaffold.sh` generates

```
myapp/
├── CLAUDE.md                 ← nav hub (≤120 lines) — Claude Code entry
├── AGENTS.md                 ← nav hub for Codex (mirrors CLAUDE.md)
├── openspec/                 ← WHAT: README, project.md, specs/{api,data,errors}, changes/_template, archive
├── .claude/  (CC edition)    ← HOW: settings.json (perms+hooks), rules/, agents/{reviewer,coordinator}
├── .codex/   (Codex edition) ← HOW: skills/openspec-* (propose/apply/verify/archive + triggers)
├── backend/{CLAUDE,AGENTS}.md   ← Backend Agent (Claude Code / Codex)
└── frontend-web/{CLAUDE,AGENTS}.md ← Frontend Agent (Claude Code / Codex)
```

`CLAUDE.md` and `AGENTS.md` are always generated together (mirrored), so the same project works in either tool. The CC edition creates `.claude/`; the Codex edition creates `.codex/` - each only creates its own tool directory. Non-destructive: existing files are skipped, safe to re-run.

### What you must install separately (per edition)

**Both:** OpenSpec CLI — `npm i -g @fission-ai/openspec@latest` (scaffold runs `openspec init` for you).

**Claude Code only:** Superpowers skills (`brainstorm`, `writing-plans`, `executing-plans`, `code-review`, `verification-before-completion`) and `frontend-design` (frontend projects). These live in `.claude/skills/` and are auto-triggered by the `/opsx:` commands.

**Codex:** nothing extra — the Superpowers 5-step discipline is already encoded as instructions in each generated `AGENTS.md`, and the loop is driven by the `openspec` CLI.

Then fill `[BRACKETS]` placeholders in `openspec/project.md`, `openspec/specs/*`, and per-stack `CLAUDE.md` / `AGENTS.md`.

## Audit an existing project

Trigger the skill (e.g. "audit my project structure"). It runs Phase 0 (environment E1–E4) + Phase 1 (32 checks) and outputs a diagnostic table, maturity grade, top issues, and an action plan.

> Codex note: `scaffold.sh check` is dual-source - it checks `AGENTS.md` first, then `.claude/` as fallback. A Codex-only project (no `.claude/`) passes E3/E4/S4/S5/S6/S8/H9 via `AGENTS.md`, no false PARTIAL/FAIL.

### Maturity scoring

```
Environment = E/4 · OpenSpec = O/8 · Superpowers = S/9 · Harness = H/11
Overall = (E + O + S + H) / 32
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
