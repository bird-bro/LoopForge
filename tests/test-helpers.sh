#!/usr/bin/env bash
# test-helpers.sh - Assert utilities for LoopForge test suite
# Sourced by run-tests.sh; not executed directly.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

_PASS=0
_FAIL=0
_SKIP=0
_CURRENT_TEST=""

# Run before each test group
test_group() {
  echo ""
  echo "=== $1 ==="
}

# Assert: two strings are equal
assert_eq() {
  local expected="$1" actual="$2" msg="${3:-$_CURRENT_TEST}"
  if [[ "$expected" == "$actual" ]]; then
    printf "  ${GREEN}✓${NC} %s\n" "$msg"
    _PASS=$((_PASS+1))
  else
    printf "  ${RED}✗${NC} %s\n" "$msg"
    printf "    expected: %s\n" "$expected"
    printf "    actual:   %s\n" "$actual"
    _FAIL=$((_FAIL+1))
  fi
}

# Assert: string contains substring
assert_contains() {
  local haystack="$1" needle="$2" msg="${3:-$_CURRENT_TEST}"
  if [[ "$haystack" == *"$needle"* ]]; then
    printf "  ${GREEN}✓${NC} %s\n" "$msg"
    _PASS=$((_PASS+1))
  else
    printf "  ${RED}✗${NC} %s\n" "$msg"
    printf "    expected to contain: %s\n" "$needle"
    printf "    got: %s\n" "${haystack:0:200}"
    _FAIL=$((_FAIL+1))
  fi
}

# Assert: exit code matches
assert_exit_code() {
  local expected_rc="$1" actual_rc="$2" msg="${3:-$_CURRENT_TEST}"
  if [[ "$expected_rc" == "$actual_rc" ]]; then
    printf "  ${GREEN}✓${NC} %s (rc=%s)\n" "$msg" "$actual_rc"
    _PASS=$((_PASS+1))
  else
    printf "  ${RED}✗${NC} %s (expected rc=%s, got rc=%s)\n" "$msg" "$expected_rc" "$actual_rc"
    _FAIL=$((_FAIL+1))
  fi
}

# Assert: file exists
assert_file_exists() {
  local file="$1" msg="${2:-$_CURRENT_TEST}"
  if [[ -f "$file" ]]; then
    printf "  ${GREEN}✓${NC} %s\n" "$msg"
    _PASS=$((_PASS+1))
  else
    printf "  ${RED}✗${NC} %s (missing: %s)\n" "$msg" "$file"
    _FAIL=$((_FAIL+1))
  fi
}

# Assert: file does NOT exist
assert_file_not_exists() {
  local file="$1" msg="${2:-$_CURRENT_TEST}"
  if [[ ! -f "$file" ]]; then
    printf "  ${GREEN}✓${NC} %s\n" "$msg"
    _PASS=$((_PASS+1))
  else
    printf "  ${RED}✗${NC} %s (should not exist: %s)\n" "$msg" "$file"
    _FAIL=$((_FAIL+1))
  fi
}

# Assert: file is executable
assert_executable() {
  local file="$1" msg="${2:-$_CURRENT_TEST}"
  if [[ -x "$file" ]]; then
    printf "  ${GREEN}✓${NC} %s\n" "$msg"
    _PASS=$((_PASS+1))
  else
    printf "  ${RED}✗${NC} %s (not executable: %s)\n" "$msg" "$file"
    _FAIL=$((_FAIL+1))
  fi
}

# Skip a test
skip_test() {
  local msg="${1:-$_CURRENT_TEST}"
  printf "  ${YELLOW}⊘${NC} %s (skipped)\n" "$msg"
  _SKIP=$((_SKIP+1))
}

# Print summary
print_summary() {
  echo ""
  echo "========================================"
  printf "  Results: ${GREEN}%d pass${NC}, ${RED}%d fail${NC}, ${YELLOW}%d skip${NC}\n" $_PASS $_FAIL $_SKIP
  echo "========================================"
  [[ $_FAIL -eq 0 ]]
}
