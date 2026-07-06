#!/usr/bin/env bash
# loop-eng scaffold — complete LoopEng project generator
# OpenSpec (WHAT) + Superpowers (HOW) + Harness (WHO)
#
# Subcommands:
#   scaffold.sh <name> [options]   generate a complete framework (default)
#   scaffold.sh list   [options]   preview the file manifest without writing
#   scaffold.sh check  [project]   self-check (env + script) + LoopEng compliance audit
#
# Non-destructive: existing files are skipped (safe to re-run).
set -euo pipefail

PROJECT_NAME=""
STACKS="backend,frontend"
TARGET_DIR=""
BACKEND_DIR="backend"
FRONTEND_DIR="frontend-web"
MOBILE_DIR="frontend-mobile"
RUN_INIT=1
TOOLS="claude"
# CJK char ratio (%) above which an auto-loaded .md is flagged Chinese (O7 check + tokens).
# Override per-run: CJK_THRESHOLD=5 ./scaffold.sh check ./myapp
CJK_THRESHOLD="${CJK_THRESHOLD:-10}"

usage() {
  cat <<'USG'
Usage: scaffold.sh <subcommand|project-name> [options]

Subcommands:
  (default) <project-name>   Generate a complete Loop Engineering framework
  list        [options]      Preview the file manifest without writing anything
  check       [project-dir]  Self-check (env + script) and LoopEng compliance audit
  tokens      [project-dir]  Token audit of auto-loaded files (O7 overhead)

Generate options:
  --stacks <list>      comma list: backend,frontend,frontend-mobile (default: backend,frontend)
  --dir <path>         target directory (default: ./<project-name>)
  --backend-dir <n>    backend code dir name (default: backend)
  --frontend-dir <n>   web frontend dir name (default: frontend-web)
  --mobile-dir <n>     mobile frontend dir name (default: frontend-mobile)
  --tools <list>       AI tool(s) for openspec init, comma list (default: claude)
  --no-init            do not run `openspec init` (init separately later)
  -h, --help           show this help

Examples:
  scaffold.sh myapp
  scaffold.sh myapp --stacks backend,frontend,frontend-mobile
  scaffold.sh list --stacks backend,frontend
  scaffold.sh check ./myapp
  scaffold.sh check                 # self-check only
  scaffold.sh tokens ./myapp      # token audit of auto-loaded files
USG
}

# ---------------- helpers ----------------
has() { [[ ",$STACKS," == *",$1,"* ]]; }

dir_for() {
  case "$1" in
    backend)          echo "$BACKEND_DIR";;
    frontend)         echo "$FRONTEND_DIR";;
    frontend-mobile)  echo "$MOBILE_DIR";;
  esac
}

label_for() {
  case "$1" in
    backend)          echo "Backend Agent";;
    frontend)         echo "Frontend Web Agent";;
    frontend-mobile)  echo "Frontend Mobile Agent";;
  esac
}

# write_if_absent <path>  — reads body from stdin; skips if file exists
write_if_absent() {
  local f="$1"
  if [[ -f "$f" ]]; then
    cat > /dev/null  # drain stdin so upstream producer (sed/cat) does not SIGPIPE under pipefail
    echo "  skip (exists): $f"
  else
    mkdir -p "$(dirname "$f")"
    cat > "$f"
    echo "  create: $f"
  fi
}

# write_both <path1> <path2> — reads body from stdin; writes to both (skips existing per file)
write_both() {
  local body; body=$(cat)
  printf '%s\n' "$body" | write_if_absent "$1"
  printf '%s\n' "$body" | write_if_absent "$2"
}

# inject_after_frontmatter <file> <marker>  — reads block from stdin; inserts it right after
# the YAML frontmatter closing '---'. Idempotent (skips if <marker> present). No-op if file missing.
inject_after_frontmatter() {
  local file="$1" marker="$2" block
  [[ -f "$file" ]] || { cat >/dev/null; echo "  skip (not generated yet): ${file#./} — run 'openspec init' first"; return 0; }
  grep -qF "$marker" "$file" && { cat >/dev/null; echo "  skip (embedded): ${file#./}"; return 0; }
  block="$(cat)"
  block="$block" awk '
    NR==1 && /^---[[:space:]]*$/ { print; fm=1; next }
    fm && /^---[[:space:]]*$/ { print; print ""; print ENVIRON["block"]; fm=0; done=1; next }
    { print }
    END { if (!done) { print ""; print ENVIRON["block"] } }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  echo "  embed: ${file#./}"
}

# autoloaded_md — print paths of auto-loaded .md in cwd (root + per-stack CLAUDE.md/AGENTS.md + .claude/rules/*.md)
autoloaded_md() {
  [[ -f CLAUDE.md ]] && printf '%s\n' CLAUDE.md
  [[ -f AGENTS.md ]] && printf '%s\n' AGENTS.md
  local d
  for d in */; do
    [[ -f "${d}CLAUDE.md" ]] && printf '%s\n' "${d}CLAUDE.md"
    [[ -f "${d}AGENTS.md" ]] && printf '%s\n' "${d}AGENTS.md"
  done
  find .claude/rules -name '*.md' 2>/dev/null
}

subst() { sed -e "s/@@PROJECT_NAME@@/$PROJECT_NAME/g" \
              -e "s/@@BACKEND_DIR@@/$BACKEND_DIR/g" \
              -e "s/@@FRONTEND_DIR@@/$FRONTEND_DIR/g" \
              -e "s/@@MOBILE_DIR@@/$MOBILE_DIR/g"; }

# ---------------- generation core (reused by scaffold + list) ----------------
generate_scaffold() {
  echo "==> Loop Engineering scaffold: $PROJECT_NAME"
  echo "    target: $TARGET_DIR"
  echo "    stacks: $STACKS"
  mkdir -p "$TARGET_DIR"
  cd "$TARGET_DIR"

  # ---------- 0. openspec init (generates openspec/, .claude/commands/, base skills) ----------
  if [[ $RUN_INIT -eq 1 ]]; then
    if command -v openspec >/dev/null 2>&1; then
      echo "==> Running: openspec init --tools $TOOLS"
      openspec init --tools "$TOOLS" || echo "  warn: openspec init failed or already initialized"
    else
      echo "  warn: openspec CLI not found."
      echo "        install: npm i -g @fission-ai/openspec@latest"
      echo "        then run 'openspec init' in $TARGET_DIR"
    fi
  fi


  # ---------- 0b. LoopEng runtime enhancements (/opsx:verify command + Superpowers triggers) ----------
  # openspec init ships 5 commands (propose/apply/archive/sync/explore) but NOT /opsx:verify, and the
  # generated propose/apply/archive are plain CLI flows with no Superpowers trigger / verify gate.
  # Loop-eng layers these on so the documented loop (propose->apply->verify->archive) is real.
  echo "==> Layering LoopEng runtime enhancements (/opsx:verify + Superpowers triggers)"
  mkdir -p .claude/commands/opsx

  cat <<'__LOOPENG_VERIFY_CMD__' | write_if_absent .claude/commands/opsx/verify.md
---
name: "OPSX: Verify"
description: Three-layer verification (L1 build / L2 spec alignment / L3 tests) for a change — writes verify.md as the archive credential
category: Workflow
tags: [workflow, verification, experimental]
---

Three-layer verification for an OpenSpec change. Confirms the implementation actually satisfies the spec's WHEN/THEN scenarios, then writes a `verify.md` credential into the change directory that `/opsx:archive` checks before archiving.

**The three layers**

| Layer | What it checks | How |
|:--|:--|:--|
| **L1 Build** | Code compiles / builds | Runs each affected stack's build command |
| **L2 Spec alignment** | Code implements the spec's WHEN/THEN scenarios | Reviewer-style audit: per scenario, find code evidence, score IMPLEMENTED / PARTIAL / NOT_IMPLEMENTED |
| **L3 Tests** | Existing test suite passes | Runs each affected stack's test command (SKIP if none) |

**Overall status** (written into `verify.md`, read by `/opsx:archive`)

| Overall | Rule | Archive |
|:--|:--|:--|
| `PASS` | L1 + L3 pass, every scenario IMPLEMENTED | ✅ direct |
| `PASS_WITH_ISSUES` | L1 + L3 pass, ≥1 scenario PARTIAL | ⚠ confirm first |
| `FAIL` | any L1 build failed / any L3 test failed / any scenario NOT_IMPLEMENTED | ❌ fix first |
| `NOT_RUN` | no verify.md yet | ⚠ archive warns |

---

**Input**: Optionally specify a change name (e.g., `/opsx:verify add-auth`). If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **Select the change**

   If a name is provided, use it. Otherwise:
   - Infer from conversation context if the user mentioned a change
   - Auto-select if only one active change exists
   - If ambiguous, run `openspec list --json` to get available changes and use the **AskUserQuestion tool** to let the user select

   Always announce: "Using change: <name>" and how to override (e.g., `/opsx:verify <other>`).

2. **Resolve change context**

   ```bash
   openspec status --change "<name>" --json
   ```

   Parse the JSON for:
   - `changeRoot` — where to write `verify.md`
   - `artifactPaths.specs.existingOutputPaths` — delta spec files holding the WHEN/THEN scenarios (the L2 source of truth)
   - `planningHome` — to locate `verify.config.yaml` (see step 4) and per-stack `CLAUDE.md`
   - `actionContext.allowedEditRoots` / stack hints — which stacks are affected

   **Workspace guard:** If status reports `actionContext.mode: "workspace-planning"`, explain that workspace verification is not supported in this slice and STOP. Do not run builds against linked repos.

3. **Validate artifacts first (fail fast)**

   ```bash
   openspec validate "<name>" --json
   ```

   If validation reports malformed specs/tasks, STOP and report — there is no point verifying against a broken spec. Suggest `/opsx:propose` to fix the spec.

4. **Load the verify config (build & test commands per stack)**

   Resolution order (use the first that yields commands):
   a. **`openspec/verify.config.yaml`** (project-level, authoritative). Schema:
      ```yaml
      stacks:
        <stack-id>:
          dir: <stack-dir>        # relative to project root
          build: <build-cmd>      # L1
          test: <test-cmd> | null # L3; null or omitted => SKIP
      ```
   b. **Infer from per-stack `CLAUDE.md`** — read each affected stack's `CLAUDE.md`, extract commands from its `## Build Commands` (→ L1) and `## Test` (→ L3) sections.
   c. **Ask once and persist** — use the **AskUserQuestion tool** to ask for the build (and optional test) command per affected stack, then write the answers to `openspec/verify.config.yaml` so future runs are deterministic.

   Identify **affected stacks** from: status JSON `allowedEditRoots`, the change's `design.md`, or `tasks.md` stack tags. If only one stack exists, use it.

5. **L1 — Build check (per affected stack)**

   For each affected stack, run its build command **inside that stack's `dir`**:
   ```bash
   cd "<stack-dir>" && <build-cmd>
   ```
   - Capture exit code and tail of output.
   - Record `L1 = PASS` (exit 0) or `L1 = FAIL` (non-zero) with the failing output.
   - If a stack has no build command, record `L1 = SKIP`.

6. **L2 — Spec alignment (reviewer-style, agent-driven)**

   This is the core layer. It is NOT a CLI call — it is a semantic audit you perform.

   a. **Read every delta spec** from `artifactPaths.specs.existingOutputPaths`. Extract each `## Scenario:` block and its WHEN/THEN clauses. These scenarios ARE the verification cases.
   b. **For each scenario**, search the affected stacks' code for implementation evidence:
      - Use `rg` to find the code path(s) the scenario describes (e.g., a route handler, a component, a service method).
      - Read the matched code to confirm it actually fulfills the WHEN/THEN.
      - **Honor `verify-meta`**: if the scenario carries an HTML comment such as
        `<!-- verify-meta: { "endpoint": "POST /api/repair", "expectedStatus": 201 } -->`,
        use the structured fields for a precise check (does that exact route exist? does it return that status?). Absent `verify-meta`, fall back to semantic matching.
      - **Cross-domain rule**: a backend scenario is checked against backend code only; a frontend scenario against frontend code only. Never cite a frontend file as evidence for a backend scenario, and vice versa.
   c. **Score each scenario**:
      - `✓ IMPLEMENTED` — clear, working evidence found → cite `file:line`
      - `⚠ PARTIAL` — partial / fragile / missing edge case → cite what's there and what's missing
      - `✗ NOT_IMPLEMENTED` — no evidence found → state what the spec requires vs. what exists
   d. Tally: `N/M scenarios implemented`.

7. **L3 — Test execution (per affected stack)**

   For each affected stack with a non-null test command, run it inside that stack's `dir`:
   ```bash
   cd "<stack-dir>" && <test-cmd>
   ```
   - Record `L3 = PASS` (exit 0) with pass/fail counts, or `L3 = FAIL` with the failing test names.
   - Stacks with `test: null` record `L3 = SKIP` (e.g., "仅 ops_wechat 有 Vitest，其他子项目报 SKIP").

8. **Compute overall status**

   Apply in order (first match wins):
   - `FAIL` if any L1 = FAIL **or** any L3 = FAIL **or** any scenario = NOT_IMPLEMENTED
   - `PASS_WITH_ISSUES` if L1 + L3 all pass/SKIP **and** ≥1 scenario = PARTIAL
   - `PASS` if L1 + L3 all pass/SKIP **and** every scenario = IMPLEMENTED
   - (NOT_RUN is only the pre-verify state; once you run, the result is one of the above three.)

9. **Write `verify.md` to `<changeRoot>/verify.md`**

   This file is the archive credential. Use the template in `openspec/verify-result.template.md`. Its YAML frontmatter MUST be machine-readable because `/opsx:archive` parses `overall` from it:
   ```yaml
   ---
   verify:
     change: <name>
     date: YYYY-MM-DD
     overall: PASS | PASS_WITH_ISSUES | FAIL
     stacks:
       <stack-id>:
         L1: PASS | FAIL | SKIP
         L2: "<implemented>/<total>"
         L3: PASS | FAIL | SKIP
   ---
   ```
   Followed by the human-readable tables (per-stack L1/L2/L3 + scenario alignment detail + issues).

10. **Display the report and suggest the next action**

    Match the report format below. Then:
    - `FAIL` → list blocking issues, suggest `/opsx:apply <name>` to fix
    - `PASS_WITH_ISSUES` → list PARTIALs, ask "要我修复吗?" → if yes, hand off to `/opsx:apply`
    - `PASS` → suggest `/opsx:archive <name>`

**Output (report)**

```
## 验证结果: <change-name>

### <stack-id>
| 层级 | 状态 | 详情 |
|:---|:---|:---|
| L1 构建 | ✓ PASS | <build-cmd> 成功 |
| L2 规格对齐 | 5/6 已实现 | 1 PARTIAL |
| L3 测试 | ✓ PASS | 4/4 测试通过 |

### 场景对齐详情
| 场景 | 状态 | 证据 |
|:---|:---|:---|
| 提交报修单 | ✓ 已实现 | repair.vue:42-58 |
| 提交后刷新列表 | ⚠ PARTIAL | 缺少刷新逻辑 |

总体: PASS_WITH_ISSUES
要我修复那个 PARTIAL 吗?
```

**Guardrails**
- `verify.md` is the single source of truth for verification status — always (over)write it at the end, even on FAIL, so the record is honest.
- Never mark a scenario IMPLEMENTED without a concrete `file:line` evidence citation.
- Never run a build/test command outside its stack's `dir`.
- Never let backend evidence satisfy a frontend scenario or vice versa (cross-domain prohibition).
- L2 is judgment work — if you cannot find evidence, score NOT_IMPLEMENTED and say so; do not guess.
- If `verify.config.yaml` is missing, create it from the first run so subsequent runs are deterministic (do not re-ask).
- Do not modify any source code during verify — verification is read/execute only. Fixes belong to `/opsx:apply`.

**Fluid Workflow Integration**
- Re-runnable any number of times; each run overwrites `verify.md`.
- After a `/opsx:apply` fix, re-run `/opsx:verify` to refresh the credential before archiving.
__LOOPENG_VERIFY_CMD__

  cat <<'__LOOPENG_VERIFY_CFG__' | write_if_absent openspec/verify.config.yaml
# OpenSpec verify configuration
# /opsx:verify reads L1 (build) and L3 (test) commands from here.
# Place at: <project>/openspec/verify.config.yaml
#
# - `build` is required for L1; omit/leave null to SKIP L1 for a stack.
# - `test`  is optional for L3; omit/leave null to SKIP L3 (report SKIP, not FAIL).
# - `dir` is the stack directory relative to the project root; builds/tests run there.

stacks:
  ops_wechat:
    dir: ops_wechat
    build: pnpm build:mp
    test: pnpm test            # Vitest
  backend:
    dir: backend
    build: mvn compile -q
    test: mvn test -q
  ops_admin:
    dir: ops_admin
    build: pnpm build
    test: null                 # no test runner -> L3 SKIP
__LOOPENG_VERIFY_CFG__

  cat <<'__LOOPENG_VERIFY_TPL__' | write_if_absent openspec/verify-result.template.md
<!--
  Written by /opsx:verify. This file is the archive credential — /opsx:archive
  parses the `overall` field below. Do not hand-edit; re-run /opsx:verify to refresh.
-->
---
verify:
  change: CHANGE_NAME
  date: YYYY-MM-DD
  overall: PASS_WITH_ISSUES   # PASS | PASS_WITH_ISSUES | FAIL
  stacks:
    STACK_ID:
      L1: PASS                 # PASS | FAIL | SKIP
      L2: "5/6"                # implemented/total scenarios
      L3: PASS                 # PASS | FAIL | SKIP
---

# 验证结果: CHANGE_NAME

> 生成时间: YYYY-MM-DD · 总体: **PASS_WITH_ISSUES**

## STACK_ID

| 层级 | 状态 | 详情 |
|:---|:---|:---|
| L1 构建 | ✓ PASS | <build-cmd> 成功 |
| L2 规格对齐 | 5/6 已实现 | 1 PARTIAL |
| L3 测试 | ✓ PASS | 4/4 测试通过 |

## 场景对齐详情

| 场景 | 状态 | 证据 |
|:---|:---|:---|
| 提交报修单 | ✓ 已实现 | repair.vue:42-58 |
| 提交后刷新列表 | ⚠ PARTIAL | 缺少刷新逻辑 |

## 发现的问题

⚠ PARTIAL: "提交后刷新列表"
- 期望: 提交报修单后列表自动刷新
- 实际: repair.vue 提交成功后未调用列表刷新
- 建议: 提交回调中 emit 事件或调用 store.refresh()

## 下一步

- PASS → `/opsx:archive CHANGE_NAME`
- PASS_WITH_ISSUES → 确认后归档，或 `/opsx:apply CHANGE_NAME` 修复 PARTIAL
- FAIL → `/opsx:apply CHANGE_NAME` 修复阻断项后重新 `/opsx:verify`
__LOOPENG_VERIFY_TPL__

  cat <<'__LOOPENG_TRIG__' | inject_after_frontmatter .claude/commands/opsx/propose.md '<!-- LoopEng: superpowers-trigger-propose -->'
<!-- LoopEng: superpowers-trigger-propose -->
## Superpowers Integration (auto-triggered — LoopEng loop start)

Before writing artifacts, ground the spec in real requirements:
1. **Activate `brainstorm`** — clarify goals/scope/edge cases with the user; ask questions; do NOT write the proposal until the user confirms understanding.
2. **Use `writing-plans`** — structure confirmed requirements into proposal/design/tasks/spec; write concrete WHEN/THEN scenarios (these become /opsx:verify L2 cases later).
3. Then proceed to the `openspec new change` / `openspec status` / `openspec instructions` steps below.

> If Superpowers skills are not installed, apply the same discipline manually (loop-eng scaffold lists them as separate skills to install).
<!-- /LoopEng: superpowers-trigger-propose -->
__LOOPENG_TRIG__

  cat <<'__LOOPENG_TRIG__' | inject_after_frontmatter .claude/commands/opsx/apply.md '<!-- LoopEng: superpowers-trigger-apply -->'
<!-- LoopEng: superpowers-trigger-apply -->
## Superpowers Integration (auto-triggered — TDD discipline)

1. **Activate `executing-plans`** before coding — tasks in order, smallest scope first.
2. After each task code change: **`code-review`** the diff against the spec WHEN/THEN.
3. **Per-task build check (L1 quick verify):** after the code change, before marking the task done, run the affected stack build command from `openspec/verify.config.yaml` inside that stack dir. On PASS print `✓ 构建检查通过`; on FAIL do NOT mark done — pause and report. (Reuses the same config as /opsx:verify — one source of truth.)
4. On full completion: **`verification-before-completion`**, then suggest `/opsx:verify <change>` (not archive directly).
<!-- /LoopEng: superpowers-trigger-apply -->
__LOOPENG_TRIG__

  cat <<'__LOOPENG_TRIG__' | inject_after_frontmatter .claude/commands/opsx/archive.md '<!-- LoopEng: verify-gate-archive -->'
<!-- LoopEng: verify-gate-archive -->
## Pre-archive Gate (verify credential — mandatory, runs before the archive move)

Check for `verify.md` in the change root:
- **Missing** -> warn "未找到 verify.md，该 change 尚未验证"; recommend `/opsx:verify "<name>"`; ask 否(推荐)/是; on 否 STOP.
- **overall: FAIL** -> block: print blocking issues, STOP, suggest `/opsx:apply` then `/opsx:verify`.
- **overall: PASS_WITH_ISSUES** -> warn PARTIALs, confirm before proceeding.
- **overall: PASS** -> proceed.

Read `verify.overall` from verify.md YAML frontmatter (written by /opsx:verify). Runs after the spec-sync assessment and before `mv` into archive/.
<!-- /LoopEng: verify-gate-archive -->
__LOOPENG_TRIG__

  # ---------- 1. openspec/  (WHAT — shared truth) ----------
  echo "==> Creating openspec/ (WHAT)"
  mkdir -p openspec/specs openspec/changes/_template openspec/archive

  cat <<'EOF' | subst | write_if_absent openspec/README.md
# OpenSpec — Shared Truth (WHAT)

This directory is the **single source of truth** for WHAT to build.

## Structure
- `specs/` — static contracts (`api/`, `data/`, `errors/`). Authoritative; all agents reference it.
- `changes/` — dynamic delta proposals (active work). Start from `_template/`.
- `archive/` — completed proposals (history).
- `project.md` — tech stack, module map, architecture (no coding conventions).

## Responsibility Separation
| Layer | Location | Role |
|:--|:--|:--|
| Spec (here) | `openspec/` | WHAT — shared truth |
| Discipline | `.claude/` | HOW — TDD, review, quality gates |
| Harness | `CLAUDE.md` + agents | WHO — roles, boundaries |

## Workflow
1. `/opsx:propose <change>` — brainstorm + write proposal (auto-triggers Superpowers)
2. `/opsx:apply` — implement per spec (TDD enforced)
3. `/opsx:archive` — move completed proposal to `archive/`
EOF

  cat <<'EOF' | subst | write_if_absent openspec/project.md
# Project Overview — @@PROJECT_NAME@@

## System
@@PROJECT_NAME@@ — [one-line business description]

## Tech Stack
| Layer | Tech |
|:--|:--|
| Backend | [e.g. Java 17 + Spring Boot 3 + MyBatis] |
| Frontend | [e.g. Vue 3 + Vite + Element Plus] |
| Database | [e.g. MySQL 8] |

## Module Map
[Directory tree of code modules]

## Architecture
[High-level architecture: layers, data flow, external integrations]

> No coding conventions here — those live in `.claude/rules/` and per-stack `CLAUDE.md`.
EOF

  cat <<'EOF' | write_if_absent openspec/specs/README.md
# Specs — Static Contracts

Authoritative contracts all agents must follow.
- `api/spec.md` — API contract (endpoints, request/response). Frontend mocks from it; backend implements to it.
- `data/spec.md` — data models, schemas.
- `errors/spec.md` — error codes, response format.

Every spec must include WHEN/THEN verification scenarios (executable acceptance criteria).
EOF

  cat <<'EOF' | write_if_absent openspec/specs/api/spec.md
# API Contract

> Authoritative. Frontend mocks from this; backend implements to this.

## Conventions
- Base URL: `/api/v1`
- Response envelope: `{ "code": 0, "data": {}, "message": "" }`

## Endpoints

### [Resource]

#### WHEN [scenario / actor intent]
- `GET /api/v1/[resource]` — [description]
  - Response: `[field]: [type]`

#### THEN [expected outcome]
- Returns `code: 0` with `[payload]`
EOF

  cat <<'EOF' | write_if_absent openspec/specs/data/spec.md
# Data Model

## Entities

### [Entity]
| Field | Type | Constraints | Notes |
|:--|:--|:--|:--|
| id | bigint | PK, auto-increment | |
| created_at | datetime | not null | UTC |
EOF

  cat <<'EOF' | write_if_absent openspec/specs/errors/spec.md
# Error Handling

## Error Codes
| Code | HTTP | Meaning |
|:--|:--|:--|
| 0 | 200 | Success |
| 40001 | 400 | [Bad request — validation] |
| 40401 | 404 | [Resource not found] |
| 50001 | 500 | [Internal error] |

## Error Response
```json
{ "code": 40001, "data": null, "message": "[description]" }
```
EOF

  cat <<'EOF' | write_if_absent openspec/changes/_template/proposal.md
# Proposal: [Change Name]

## Why
[Business reason — what problem this solves]

## What
[Summary of the change]

## Scope
- In scope: [list]
- Out of scope: [list]

## Success Criteria
- [Measurable outcomes]

## Constraints
- [Technical / business constraints]

## Risks
- [Risk] → [Mitigation]
EOF

  cat <<'EOF' | write_if_absent openspec/changes/_template/spec.md
# Spec Delta: [Change Name]

## Data Model
[New / changed entities — reference `specs/data/spec.md`]

## API
[New / changed endpoints — reference `specs/api/spec.md`]

## Business Rules
[Rules introduced or changed]

## Error Handling
[New error codes — reference `specs/errors/spec.md`]

## Verification Scenarios
### WHEN [scenario]
THEN [expected outcome]
EOF

  cat <<'EOF' | write_if_absent openspec/changes/README.md
# Changes — Delta Proposals

Active work lives here. Each proposal is a directory containing:
- `proposal.md` — Why / What / Scope / Success Criteria / Constraints / Risks
- `spec.md` — Data Model / API / Business Rules / Errors / WHEN-THEN verification

Start from `_template/`. On completion, move the directory to `../archive/` via `/opsx:archive`.
EOF
  touch openspec/archive/.gitkeep

  # ---------- 2. .claude/  (HOW — discipline) ----------
  echo "==> Creating .claude/ (HOW)"
  mkdir -p .claude/rules .claude/skills .claude/agents .claude/commands

  cat <<'EOF' | write_if_absent .claude/settings.json
{
  "permissions": {
    "allow": [
      "Bash(openspec:*)",
      "Bash(npm:*)",
      "Bash(pnpm:*)",
      "Bash(mvn:*)",
      "Bash(gradle:*)",
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)"
    ]
  },
  "hooks": {
    "SessionStart": [
      { "matcher": "*", "hooks": [ { "type": "command", "command": "echo '[loop-eng] session started'" } ] }
    ],
    "PreToolUse": [
      { "matcher": "Edit|Write", "hooks": [ { "type": "command", "command": "echo '[loop-eng] pre-edit gate'" } ] }
    ],
    "Stop": [
      { "matcher": "*", "hooks": [ { "type": "command", "command": "echo '[loop-eng] session stop'" } ] }
    ]
  }
}
EOF
  echo "  note: replace hook placeholder commands with real scripts (e.g. lint/format gates)."

  cat <<'EOF' | write_if_absent .claude/rules/naming.md
---
globs: ["backend/**", "frontend-web/**", "frontend-mobile/**"]
---
<!-- auto-loaded: English only. Human notes: docs/GUIDE.zh.md -->
# Naming Conventions (shared)

- File names: kebab-case (`user-service.ts`)
- [Add stack-specific rules in per-stack CLAUDE.md; only truly universal rules here]
EOF
  touch .claude/rules/.gitkeep .claude/skills/.gitkeep .claude/commands/.gitkeep

  cat <<'EOF' | write_if_absent .claude/agents/reviewer.md
---
name: reviewer
description: Code reviewer — read-only audit, never edits files.
tools: Read, Bash
---
You are a **Code Reviewer Agent**. Read code and run checks/commands.
**NEVER edit files.** Report issues with `file:line` references and severity (blocker / major / minor).
Verify implementation against `openspec/specs/` WHEN/THEN scenarios.
EOF

  cat <<'EOF' | write_if_absent .claude/agents/coordinator.md
---
name: coordinator
description: Orchestrates multi-agent workflow; delegates to domain agents.
tools: Read, Bash, Edit, Write
---
You are the **Coordinator Agent**. Delegate work to domain agents (backend / frontend).
**NEVER write domain code yourself.** Track proposals in `openspec/changes/`, route review to the `reviewer` agent.
EOF

  # ---------- 3. Per-stack Agent CLAUDE.md (WHO) ----------
  echo "==> Creating Agent CLAUDE.md per stack"

  gen_agent() {
    local stack="$1"
    local dir="$2"
    local label="$3"
    case "$stack" in
      backend)
        cat <<EOF | subst | write_both "$dir/CLAUDE.md" "$dir/AGENTS.md"
<!-- auto-loaded: English only. Human notes: docs/GUIDE.zh.md -->
# CLAUDE.md — @@PROJECT_NAME@@ $label

## Role
You are a **$label**. Your scope: server-side logic, APIs, data access, business rules.
**NEVER generate frontend code** (that lives in \`../@@FRONTEND_DIR@@/CLAUDE.md\`).
**NEVER modify \`../openspec/specs/\`** — specs are shared truth, read-only.

## Project Overview
- **System**: @@PROJECT_NAME@@ — [one-line business description]
- **Stack**: [e.g. Java 17 + Spring Boot 3 + MyBatis]
- **Database**: [e.g. MySQL 8]

## Before You Code
1. Read \`../openspec/specs/api/spec.md\` (authoritative contract)
2. Read \`../openspec/specs/data/spec.md\` and \`../openspec/specs/errors/spec.md\`
3. Check \`../openspec/changes/\` for active proposals
4. If no spec exists, run \`/opsx:propose\` first — never code without a spec

## Module Structure
[Describe backend module layout]

## Coding Standards
- [Domain-specific conventions; shared conventions in \`../.claude/rules/\`]
- Never modify existing public methods — use overloading
- New behavior = new method/class

## Superpowers Workflow (auto-triggered by /opsx:propose, /opsx:apply)
1. brainstorm → clarify requirements
2. writing-plans → TDD plan
3. executing-plans → implement (tests first)
4. code-review → self/peer review
5. verification-before-completion → prove it against WHEN/THEN

## TDD
- Red: write a failing test for the WHEN/THEN scenario
- Green: minimum code to pass
- Refactor: keep tests green

## Build Commands
\`\`\`
[mvn clean test | ./gradlew test | ...]
\`\`\`
EOF
        ;;
      frontend|frontend-mobile)
        cat <<EOF | subst | write_both "$dir/CLAUDE.md" "$dir/AGENTS.md"
<!-- auto-loaded: English only. Human notes: docs/GUIDE.zh.md -->
# CLAUDE.md — @@PROJECT_NAME@@ $label

## Role
You are a **$label**. Your scope: UI, components, state, API integration.
**NEVER generate backend code** (that lives in \`../@@BACKEND_DIR@@/CLAUDE.md\`).
**NEVER modify \`../openspec/specs/\`** — specs are shared truth, read-only.

## Project Overview
- **System**: @@PROJECT_NAME@@ — [one-line business description]
- **Stack**: [e.g. Vue 3 + Vite + Element Plus (web) / Vant (mobile)]

## Before You Code
1. Read \`../openspec/specs/api/spec.md\` — mock from it (MSW), do not invent endpoints
2. Read \`../openspec/specs/errors/spec.md\` — handle every error code
3. Check \`../openspec/changes/\` for active proposals
4. If no spec exists, run \`/opsx:propose\` first — never code without a spec

## Mock-First
- Mock APIs from \`../openspec/specs/api/spec.md\` (MSW)
- UI prototype via \`frontend-design\` skill → **user confirms** → then \`/opsx:apply\`

## Module Structure
[Describe frontend module/layout]

## Coding Standards
- [Domain-specific conventions; shared conventions in \`../.claude/rules/\`]
- Never modify existing components — compose or extend

## Superpowers Workflow (auto-triggered by /opsx:propose, /opsx:apply)
1. brainstorm → clarify requirements
2. writing-plans → TDD plan
3. executing-plans → implement (tests first)
4. code-review → self/peer review
5. verification-before-completion → prove it against WHEN/THEN

## TDD
- Red: failing component/unit test for the WHEN/THEN scenario
- Green: minimum code to pass
- Refactor: keep tests green

## Build Commands
\`\`\`
[pnpm dev | pnpm test | pnpm build | ...]
\`\`\`
EOF
        ;;
    esac
  }

  if has backend;         then mkdir -p "$BACKEND_DIR";  gen_agent backend         "$BACKEND_DIR"  "$(label_for backend)";        touch "$BACKEND_DIR/.gitkeep"; fi
  if has frontend;        then mkdir -p "$FRONTEND_DIR"; gen_agent frontend        "$FRONTEND_DIR" "$(label_for frontend)";       touch "$FRONTEND_DIR/.gitkeep"; fi
  if has frontend-mobile; then mkdir -p "$MOBILE_DIR";   gen_agent frontend-mobile "$MOBILE_DIR"   "$(label_for frontend-mobile)"; touch "$MOBILE_DIR/.gitkeep"; fi

  # ---------- 4. Root CLAUDE.md (nav hub, <=120 lines) ----------
  echo "==> Creating root CLAUDE.md (nav hub)"
  {
    echo "<!-- auto-loaded: English only. Human notes: docs/GUIDE.zh.md -->"
    echo "# @@PROJECT_NAME@@"
    echo ""
    echo "> Structured per OpenSpec + Superpowers + Harness (Loop Engineering)."
    echo "> Launch agents from their subdirectories (Claude Code: \`claude\`; Codex: \`codex\`)."
    echo ""
    echo "## Project Map"
    echo '```'
    echo "@@PROJECT_NAME@@/"
    echo "├── CLAUDE.md          ← nav hub (≤120 lines)"
    echo "├── openspec/          ← WHAT: specs/, changes/, archive/"
    echo "├── .claude/           ← HOW: rules/, skills/, agents/, settings.json"
    if has backend;         then echo "├── @@BACKEND_DIR@@/      ← $(label_for backend)"; fi
    if has frontend;        then echo "├── @@FRONTEND_DIR@@/     ← $(label_for frontend)"; fi
    if has frontend-mobile; then echo "├── @@MOBILE_DIR@@/   ← $(label_for frontend-mobile)"; fi
    echo '```'
    echo ""
    echo "## Business Context"
    echo "[1–3 sentences from openspec/project.md]"
    echo ""
    echo "## Tech Stack"
    echo "| Layer | Tech |"
    echo "|:--|:--|"
    if has backend;         then echo "| Backend | [fill] |"; fi
    if has frontend;        then echo "| Frontend (web) | [fill] |"; fi
    if has frontend-mobile; then echo "| Frontend (mobile) | [fill] |"; fi
    echo ""
    echo "## Development Workflow"
    echo "### New Feature"
     echo "1. Write spec: \`/opsx:propose <change>\` (auto-triggers Superpowers brainstorm)"
     if has backend && (has frontend || has frontend-mobile); then
      echo "2. Backend Agent: \`cd @@BACKEND_DIR@@\` → launch AI (claude/codex) → implement to spec (TDD)"
      echo "3. Frontend Agent (parallel): \`cd @@FRONTEND_DIR@@\` → launch AI (claude/codex) → mock from spec → \`frontend-design\` skill → UI prototype → **user confirms** → \`/opsx:apply\`"
     echo "4. Verify against WHEN/THEN; \`/opsx:archive\` when done"
    else
      echo "2. Agent: \`cd <stack-dir>\` → launch AI (claude/codex) → implement to spec (TDD)"
     echo "3. Verify against WHEN/THEN; \`/opsx:archive\` when done"
    fi
    echo ""
    echo "### AI Coding Rules"
    echo "- Spec first — read \`openspec/specs/\` before writing code"
    if has frontend || has frontend-mobile; then echo "- UI prototype first — \`frontend-design\` skill before \`/opsx:apply\`"; fi
    echo "- TDD — Superpowers auto-enforces"
    echo "- No cross-domain — each agent writes only its own stack"
    echo "- Never modify existing methods — use overloading"
    echo ""
    echo "### Session Commands"
    echo "\`/resume\` · \`/branch\` · \`/rewind\`"
    echo ""
    echo "## Build & Test"
    echo '```'
    echo "[3–5 commands covering all stacks; details in per-stack CLAUDE.md]"
    echo '```'
  } | subst | write_both CLAUDE.md AGENTS.md

  cat <<'EOF' | subst | write_if_absent README.md
# @@PROJECT_NAME@@

Generated by **loop-eng scaffold** (OpenSpec + Superpowers + Harness).

See `CLAUDE.md` / `AGENTS.md` (nav hub) and `openspec/README.md`.
EOF

  cat <<'EOF' | write_if_absent .gitignore
node_modules/
dist/
build/
target/
*.log
.DS_Store
.env
EOF

  # ---------- docs/ human guide (Chinese, NOT auto-loaded) ----------
  mkdir -p docs
  cat <<'__GUIDE_ZH__' | subst | write_if_absent docs/GUIDE.zh.md
# @@PROJECT_NAME@@ 项目指南（人类阅读）

> ⚠️ 非权威文档，仅供人类阅读。
> AI 自动加载的文件（根/各栈 `CLAUDE.md`、`AGENTS.md`、`.claude/rules/*.md`）均为英文且为真相源；
> 本文件与它们不一致时，以英文文件为准。本文件位于 `docs/`，不在任何自动加载路径中（Claude/Codex 不加载 docs/）。

## 这是什么
本项目用 Loop Engineering 框架协作开发：OpenSpec 定方向（WHAT）、Superpowers 强纪律（HOW）、Harness 编协作（WHO）。
每个功能走闭环：propose → apply → verify → archive。

## 去哪找什么
| 你想找的 | 位置 | 语言 |
|:--|:--|:--|
| 项目业务/架构/模块图 | `openspec/project.md` | 英文 |
| API/数据/错误契约 | `openspec/specs/` | 英文 |
| 各技术栈编码规范 | `<stack>/CLAUDE.md` | 英文 |
| 命名等通用规则 | `.claude/rules/*.md` | 英文 |
| 斜杠命令用法 | `.claude/commands/opsx/` | 英文 |
| 构建测试配置（验证用） | `openspec/verify.config.yaml` | 英文 |
| 本人类导览 | `docs/GUIDE.zh.md`（本文件） | 中文 |

## 日常工作流（中文口语版）
1. 想做新功能 → 说"我要加 xxx 功能"或 `/opsx:propose <名字>`，AI 先澄清需求再写 spec
2. 实施 → `/opsx:apply <名字>`，AI 按 TDD 逐任务实现，每任务后跑构建检查
3. 验证 → `/opsx:verify <名字>`，跑三层（构建/规格对齐/测试），生成 `verify.md`
4. 归档 → `/opsx:archive <名字>`，检查 `verify.md` 门禁后归档

## 约定速记
- 先 spec 后代码：没有 spec 不写代码
- 跨域禁止：后端 agent 不写前端代码，反之亦然
- 自动加载文件只写英文：中文说明写在本文件，避免每会话浪费 token
- 验证凭证：`verify.md` 是归档的通行证

## 常用命令
- `scaffold.sh check ./<project>` — 审计项目合规度（含 O7 中文检查）
- `scaffold.sh tokens ./<project>` — 测自动加载文件 token 数与中文占比
- `scaffold.sh list` — 预览脚手架生成哪些文件

> 维护提示：英文 auto-loaded 文件改了，按需把关键点同步到本文件即可，不必逐行对照。
__GUIDE_ZH__

  # ---------- done ----------
  echo ""
  echo "==> Scaffold complete: $TARGET_DIR"
  echo ""
  echo "Next steps:"
  echo "  1. cd $TARGET_DIR"
  if [[ $RUN_INIT -eq 0 ]]; then echo "  2. openspec init   (generate slash commands + base skills)"; fi
  echo "  3. Install on-demand skills not generated here:"
  echo "     - Superpowers set (brainstorm / writing-plans / executing-plans / code-review / verification)"
  if has frontend || has frontend-mobile; then echo "     - frontend-design skill"; fi
  echo "  4. Fill [BRACKETS] placeholders in openspec/project.md, openspec/specs/*, and per-stack CLAUDE.md/AGENTS.md"
  echo "  5. Edit openspec/verify.config.yaml — set each stack build/test commands for /opsx:verify (L1 build / L3 test)"
  echo "  6. Run the loop-eng audit (32 checks) to verify maturity"
}

# ---------------- subcommand: check (自检 + LoopEng audit) ----------------
cmd_check() {
  [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { echo "Usage: scaffold.sh check [project-dir]  # self-check + LoopEng audit"; exit 0; }
  local dir="${1:-}"
  local pass=0 partial=0 fail=0 total=0
  report() {
    local s="$1" label="$2"
    total=$((total+1))
    case "$s" in
      PASS)    pass=$((pass+1));    printf "  [ PASS ]    %s\n" "$label";;
      PARTIAL) partial=$((partial+1)); printf "  [PARTIAL]   %s\n" "$label";;
      *)       fail=$((fail+1));    printf "  [ FAIL ]    %s\n" "$label";;
    esac
  }
  json_ok() { python3 -c 'import json,sys;json.load(open(sys.argv[1]))' "$1" >/dev/null 2>&1; }

  echo "==> loop-eng self-check"
  echo "  script: $0"
  echo "  bash:   ${BASH_VERSION:-unknown}"
  if bash -n "$0" 2>/dev/null; then report PASS "script syntax (bash -n)"; else report FAIL "script syntax (bash -n)"; fi
  if command -v openspec >/dev/null 2>&1; then
    report PASS "openspec CLI: $(openspec --version 2>/dev/null || echo present)"
  else
    report FAIL "openspec CLI (install: npm i -g @fission-ai/openspec@latest)"
  fi
  if command -v node >/dev/null 2>&1; then report PASS "node: $(node --version 2>/dev/null)"; else report FAIL "node (required by openspec)"; fi

  if [[ -z "$dir" ]]; then
    echo ""
    echo "==> No project directory specified — self-check only."
    echo "    Audit a project with: scaffold.sh check <project-dir>"
    _score "$pass" "$partial" "$fail" "$total"
    exit 0
  fi
  [[ -d "$dir" ]] || { echo "Error: not a directory: $dir" >&2; exit 1; }

  echo ""
  echo "==> LoopEng compliance audit: $dir"
  cd "$dir"

  # E2 / O1 / O3 / O4 / O5 / O6
  if [[ -d openspec && -d openspec/specs && -d openspec/changes ]]; then report PASS "E2 openspec/ (specs/ + changes/)"; else report FAIL "E2 openspec/ structure (run: openspec init / scaffold.sh)"; fi
  local specs=0
  [[ -f openspec/specs/api/spec.md ]] && specs=$((specs+1))
  [[ -f openspec/specs/data/spec.md ]] && specs=$((specs+1))
  [[ -f openspec/specs/errors/spec.md ]] && specs=$((specs+1))
  case $specs in 3) report PASS "O1 specs api/data/errors";; 1|2) report PARTIAL "O1 specs ($specs/3: api/data/errors)";; *) report FAIL "O1 specs api/data/errors";; esac
 if [[ -f openspec/changes/_template/proposal.md && -f openspec/changes/_template/spec.md ]]; then report PASS "O3 changes/_template (proposal+spec)"; else report FAIL "O3 changes/_template"; fi
  # O4 — canonical archive is openspec/archive/; archives misplaced in
  # openspec/changes/archive/ is common drift - a dir-existence-only check hides it.
  local _o4real=0 _o4mis=0 _o4e
  if [[ -d openspec/archive ]]; then
    for _o4e in openspec/archive/*; do
      [[ -e "$_o4e" ]] || continue
      case "$(basename "$_o4e")" in .gitkeep|README.md|.DS_Store) continue;; esac
      _o4real=$((_o4real+1))
    done
  fi
  if [[ -d openspec/changes/archive ]]; then
    for _o4e in openspec/changes/archive/*; do
      [[ -e "$_o4e" ]] || continue
      case "$(basename "$_o4e")" in .gitkeep|README.md|.DS_Store) continue;; esac
      _o4mis=$((_o4mis+1))
    done
  fi
  if (( _o4mis > 0 )); then
    report PARTIAL "O4 archive/ ($_o4mis misplaced in changes/archive/ - move to openspec/archive/)"
  elif [[ -d openspec/archive ]]; then
    report PASS "O4 archive/ ($_o4real archived)"
  else
    report FAIL "O4 archive/ (run: openspec init / scaffold.sh)"
  fi
 [[ -f openspec/project.md ]] && report PASS "O5 openspec/project.md" || report FAIL "O5 openspec/project.md"
  [[ -f openspec/README.md ]] && report PASS "O6 openspec/README.md" || report FAIL "O6 openspec/README.md"

  # O8 WHEN/THEN
  if grep -rq 'WHEN' openspec/changes openspec/specs 2>/dev/null; then report PASS "O8 WHEN/THEN scenarios present"; else report PARTIAL "O8 no WHEN/THEN found (add to specs/changes)"; fi

  # O7 — auto-loaded files English-only (CJK ratio; Chinese wastes tokens every session)
  if ! command -v python3 >/dev/null 2>&1; then
    report PARTIAL "O7 auto-loaded English (no python3 to scan CJK)"
  else
    local _af _cjk_over=0 _cjk_total=0 _worst="" _wpct=0 _f _pct
    _af="$(autoloaded_md)"
    if [[ -z "$_af" ]]; then
      report PARTIAL "O7 auto-loaded English (no auto-loaded .md found)"
    else
      while IFS= read -r _f; do
        [[ -f "$_f" ]] || continue
        _cjk_total=$((_cjk_total+1))
        _pct="$(python3 - "$_f" <<'PY'
import sys,re
t=open(sys.argv[1],encoding='utf-8',errors='replace').read()
cjk=len(re.findall(r'[\u3000-\u303f\u4e00-\u9fff\uff00-\uffef]',t))
tot=len(t)
print('0' if tot==0 else str(round(100*cjk/tot,1)))
PY
)"
        if awk -v p="$_pct" -v t="$CJK_THRESHOLD" 'BEGIN{exit !(p>t)}'; then
          _cjk_over=$((_cjk_over+1))
          if awk -v p="$_pct" -v w="$_wpct" 'BEGIN{exit !(p>w)}'; then _wpct="$_pct"; _worst="$_f"; fi
        fi
      done <<< "$_af"
      if [[ $_cjk_over -eq 0 ]]; then
        report PASS "O7 auto-loaded files English-only (0/$_cjk_total over ${CJK_THRESHOLD}% CJK)"
      else
        report PARTIAL "O7 auto-loaded files have Chinese ($_cjk_over/$_cjk_total over ${CJK_THRESHOLD}% CJK; worst: $_worst ${_wpct}%)"
      fi
    fi
  fi

  # E3 / S6 / S4 / S8 / S5
  [[ -d .claude/commands/opsx ]] && report PASS "E3 .claude/commands/opsx/ (slash commands)" || report FAIL "E3 .claude/commands/opsx/ (run: openspec init)"
  [[ -f .claude/commands/opsx/verify.md ]] && report PASS "E3+ /opsx:verify command (loop-eng enhancement)" || report PARTIAL "E3+ /opsx:verify missing (re-run scaffold.sh to embed)"
  if [[ -f .claude/settings.json ]]; then
    if ! command -v python3 >/dev/null 2>&1; then report PARTIAL "S6 settings.json (no python3 to validate JSON)"
    elif json_ok .claude/settings.json; then report PASS "S6 .claude/settings.json (valid JSON)"; else report FAIL "S6 .claude/settings.json (invalid JSON)"; fi
  else report FAIL "S6 .claude/settings.json (missing)"; fi
  local rules=0 sp=0
  while IFS= read -r _; do rules=$((rules+1)); done < <(find .claude/rules -name '*.md' 2>/dev/null)
  [[ $rules -gt 0 ]] && report PASS "S4 .claude/rules/ ($rules rule(s))" || report PARTIAL "S4 .claude/rules/ (empty)"
 if [[ -f .claude/agents/reviewer.md && -f .claude/agents/coordinator.md ]]; then report PASS "S8 agents reviewer+coordinator"; else report PARTIAL "S8 agents (reviewer/coordinator)"; fi
  # S5 — domain skills. Detect the Superpowers discipline set by skill name so a
  # project that has it installed scores PASS; without it, prompt to install.
  local _s5_total=0 _s5_super=0 _s5d _s5n
  while IFS= read -r _s5d; do
    _s5_total=$((_s5_total+1))
    _s5n="$(basename "$_s5d")"
    case "$_s5n" in
      brainstorming|writing-plans|executing-plans|requesting-code-review|receiving-code-review|verification-before-completion|using-superpowers|test-driven-development|systematic-debugging|subagent-driven-development|dispatching-parallel-agents|using-git-worktrees|finishing-a-development-branch|writing-skills) _s5_super=$((_s5_super+1));;
    esac
  done < <(find .claude/skills -mindepth 1 -maxdepth 1 -type d ! -name 'openspec-*' 2>/dev/null)
  if [[ $_s5_super -gt 0 ]]; then report PASS "S5 domain skills ($_s5_total; Superpowers: $_s5_super)";
  elif [[ $_s5_total -gt 0 ]]; then report PARTIAL "S5 domain skills ($_s5_total; no Superpowers set - install brainstorming/writing-plans/executing-plans/requesting-code-review/verification-before-completion)";
  else report PARTIAL "S5 no domain skills installed"; fi

  # H1 / H5 / H2 / H9
  local ag=0
  while IFS= read -r _; do ag=$((ag+1)); done < <(find . -mindepth 2 -maxdepth 2 -name CLAUDE.md -not -path './.claude/*' 2>/dev/null)
  [[ $ag -gt 0 ]] && report PASS "H1 per-stack Agent CLAUDE.md ($ag)" || report PARTIAL "H1 no per-stack Agent CLAUDE.md"
  [[ -f AGENTS.md ]] && report PASS "AGENTS.md Codex harness entry present" || report PARTIAL "AGENTS.md (Codex entry) — add for Codex support"
  if [[ -f CLAUDE.md ]]; then
    local lc; lc=$(wc -l < CLAUDE.md | tr -d ' ')
    if [[ $lc -le 120 ]]; then report PASS "H5 root CLAUDE.md nav hub ($lc lines)"; else report PARTIAL "H5 root CLAUDE.md ($lc lines > 120; trim to nav hub)"; fi
  else report FAIL "H5 root CLAUDE.md (missing)"; fi
  if grep -rq 'openspec/specs' . --include='*.md' 2>/dev/null; then report PASS "H2 agents reference openspec/specs"; else report PARTIAL "H2 no openspec/specs references found"; fi
  if [[ -f .claude/settings.json ]] && grep -q 'rm -rf' .claude/settings.json 2>/dev/null && grep -q 'push --force' .claude/settings.json 2>/dev/null; then report PASS "H9 dangerous commands denied"; else report PARTIAL "H9 dangerous-command deny list"; fi

  echo ""
  _score "$pass" "$partial" "$fail" "$total"
  echo "    Tip: ask the loop-eng skill for a full 32-check audit + remediation plan."
}

_score() {
  local p="$1" pa="$2" f="$3" t="$4" pct=0 level="Pre-build"
  [[ $t -gt 0 ]] && pct=$(( (p*100) / t ))
  if   [[ $pct -ge 90 ]]; then level="Industrial"
  elif [[ $pct -ge 66 ]]; then level="Quality"
  elif [[ $pct -ge 33 ]]; then level="Basic"; fi
  echo "==> Result: $p/$t passed ($pct%) · $pa partial · $f failed"
  echo "    Maturity level: $level"
}

# ---------------- subcommand: list (preview manifest) ----------------
cmd_tokens() {
  [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { echo "Usage: scaffold.sh tokens [project-dir]  # token audit of auto-loaded files"; exit 0; }
  local dir="${1:-.}"
  [[ -d "$dir" ]] || { echo "Error: not a directory: $dir" >&2; exit 1; }
  command -v python3 >/dev/null 2>&1 || { echo "Error: python3 required for token audit" >&2; exit 1; }
  echo "==> Token audit: $dir (auto-loaded files only)"
  cd "$dir"
  local _af; _af="$(autoloaded_md)"
  [[ -z "$_af" ]] && { echo "  (no auto-loaded .md found)"; exit 0; }
  local _engine="heuristic"
  python3 -c 'import tiktoken' 2>/dev/null && _engine="tiktoken cl100k_base"
  echo "  engine: $_engine   (pip install tiktoken for exact counts)"
  echo ""
  printf "  %-42s %8s %7s  %s\n" "file" "tokens" "CJK%" "note"
  local _total=0 _f _tok _pct _note
  while IFS= read -r _f; do
    [[ -f "$_f" ]] || continue
    read -r _tok _pct < <(python3 - "$_f" "$_engine" <<'PY'
import sys,re
t=open(sys.argv[1],encoding='utf-8',errors='replace').read()
cjk=len(re.findall(r'[\u3000-\u303f\u4e00-\u9fff\uff00-\uffef]',t))
tot=len(t)
pct=0 if tot==0 else round(100*cjk/tot,1)
if 'tiktoken' in sys.argv[2]:
    import tiktoken
    n=len(tiktoken.get_encoding('cl100k_base').encode(t))
else:
    n=cjk + (tot-cjk)//4
print(n, pct)
PY
)
    _total=$((_total+_tok))
    _note=""
    awk -v p="$_pct" -v t="$CJK_THRESHOLD" 'BEGIN{exit !(p>t)}' && _note="!! Chinese"
    printf "  %-42s %8s %6s%%  %s\n" "$_f" "$_tok" "$_pct" "$_note"
  done <<< "$_af"
  echo ""
  echo "  TOTAL auto-loaded: $_total tokens/session"
  echo "  Files marked '!! Chinese' (CJK>${CJK_THRESHOLD}%) are O7 overhead — translate to English to recover."
  echo "  Re-run after translating to confirm the drop."
}

cmd_list() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --stacks)        STACKS="$2"; shift 2;;
      --backend-dir)   BACKEND_DIR="$2"; shift 2;;
      --frontend-dir)  FRONTEND_DIR="$2"; shift 2;;
      --mobile-dir)    MOBILE_DIR="$2"; shift 2;;
      -h|--help)       echo "Usage: scaffold.sh list [--stacks <list>] [--backend-dir <n>] [--frontend-dir <n>] [--mobile-dir <n>]"; exit 0;;
      *) echo "list: unknown arg: $1" >&2; exit 1;;
    esac
  done
  local tmp; tmp="$(mktemp -d)"
  PROJECT_NAME="preview"
  TARGET_DIR="$tmp"
  RUN_INIT=0
  generate_scaffold >/dev/null 2>&1
  echo "==> Preview: files scaffold.sh would generate"
  echo "    stacks: $STACKS"
  echo "    (written to a temp dir, then discarded)"
  echo "    note: openspec init additionally creates .claude/commands/opsx/ + openspec-* skills"
  echo ""
  ( cd "$tmp" && find . -type f | sed 's|^\./||' | sort )
  echo ""
  echo "Count: $(cd "$tmp" && find . -type f | wc -l | tr -d ' ') files"
  rm -rf "$tmp"
}

# ---------------- dispatch ----------------
_subcmd="scaffold"
case "${1:-}" in
  list|--list)                           _subcmd="list";  shift;;
  check|--check|self-check|--self-check) _subcmd="check"; shift;;
  tokens|--tokens)                       _subcmd="tokens"; shift;;
esac
case "$_subcmd" in
  list)  cmd_list  "$@"; exit 0;;
  check) cmd_check "$@"; exit 0;;
  tokens) cmd_tokens "$@"; exit 0;;
esac

# ---------------- default: scaffold ----------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --stacks)        STACKS="$2"; shift 2;;
    --dir)           TARGET_DIR="$2"; shift 2;;
    --backend-dir)   BACKEND_DIR="$2"; shift 2;;
    --frontend-dir)  FRONTEND_DIR="$2"; shift 2;;
    --mobile-dir)    MOBILE_DIR="$2"; shift 2;;
    --tools)         TOOLS="$2"; shift 2;;
    --no-init)       RUN_INIT=0; shift;;
    -h|--help)       usage; exit 0;;
    *)
      if [[ -z "$PROJECT_NAME" ]]; then PROJECT_NAME="$1"
      else echo "Unknown arg: $1" >&2; usage; exit 1; fi
      shift;;
  esac
done

[[ -z "$PROJECT_NAME" ]] && { echo "Error: project name required" >&2; usage; exit 1; }
[[ -z "$TARGET_DIR" ]] && TARGET_DIR="./$PROJECT_NAME"
generate_scaffold
