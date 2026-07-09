#!/usr/bin/env bash
# build.sh - Inline shared subcommands into scaffold.sh variants
#
# Both CC and Codex scaffold.sh share ~400 lines of identical subcommand code
# (cmd_tokens through end of file). This code lives in lib/loopforge-subcommands.sh
# as the single source of truth. This script inlines it into both scaffold.sh files.
#
# The split point is "cmd_tokens()": everything before it is platform-specific
# (template); everything from cmd_tokens() onward is shared (lib).
#
# Usage:
#   bash build.sh           # regenerate both scaffold.sh files from template + lib
#   bash build.sh --check   # CI mode: verify committed files match build output
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB="$SCRIPT_DIR/lib/loopforge-subcommands.sh"
CHECK_MODE=0
[[ "${1:-}" == "--check" ]] && CHECK_MODE=1

[[ -f "$LIB" ]] || { echo "Error: $LIB not found" >&2; exit 1; }

# Read shared library content (ensure trailing newline)
LIB_CONTENT=$(cat "$LIB")
[[ "$LIB_CONTENT" != *$'\n' ]] && LIB_CONTENT+=$'\n'

build_variant() {
  local scaffold="$1" name="$2"
  
  [[ -f "$scaffold" ]] || { echo "Error: not found: $scaffold" >&2; exit 1; }
  
  # Extract template part: everything before "cmd_tokens()"
  # (If cmd_tokens is not found, the whole file is the template)
  local template
  template=$(sed '/^cmd_tokens()/,$d' "$scaffold")
  
  # Ensure template ends with newline
  [[ "$template" != *$'\n' ]] && template+=$'\n'
  
  # Add blank line separator if template doesn't end with one
  [[ "$template" != *$'\n\n' ]] && template+=$'\n'
  
  # Assemble: template + lib
  local result="${template}${LIB_CONTENT}"
  
  if [[ $CHECK_MODE -eq 1 ]]; then
    if diff -q <(printf '%s' "$result") "$scaffold" >/dev/null 2>&1; then
      echo "  OK $name: up to date"
      return 0
    else
      echo "  STALE $name: run: bash build.sh"
      return 1
    fi
  else
    printf '%s' "$result" > "$scaffold"
    bash -n "$scaffold" 2>&1 && echo "  OK $name: generated + syntax valid" || { echo "  FAIL $name: syntax error" >&2; exit 1; }
  fi
}

echo "LoopForge build: inlining shared subcommands"

if [[ $CHECK_MODE -eq 1 ]]; then
  echo "Check mode: verifying committed files match build output"
  rc=0
  build_variant "$SCRIPT_DIR/skills/loopforge-cc/scaffold.sh" "CC" || rc=1
  build_variant "$SCRIPT_DIR/skills/loopforge-codex/scaffold.sh" "Codex" || rc=1
  [[ $rc -eq 0 ]] && echo "All up to date" || { echo "Some files are stale - run: bash build.sh"; exit 1; }
else
  echo "Build mode: regenerating scaffold.sh files"
  build_variant "$SCRIPT_DIR/skills/loopforge-cc/scaffold.sh" "CC"
  build_variant "$SCRIPT_DIR/skills/loopforge-codex/scaffold.sh" "Codex"
  echo ""
  echo "Done. Both scaffold.sh files are standalone (no runtime deps)."
  echo "Run: bash tests/run-tests.sh  to verify"
fi
