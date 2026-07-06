# loopEng-skills

[中文文档](README-CN.md) | English

> 操作手册(对话剧本):[USAGE-PLAYBOOK.md](USAGE-PLAYBOOK.md)

---

## Overview

A single Skill for AI collaboration optimization based on the industrial-grade three-layer paradigm (**OpenSpec + Superpowers + Harness**, a.k.a. OSH / Loop Engineering):

**`loop-eng`** — Scaffold, audit, and restructure a project's AI-collaboration structure against the OSH standard. Three modes in one skill:

| Mode | Purpose |
|:--|:--|
| **scaffold** | Generate a complete new framework from scratch via `scaffold.sh` |
| **audit** | 32-check maturity scoring (E1–E4, O1–O8, S1–S9, H1–H11) |
| **restructure** | Split a monolithic `CLAUDE.md` into per-stack agents + optimize |

> v2: the previous `loop-guard` + `split-help` skills are merged into `loop-eng`. File templates now live in `scaffold.sh` (single source of truth) — the SKILL.md no longer duplicates them.

**Core Philosophy:**
- **OpenSpec** defines direction (WHAT)
- **Superpowers** enforces discipline (HOW)
- **Harness** orchestrates collaboration (WHO)

## Install

Copy the skill into your project (or any project that should use it):

```bash
cp -r skills/loop-eng /path/to/project/.claude/skills/loop-eng
```

The skill is auto-loaded by Claude Code from `.claude/skills/`.

## Scaffold a new project

```bash
# default: backend + frontend web stacks, runs `openspec init` automatically
./skills/loop-eng/scaffold.sh myapp

# three stacks (web + mobile)
./skills/loop-eng/scaffold.sh myapp --stacks backend,frontend,frontend-mobile

# custom target dir + skip init
./skills/loop-eng/scaffold.sh myapp --dir ./projects/myapp --no-init
```

Options: `--stacks`, `--dir`, `--backend-dir`, `--frontend-dir`, `--mobile-dir`, `--tools` (default `claude`), `--no-init`.

### What `scaffold.sh` generates

```
myapp/
├── CLAUDE.md                 ← nav hub (≤120 lines)
├── AGENTS.md                 ← nav hub for Codex (mirrors CLAUDE.md)
├── openspec/                 ← WHAT: README, project.md, specs/{api,data,errors}, changes/_template, archive
├── .claude/                  ← HOW: settings.json (perms+hooks), rules/, agents/{reviewer,coordinator}
│   └── (commands/ + openspec-* skills come from `openspec init`)
├── backend/{CLAUDE,AGENTS}.md   ← Backend Agent (Claude Code / Codex)
└── frontend-web/{CLAUDE,AGENTS}.md ← Frontend Agent (Claude Code / Codex)
```

> `CLAUDE.md` is the Claude Code entry; `AGENTS.md` is the Codex entry. The scaffold generates both (mirrored), so the same project works in either tool. The `loop-eng` SKILL itself is Claude-Code-side; in Codex, drive work via the `scaffold.sh` CLI + the generated `AGENTS.md` files.

Non-destructive: existing files are skipped, so it is safe to re-run.

### What you must install separately (referenced by audit, not generated)

- **OpenSpec CLI**: `npm i -g @fission-ai/openspec@latest` (scaffold runs `openspec init` for you)
- **Superpowers skills**: brainstorm, writing-plans, executing-plans, code-review, verification-before-completion
- **`frontend-design` skill** (frontend projects only)

Then fill `[BRACKETS]` placeholders in `openspec/project.md`, `openspec/specs/*`, and per-stack `CLAUDE.md` / `AGENTS.md`.

## Audit an existing project

Trigger the skill (e.g. "audit my project structure"). It runs Phase 0 (environment E1–E4) + Phase 1 (32 checks) and outputs a diagnostic table, maturity grade, top issues, and an action plan.

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

When a single `CLAUDE.md` covers multiple stacks, or the audit score is low: trigger the skill to split it into per-stack Agent `CLAUDE.md` files, rewrite the root as a nav hub, and apply the Phase 5 restructuring order.

## License

See [LICENSE](LICENSE).
