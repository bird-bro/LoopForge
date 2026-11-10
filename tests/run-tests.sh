#!/usr/bin/env bash
# run-tests.sh - LoopForge test suite
# Tests both CC and Codex scaffold.sh versions.
# Usage: bash tests/run-tests.sh [--keep]  # --keep keeps test dirs for inspection
set -uo pipefail   # no -e: we handle errors per-test

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KEEP=0
[[ "${1:-}" == "--keep" ]] && KEEP=1

source "$SCRIPT_DIR/test-helpers.sh"

CC_SCAFFOLD="$REPO_DIR/skills/loopforge-cc/scaffold.sh"
CX_SCAFFOLD="$REPO_DIR/skills/loopforge-codex/scaffold.sh"
TMPBASE=$(mktemp -d)
trap '[[ $KEEP -eq 0 ]] && rm -rf "$TMPBASE"' EXIT

echo "LoopForge Test Suite"
echo "Temp dir: $TMPBASE"
echo "Repo:     $REPO_DIR"

# ================================================================
# 1. SYNTAX CHECKS
# ================================================================
test_group "1. Syntax checks"

_CURRENT_TEST="CC scaffold.sh syntax"
bash -n "$CC_SCAFFOLD" 2>&1; assert_exit_code 0 $? "$_CURRENT_TEST"

_CURRENT_TEST="Codex scaffold.sh syntax"
bash -n "$CX_SCAFFOLD" 2>&1; assert_exit_code 0 $? "$_CURRENT_TEST"

# ================================================================
# 2. SCAFFOLD GENERATION
# ================================================================
test_group "2. Scaffold generation"

CC_PROJ="$TMPBASE/cc-proj"
CX_PROJ="$TMPBASE/cx-proj"

_CURRENT_TEST="CC scaffold generates project"
"$CC_SCAFFOLD" cc-proj --dir "$CC_PROJ" --no-init >/dev/null 2>&1; assert_exit_code 0 $? "$_CURRENT_TEST"

_CURRENT_TEST="Codex scaffold generates project"
"$CX_SCAFFOLD" cx-proj --dir "$CX_PROJ" --no-init >/dev/null 2>&1; assert_exit_code 0 $? "$_CURRENT_TEST"

# Key files exist
for f in openspec/guard.sh openspec/ensure-contract-fresh.sh openspec/build-contract.sh \
         openspec/check-conflicts.sh \
         openspec/loop-state.yaml openspec/validate-artifacts.py openspec/verify.config.yaml \
         openspec/changes/_template/proposal.md openspec/changes/_template/specs/capability/spec.md \
         openspec/changes/_template/execution-contract.md \
         openspec/changes/_template/loop-state.yaml; do
  _CURRENT_TEST="CC: $f exists"
  assert_file_exists "$CC_PROJ/$f" "$_CURRENT_TEST"
  _CURRENT_TEST="Codex: $f exists"
  assert_file_exists "$CX_PROJ/$f" "$_CURRENT_TEST"
done

# Generated scripts are executable
for f in openspec/guard.sh openspec/ensure-contract-fresh.sh openspec/build-contract.sh openspec/check-conflicts.sh; do
  _CURRENT_TEST="CC: $f is executable"
  assert_executable "$CC_PROJ/$f" "$_CURRENT_TEST"
  _CURRENT_TEST="Codex: $f is executable"
  assert_executable "$CX_PROJ/$f" "$_CURRENT_TEST"
done

# Generated scripts have valid syntax
for script in guard.sh build-contract.sh ensure-contract-fresh.sh check-conflicts.sh; do
  _CURRENT_TEST="CC: $script syntax"
  bash -n "$CC_PROJ/openspec/$script" 2>&1; assert_exit_code 0 $? "$_CURRENT_TEST"
  _CURRENT_TEST="Codex: $script syntax"
  bash -n "$CX_PROJ/openspec/$script" 2>&1; assert_exit_code 0 $? "$_CURRENT_TEST"
done

# ================================================================
# 3. VERSION SUBCOMMAND
# ================================================================
test_group "3. version subcommand"

_CURRENT_TEST="CC version outputs LoopForge"
out=$("$CC_SCAFFOLD" version 2>&1); rc=$?
assert_contains "$out" "LoopForge" "$_CURRENT_TEST"
assert_exit_code 0 $rc "CC version exit code"

_CURRENT_TEST="Codex version outputs LoopForge"
out=$("$CX_SCAFFOLD" version 2>&1); rc=$?
assert_contains "$out" "LoopForge" "$_CURRENT_TEST"
assert_exit_code 0 $rc "Codex version exit code"

# ================================================================
# 4. LIST SUBCOMMAND
# ================================================================
test_group "4. list subcommand"

_CURRENT_TEST="CC list shows build-contract.sh"
out=$("$CC_SCAFFOLD" list 2>&1); rc=$?
assert_contains "$out" "build-contract.sh" "$_CURRENT_TEST"

_CURRENT_TEST="Codex list shows build-contract.sh"
out=$("$CX_SCAFFOLD" list 2>&1); rc=$?
assert_contains "$out" "build-contract.sh" "$_CURRENT_TEST"

# ================================================================
# 5. DOCTOR SUBCOMMAND
# ================================================================
test_group "5. doctor subcommand"

_CURRENT_TEST="CC doctor checks build-contract.sh"
out=$("$CC_SCAFFOLD" doctor "$CC_PROJ" 2>&1); rc=$?
assert_contains "$out" "build-contract.sh" "$_CURRENT_TEST"
assert_contains "$out" "Healthy" "CC doctor reports healthy"

_CURRENT_TEST="Codex doctor checks build-contract.sh"
out=$("$CX_SCAFFOLD" doctor "$CX_PROJ" 2>&1); rc=$?
assert_contains "$out" "build-contract.sh" "$_CURRENT_TEST"
assert_contains "$out" "Healthy" "Codex doctor reports healthy"

# ================================================================
# 6. CHECK SUBCOMMAND
# ================================================================
test_group "6. check subcommand"

_CURRENT_TEST="CC check runs on generated project"
out=$("$CC_SCAFFOLD" check "$CC_PROJ" 2>&1); rc=$?
assert_contains "$out" "Result:" "$_CURRENT_TEST"

_CURRENT_TEST="Codex check runs on generated project"
out=$("$CX_SCAFFOLD" check "$CX_PROJ" 2>&1); rc=$?
assert_contains "$out" "Result:" "$_CURRENT_TEST"

# ================================================================
# 7. CONTRACT SUBCOMMAND
# ================================================================
test_group "7. contract subcommand"

# Setup: create planning artifacts
setup_change() {
  local proj="$1" change="$2"
  local cdir="$proj/openspec/changes/$change"
  mkdir -p "$cdir"
  cat > "$cdir/proposal.md" << 'PEOF'
# Proposal: Test Change
## Why
Test reason for validation.
## What
Test change summary.
## Scope
- In scope: feature A
- Out of scope: feature B
## Constraints
- Must be fast
PEOF
  cat > "$cdir/spec.md" << 'SEOF'
## Verification Scenarios
### WHEN valid input
THEN returns success
### WHEN invalid input
THEN returns error
SEOF
  cat > "$cdir/design.md" << 'DEOF'
## Decisions
- Use pattern X
- Cache with Redis
DEOF
  cat > "$cdir/tasks.md" << 'TEOF'
- [ ] T1: Implement core
- [ ] T2: Add tests
- [ ] T3: Documentation
TEOF
}

setup_change "$CC_PROJ" "test-change"
setup_change "$CX_PROJ" "test-change"

_CURRENT_TEST="CC contract generates execution-contract.md"
out=$("$CC_SCAFFOLD" contract "$CC_PROJ/openspec/changes/test-change" 2>&1); rc=$?
assert_contains "$out" "Generated" "$_CURRENT_TEST"
assert_file_exists "$CC_PROJ/openspec/changes/test-change/execution-contract.md" "CC contract file created"

_CURRENT_TEST="Codex contract generates execution-contract.md"
out=$("$CX_SCAFFOLD" contract "$CX_PROJ/openspec/changes/test-change" 2>&1); rc=$?
assert_contains "$out" "Generated" "$_CURRENT_TEST"
assert_file_exists "$CX_PROJ/openspec/changes/test-change/execution-contract.md" "Codex contract file created"

# Verify contract content
_CURRENT_TEST="CC contract contains Intent Lock"
contract_content=$(cat "$CC_PROJ/openspec/changes/test-change/execution-contract.md")
assert_contains "$contract_content" "Intent Lock" "$_CURRENT_TEST"
assert_contains "$contract_content" "Test Change" "CC contract has change name"
assert_contains "$contract_content" "WHEN valid input" "CC contract has approved behavior"
assert_contains "$contract_content" "Use pattern X" "CC contract has design decisions"

# Test --force
_CURRENT_TEST="CC contract --force overwrites"
out=$("$CC_SCAFFOLD" contract --force "$CC_PROJ/openspec/changes/test-change" 2>&1); rc=$?
assert_contains "$out" "Generated" "$_CURRENT_TEST"

# Test refuse without --force
_CURRENT_TEST="CC contract refuses without --force"
out=$(bash "$CC_PROJ/openspec/build-contract.sh" "$CC_PROJ/openspec/changes/test-change" 2>&1); rc=$?
assert_contains "$out" "already exists" "$_CURRENT_TEST"
assert_exit_code 1 $rc "CC contract refuse exit code"

# ================================================================
# 8. ENSURE-CONTRACT-FRESH
# ================================================================
test_group "8. ensure-contract-fresh.sh"

_CURRENT_TEST="CC ensure-contract-fresh --update"
out=$(bash "$CC_PROJ/openspec/ensure-contract-fresh.sh" --update "$CC_PROJ/openspec/changes/test-change" 2>&1); rc=$?
assert_contains "$out" "Updated artifacts_hash" "$_CURRENT_TEST"
assert_exit_code 0 $rc "CC update exit code"

_CURRENT_TEST="CC --update creates per-change state file"
assert_file_exists "$CC_PROJ/openspec/changes/test-change/loop-state.yaml" "$_CURRENT_TEST"

_CURRENT_TEST="CC global loop-state.yaml stays untouched by per-change update"
grep -q '^artifacts_hash: null' "$CC_PROJ/openspec/loop-state.yaml"; rc=$?
assert_exit_code 0 $rc "$_CURRENT_TEST"

_CURRENT_TEST="Codex --update creates per-change state file"
bash "$CX_PROJ/openspec/ensure-contract-fresh.sh" --update "$CX_PROJ/openspec/changes/test-change" >/dev/null 2>&1
assert_file_exists "$CX_PROJ/openspec/changes/test-change/loop-state.yaml" "$_CURRENT_TEST"

_CURRENT_TEST="CC ensure-contract-fresh check (fresh)"
bash "$CC_PROJ/openspec/ensure-contract-fresh.sh" "$CC_PROJ/openspec/changes/test-change" 2>&1; rc=$?
assert_exit_code 0 $rc "$_CURRENT_TEST"

_CURRENT_TEST="CC ensure-contract-fresh check (stale after artifact change)"
echo "## New Section" >> "$CC_PROJ/openspec/changes/test-change/proposal.md"
out=$(bash "$CC_PROJ/openspec/ensure-contract-fresh.sh" "$CC_PROJ/openspec/changes/test-change" 2>&1); rc=$?
assert_contains "$out" "STALE" "$_CURRENT_TEST"
assert_exit_code 1 $rc "CC stale exit code"

# ================================================================
# 9. RESTRUCTURE SUBCOMMAND
# ================================================================
test_group "9. restructure subcommand"

# Create monolithic CLAUDE.md for CC test
cat > "$CC_PROJ/CLAUDE.md" << 'REOF'
# Test App
## Business Context
E-commerce platform.
## Build Commands
Backend: `mvn clean install`
Frontend: `pnpm install && pnpm build`
## Backend Patterns
Java 17 + Spring Boot 3
## Frontend Patterns
Vue 3 + Element Plus
## API Paths
GET /api/v1/products
## Coding Standards
Error response format
## Error Codes
0|200|Success
REOF

_CURRENT_TEST="CC restructure detects backend stack"
out=$("$CC_SCAFFOLD" restructure "$CC_PROJ" 2>&1); rc=$?
assert_contains "$out" "backend" "$_CURRENT_TEST"
assert_contains "$out" "frontend" "CC restructure detects frontend stack"
assert_contains "$out" "specs/api/spec.md" "CC restructure classifies API Paths"
assert_contains "$out" "specs/errors/spec.md" "CC restructure classifies Error Codes"
assert_contains "$out" "split by tool" "CC restructure classifies Build Commands as split"

# Codex version: restructure reads CLAUDE.md first, then AGENTS.md
cat > "$CX_PROJ/CLAUDE.md" << 'REOF'
# Test App
## Business Context
E-commerce.
## Build Commands
gradle build
## API Paths
GET /api/v1/users
REOF

_CURRENT_TEST="Codex restructure detects backend"
out=$("$CX_SCAFFOLD" restructure "$CX_PROJ" 2>&1); rc=$?
assert_contains "$out" "backend" "$_CURRENT_TEST"
assert_contains "$out" "specs/api/spec.md" "Codex restructure classifies API Paths"

# ================================================================
# 10. CHANGES SUBCOMMAND
# ================================================================
test_group "10. changes subcommand"

_CURRENT_TEST="CC changes lists test-change"
out=$("$CC_SCAFFOLD" changes "$CC_PROJ" 2>&1); rc=$?
assert_contains "$out" "test-change" "$_CURRENT_TEST"

_CURRENT_TEST="Codex changes lists test-change"
out=$("$CX_SCAFFOLD" changes "$CX_PROJ" 2>&1); rc=$?
assert_contains "$out" "test-change" "$_CURRENT_TEST"

# ================================================================
# 10b. GUARD WITH PER-CHANGE STATE
# ================================================================
test_group "10b. guard with per-change state"

# Restore freshness after the stale-check mutation in section 8
bash "$CC_PROJ/openspec/ensure-contract-fresh.sh" --update "$CC_PROJ/openspec/changes/test-change" >/dev/null 2>&1

# Simulate completed tasks in the per-change state
sed -i '' -e 's/^tasks_done: .*/tasks_done: 3/' -e 's/^tasks_total: .*/tasks_total: 3/' \
  "$CC_PROJ/openspec/changes/test-change/loop-state.yaml" 2>/dev/null \
  || sed -i -e 's/^tasks_done: .*/tasks_done: 3/' -e 's/^tasks_total: .*/tasks_total: 3/' \
  "$CC_PROJ/openspec/changes/test-change/loop-state.yaml"

_CURRENT_TEST="CC guard passes with per-change state"
bash "$CC_PROJ/openspec/guard.sh" applying verifying "$CC_PROJ/openspec/changes/test-change" 2>&1; rc=$?
assert_exit_code 0 $rc "$_CURRENT_TEST"

# Incomplete tasks -> blocked
sed -i '' -e 's/^tasks_done: .*/tasks_done: 2/' \
  "$CC_PROJ/openspec/changes/test-change/loop-state.yaml" 2>/dev/null \
  || sed -i -e 's/^tasks_done: .*/tasks_done: 2/' \
  "$CC_PROJ/openspec/changes/test-change/loop-state.yaml"
_CURRENT_TEST="CC guard blocks incomplete tasks (per-change state)"
out=$(bash "$CC_PROJ/openspec/guard.sh" applying verifying "$CC_PROJ/openspec/changes/test-change" 2>&1); rc=$?
assert_contains "$out" "incomplete" "$_CURRENT_TEST"
assert_exit_code 1 $rc "$_CURRENT_TEST"

# ================================================================
# 10c. CONFLICTS SUBCOMMAND (parallel file-ownership check)
# ================================================================
test_group "10c. conflicts subcommand"

mkdir -p "$CC_PROJ/openspec/changes/feat-a" "$CC_PROJ/openspec/changes/feat-b"
cat > "$CC_PROJ/openspec/changes/feat-a/files.yaml" <<'FEOF'
- ops_sev/src/main/java/com/x/OrderService.java
- ops_sev/src/main/java/com/x/OrderMapper.xml
FEOF
cat > "$CC_PROJ/openspec/changes/feat-b/files.yaml" <<'FEOF'
- ops_sev/src/main/java/com/x/OrderService.java
- ops_web/src/api/order.ts
FEOF

_CURRENT_TEST="CC conflicts detects overlap"
out=$("$CC_SCAFFOLD" conflicts "$CC_PROJ" 2>&1); rc=$?
assert_contains "$out" "CONFLICT" "$_CURRENT_TEST"
assert_contains "$out" "OrderService.java" "$_CURRENT_TEST"
assert_exit_code 1 $rc "$_CURRENT_TEST"

# Disjoint files -> parallel-safe
cat > "$CC_PROJ/openspec/changes/feat-b/files.yaml" <<'FEOF'
- ops_web/src/api/order.ts
- ops_web/src/views/OrderList.vue
FEOF

_CURRENT_TEST="CC conflicts passes when disjoint"
out=$("$CC_SCAFFOLD" conflicts "$CC_PROJ" 2>&1); rc=$?
assert_contains "$out" "parallel-safe" "$_CURRENT_TEST"
assert_exit_code 0 $rc "$_CURRENT_TEST"

# Codex variant: same behavior
mkdir -p "$CX_PROJ/openspec/changes/feat-a" "$CX_PROJ/openspec/changes/feat-b"
printf -- '- ops_sev/src/A.java
' > "$CX_PROJ/openspec/changes/feat-a/files.yaml"
printf -- '- ops_sev/src/A.java
- ops_web/src/B.vue
' > "$CX_PROJ/openspec/changes/feat-b/files.yaml"

_CURRENT_TEST="Codex conflicts detects overlap"
out=$("$CX_SCAFFOLD" conflicts "$CX_PROJ" 2>&1); rc=$?
assert_contains "$out" "CONFLICT" "$_CURRENT_TEST"
assert_exit_code 1 $rc "$_CURRENT_TEST"

# Doctor reports the new script
_CURRENT_TEST="CC doctor reports check-conflicts.sh"
out=$("$CC_SCAFFOLD" doctor "$CC_PROJ" 2>&1)
assert_contains "$out" "check-conflicts.sh" "$_CURRENT_TEST"

# ================================================================
# 11. EDGE CASES
# ================================================================
test_group "11. Edge cases"

_CURRENT_TEST="CC contract with missing dir"
out=$("$CC_SCAFFOLD" contract "/nonexistent/path" 2>&1); rc=$?
assert_exit_code 1 $rc "$_CURRENT_TEST"

_CURRENT_TEST="CC restructure with missing dir"
out=$("$CC_SCAFFOLD" restructure "/nonexistent/path" 2>&1); rc=$?
assert_exit_code 1 $rc "$_CURRENT_TEST"

_CURRENT_TEST="CC version with -V flag"
out=$("$CC_SCAFFOLD" -V 2>&1); rc=$?
assert_contains "$out" "LoopForge" "$_CURRENT_TEST"

_CURRENT_TEST="CC contract without args shows usage"
out=$("$CC_SCAFFOLD" contract 2>&1); rc=$?
assert_contains "$out" "Usage" "$_CURRENT_TEST"

# ================================================================
# 12. CROSS-VERSION CONSISTENCY
# ================================================================
test_group "12. Cross-version consistency"

_CURRENT_TEST="Both versions have same LOOPFORGE_VERSION"
cc_ver=$(grep '^LOOPFORGE_VERSION=' "$CC_SCAFFOLD" | head -1)
cx_ver=$(grep '^LOOPFORGE_VERSION=' "$CX_SCAFFOLD" | head -1)
assert_eq "$cc_ver" "$cx_ver" "$_CURRENT_TEST"

_CURRENT_TEST="Both contract templates have same sections"
cc_sections=$(grep '^## ' "$CC_PROJ/openspec/changes/_template/execution-contract.md" | sort)
cx_sections=$(grep '^## ' "$CX_PROJ/openspec/changes/_template/execution-contract.md" | sort)
assert_eq "$cc_sections" "$cx_sections" "$_CURRENT_TEST"

_CURRENT_TEST="Both guard.sh have same dispatch cases"
cc_cases=$(grep -c 'check_\|fail\|PASS\|abandoned' "$CC_PROJ/openspec/guard.sh")
cx_cases=$(grep -c 'check_\|fail\|PASS\|abandoned' "$CX_PROJ/openspec/guard.sh")
assert_eq "$cc_cases" "$cx_cases" "$_CURRENT_TEST"

# ================================================================
# SUMMARY
# ================================================================
print_summary
