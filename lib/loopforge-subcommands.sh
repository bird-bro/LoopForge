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
    awk -v n="$_tok" -v th="${TOKEN_THRESHOLD}" 'BEGIN{exit !(n>th)}' && _note="${_note:+$_note }!! over budget"
    printf "  %-42s %8s %6s%%  %s\n" "$_f" "$_tok" "$_pct" "$_note"
  done <<< "$_af"
  echo ""
  echo "  TOTAL auto-loaded: $_total tokens/session"
  echo "  Files marked '!! Chinese' (CJK>${CJK_THRESHOLD}%) are O7 overhead — translate to English to recover."
  echo "  Files marked !! over budget exceed TOKEN_THRESHOLD=${TOKEN_THRESHOLD} tokens (S9 check)."
  echo "  Re-run after translating to confirm the drop."
}

cmd_list() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --stacks)        STACKS="$2"; shift 2;;
      --backend-dir)   BACKEND_DIR="$2"; shift 2;;
      --frontend-dir)  FRONTEND_DIR="$2"; shift 2;;
      --mobile-dir)    MOBILE_DIR="$2"; shift 2;;
      --dir|--tools|--no-init) shift 2 2>/dev/null || shift;;  # ignored (list uses temp dir)
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
  echo "    note: openspec init creates tool-specific files (.claude/commands/opsx/ for Claude; .codex/skills/ for Codex)"
  echo ""
  ( cd "$tmp" && find . -type f | sed 's|^\./||' | sort )
  echo ""
  echo "Count: $(cd "$tmp" && find . -type f | wc -l | tr -d ' ') files"
  rm -rf "$tmp"
}


cmd_validate() {
  [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { echo "Usage: scaffold.sh validate <change-dir>  # validate artifact structure (proposal/spec/design/tasks)"; exit 0; }
  local dir="${1:-}"
  [[ -n "$dir" ]] || { echo "Usage: scaffold.sh validate <change-dir>" >&2; exit 2; }
  [[ -d "$dir" ]] || { echo "Error: not a directory: $dir" >&2; exit 1; }
  command -v python3 >/dev/null 2>&1 || { echo "Error: python3 required" >&2; exit 1; }
  local script=""
  local abs_dir; abs_dir="$(cd "$dir" && pwd)"
  local cur="$abs_dir"
  while [[ "$cur" != "/" && -z "$script" ]]; do
    [[ -f "$cur/openspec/validate-artifacts.py" ]] && script="$cur/openspec/validate-artifacts.py"
    cur="$(dirname "$cur")"
  done
  [[ -z "$script" && -f "$abs_dir/../validate-artifacts.py" ]] && script="$abs_dir/../validate-artifacts.py"
  if [[ -z "$script" ]]; then
    echo "Error: validate-artifacts.py not found. Run scaffold.sh first to generate it." >&2
    exit 2
  fi
  echo "==> Validating: $dir"
  python3 "$script" "$dir"
}


cmd_changes() {
  [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { echo "Usage: scaffold.sh changes [project-dir]  # list all changes and their phase/status"; exit 0; }
  local proj="${1:-.}"
  local changes_dir="$proj/openspec/changes"
  [[ -d "$changes_dir" ]] || { echo "No openspec/changes/ found in $proj"; exit 0; }
  echo "Changes in: $proj"
  echo ""
  printf "  %-30s %-14s %-12s %-12s\n" "CHANGE" "PHASE" "TASKS" "UPDATED"
  printf "  %-30s %-14s %-12s %-12s\n" "------" "-----" "-----" "-------"
  local found=0
  for d in "$changes_dir"/*/; do
    [[ -d "$d" ]] || continue
    local name; name="$(basename "$d")"
    [[ "$name" == "_template" ]] && continue
    local state="$d/loop-state.yaml"
    [[ -f "$state" ]] || state="$proj/openspec/loop-state.yaml"
    local phase="?" tasks="?" updated="?"
    if [[ -f "$state" ]]; then
      phase=$(grep '^phase:' "$state" 2>/dev/null | awk '{print $2}' || echo "?")
      local done total
      done=$(grep '^tasks_done:' "$state" 2>/dev/null | awk '{print $2}' || echo "0")
      total=$(grep '^tasks_total:' "$state" 2>/dev/null | awk '{print $2}' || echo "0")
      tasks="${done:-0}/${total:-0}"
      updated=$(grep '^last_updated:' "$state" 2>/dev/null | awk '{print $2}' || echo "-")
    else
      if [[ -f "$d/execution-contract.md" ]]; then phase="applying?"
      elif [[ -f "$d/proposal.md" ]]; then phase="proposing"
      else phase="empty"; fi
    fi
    printf "  %-30s %-14s %-12s %-12s\n" "$name" "$phase" "$tasks" "$updated"
    found=1
  done
  [[ $found -eq 0 ]] && echo "  (no active changes)"
  echo ""
  echo "Phases: proposing -> applying -> verifying -> archived | abandoned"
}

cmd_doctor() {
  [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { echo "Usage: scaffold.sh doctor [project-dir]  # health check: deps, scaffold, guard, verify config"; exit 0; }
  local proj="${1:-.}"
  local pass=0 fail=0 warn=0
  _dr_ok()   { printf "  \xe2\x9c\x93 %s\n" "$1"; pass=$((pass+1)); }
  _dr_fail() { printf "  \xe2\x9c\x97 %s\n" "$1"; fail=$((fail+1)); }
  _dr_warn() { printf "  \xe2\x9a\xa0 %s\n" "$1"; warn=$((warn+1)); }
  echo "LoopForge Doctor - health check"
  echo "Project: $proj"
  echo ""
  echo "== Dependencies =="
  command -v node >/dev/null 2>&1 && _dr_ok "node $(node --version 2>/dev/null)" || _dr_fail "node not found (required by openspec)"
  command -v python3 >/dev/null 2>&1 && _dr_ok "python3 $(python3 --version 2>&1 | awk '{print $2}')" || _dr_warn "python3 not found (schema validation falls back to bash)"
  command -v git >/dev/null 2>&1 && _dr_ok "git $(git --version 2>/dev/null | awk '{print $3}')" || _dr_fail "git not found"
  command -v rg >/dev/null 2>&1 && _dr_ok "ripgrep (rg) available" || _dr_warn "ripgrep not found (verify L2 uses grep fallback)"
  command -v openspec >/dev/null 2>&1 && _dr_ok "openspec CLI $(openspec --version 2>/dev/null || echo present)" || _dr_fail "openspec CLI not found (install: npm i -g @fission-ai/openspec@latest)"
  echo ""
  echo "== LoopForge structure =="
  [[ -d "$proj/openspec" ]] && _dr_ok "openspec/ directory" || _dr_fail "openspec/ missing (run scaffold.sh)"
  [[ -f "$proj/openspec/guard.sh" ]] && _dr_ok "guard.sh (phase gate)" || _dr_warn "guard.sh missing (re-run scaffold.sh)"
  [[ -f "$proj/openspec/loop-state.yaml" ]] && _dr_ok "loop-state.yaml (state machine)" || _dr_warn "loop-state.yaml missing"
  [[ -f "$proj/openspec/ensure-branch.sh" ]] && _dr_ok "ensure-branch.sh (worktree isolation)" || _dr_warn "ensure-branch.sh missing"
  [[ -f "$proj/openspec/ensure-contract-fresh.sh" ]] && _dr_ok "ensure-contract-fresh.sh (contract freshness)" || _dr_warn "ensure-contract-fresh.sh missing"
  [[ -f "$proj/openspec/build-contract.sh" ]] && _dr_ok "build-contract.sh (contract auto-generation)" || _dr_warn "build-contract.sh missing (re-run scaffold.sh)"
  [[ -f "$proj/openspec/validate-artifacts.py" ]] && _dr_ok "validate-artifacts.py (schema validation)" || _dr_warn "validate-artifacts.py missing"
  [[ -f "$proj/openspec/verify.config.yaml" ]] && _dr_ok "verify.config.yaml (local L1 build / L3 test commands)" || _dr_warn "verify.config.yaml missing (L1/L3 will prompt to create)"
  [[ -d "$proj/openspec/sdd" ]] && _dr_ok "sdd/ (subagent templates)" || _dr_warn "sdd/ missing (SDD not available)"
  echo ""
  echo "== Entry files =="
  [[ -f "$proj/CLAUDE.md" ]] && _dr_ok "CLAUDE.md (Claude Code entry)" || _dr_warn "CLAUDE.md missing"
  [[ -f "$proj/AGENTS.md" ]] && _dr_ok "AGENTS.md (Codex entry)" || _dr_warn "AGENTS.md missing"
  echo ""
  echo "== Syntax =="
  bash -n "$0" 2>/dev/null && _dr_ok "scaffold.sh syntax valid" || _dr_fail "scaffold.sh syntax error"
  [[ -f "$proj/openspec/guard.sh" ]] && bash -n "$proj/openspec/guard.sh" 2>/dev/null && _dr_ok "guard.sh syntax valid" || true
  echo ""
  echo "Result: $pass pass, $warn warn, $fail fail"
  [[ $fail -eq 0 ]] && echo "Healthy" || echo "Issues found"
  [[ $fail -eq 0 ]]
}


cmd_version() {
  echo "LoopForge $LOOPFORGE_VERSION"
  echo "  scaffold: $(basename "$0")"
  echo "  bash:     ${BASH_VERSION:-unknown}"
  command -v openspec >/dev/null 2>&1 && echo "  openspec: $(openspec --version 2>/dev/null || echo present)" || echo "  openspec: not installed"
  command -v node >/dev/null 2>&1 && echo "  node:     $(node --version 2>/dev/null)" || true
}

cmd_contract() {
  local force=""
  [[ "${1:-}" == "--force" ]] && { force="--force"; shift; }
  local change_dir="${1:-}"
  [[ -n "$change_dir" ]] || { echo "Usage: scaffold.sh contract [--force] <change-dir>" >&2; exit 1; }

  # Resolve to absolute path
  change_dir="$(cd "$change_dir" 2>/dev/null && pwd)" || { echo "Error: not a directory: $change_dir" >&2; exit 1; }
  [[ -d "$change_dir" ]] || { echo "Error: not a directory: $change_dir" >&2; exit 1; }

  # Find openspec/ by searching upward
  local openspec_dir=""
  local cur="$change_dir"
  while [[ "$cur" != "/" ]]; do
    if [[ -d "$cur/openspec" ]]; then openspec_dir="$cur/openspec"; break; fi
    cur="$(dirname "$cur")"
  done

  if [[ -z "$openspec_dir" ]]; then
    echo "Error: openspec/ not found (searched upward from $change_dir)" >&2
    exit 1
  fi

  local build_sh="$openspec_dir/build-contract.sh"
  if [[ ! -f "$build_sh" ]]; then
    echo "Error: build-contract.sh not found at $build_sh" >&2
    echo "  Re-run scaffold.sh to generate it." >&2
    exit 1
  fi

  echo "Building execution-contract.md from planning artifacts..."
  bash "$build_sh" $force "$change_dir"
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    echo ""
    echo "Contract generated. Next steps:"
    echo "  1. Review AI-marked sections (<!-- AI: ... -->) in execution-contract.md"
    echo "  2. Run: bash openspec/ensure-contract-fresh.sh --update $change_dir"
    echo "  3. Begin apply phase (guard.sh will check contract freshness)"
  fi
  exit $rc
}

cmd_restructure() {
  local proj="${1:-.}"
  [[ -d "$proj" ]] || { echo "Error: not a directory: $proj" >&2; exit 1; }

  # Find root entry file
  local root_file=""
  for f in "$proj/CLAUDE.md" "$proj/AGENTS.md"; do
    [[ -f "$f" ]] && { root_file="$f"; break; }
  done
  [[ -n "$root_file" ]] || { echo "Error: no CLAUDE.md or AGENTS.md found in $proj" >&2; exit 1; }

  local total_lines
  total_lines=$(wc -l < "$root_file" | tr -d ' ')
  echo "================================================"
  echo "  LoopForge Restructure Analysis"
  echo "================================================"
  echo "Root file:    $root_file"
  echo "Total lines:  $total_lines"
  echo ""

  # --- Phase 1: Detect stacks by keyword scan ---
  local has_backend=0 has_frontend=0 has_mobile=0
  grep -qiE 'mvn|gradle|java[ _]|spring|mybatis|maven' "$root_file" && has_backend=1
  grep -qiE 'pnpm|npm|yarn|vue|react|vite|webpack|element|antd|tailwind' "$root_file" && has_frontend=1
  grep -qiE 'flutter|react-native|swift|uikit|kotlin.*android|expo' "$root_file" && has_mobile=1

  echo "--- Detected stacks ---"
  [[ $has_backend  -eq 1 ]] && echo "  [x] backend  (Java/Spring/mvn/gradle)"
  [[ $has_frontend -eq 1 ]] && echo "  [x] frontend (Vue/React/pnpm/npm)"
  [[ $has_mobile   -eq 1 ]] && echo "  [x] mobile   (Flutter/RN/Swift)"
  [[ $has_backend  -eq 0 && $has_frontend -eq 0 && $has_mobile -eq 0 ]] && echo "  [ ] no stacks detected by keyword (may need manual classification)"
  echo ""

  # --- Phase 2: Classify sections ---
  echo "--- Section classification ---"
  echo ""
  printf "%-6s %-40s %s\n" "Line" "Header" "Suggested target"
  printf "%-6s %-40s %s\n" "----" "------" "----------------"

  while IFS= read -r rawline; do
    local lineno header target section_content
    lineno=$(echo "$rawline" | cut -d: -f1)
    header=$(echo "$rawline" | cut -d: -f2-)
    [[ -z "$header" ]] && continue

    # Peek at section content until next ## header (max 15 lines)
    section_content=$(sed -n "$((lineno+1)),$((lineno+15))p" "$root_file" 2>/dev/null | sed '/^## /q' || true)

    # Classify: check header text first (more reliable), then content keywords
    target=""
    if echo "$header" | grep -qiE 'business|context|project|overview|项目|业务'; then
      target="root (nav hub) + project.md"
    elif echo "$header" | grep -qiE 'api|endpoint|route|接口'; then
      target="specs/api/spec.md"
    elif echo "$header" | grep -qiE 'error|错误|code'; then
      target="specs/errors/spec.md"
    elif echo "$header" | grep -qiE 'data|model|entity|数据|模型'; then
      target="specs/data/spec.md"
    elif echo "$header" | grep -qiE 'convention|naming|rule|规范|命名|standard'; then
      target="rules/ or specs/"
    elif echo "$header" | grep -qiE 'build|command|命令|构建'; then
      # Build commands: check which tools are present
      local _has_be=0 _has_fe=0
      echo "$section_content" | grep -qiE 'mvn|gradle|maven' && _has_be=1
      echo "$section_content" | grep -qiE 'pnpm|npm|yarn' && _has_fe=1
      if [[ $_has_be -eq 1 && $_has_fe -eq 1 ]]; then
        target="split by tool (backend+frontend agents)"
      elif [[ $_has_be -eq 1 ]]; then
        target="backend agent"
      elif [[ $_has_fe -eq 1 ]]; then
        target="frontend agent"
      else
        target="root (build commands)"
      fi
    elif echo "$header" | grep -qiE 'backend|后端|java|spring'; then
      target="backend agent"
    elif echo "$header" | grep -qiE 'frontend|前端|vue|react'; then
      target="frontend agent"
    elif echo "$header" | grep -qiE 'mobile|移动|flutter|react-native'; then
      target="mobile agent"
    elif echo "$section_content" | grep -qiE 'mvn|gradle|spring|mybatis|maven'; then
      target="backend agent"
    elif echo "$section_content" | grep -qiE 'pnpm|npm|yarn|vue|react|vite|element|antd|tailwind'; then
      target="frontend agent"
    elif echo "$section_content" | grep -qiE 'flutter|react-native|swift|kotlin.*android'; then
      target="mobile agent"
    else
      target="root or rules/"
    fi

    # Trim header for display
    local disp_header="$header"
    [[ ${#disp_header} -gt 38 ]] && disp_header="${disp_header:0:35}..."
    printf "%-6s %-40s %s\n" "$lineno" "$disp_header" "$target"
  done < <(grep -n '^## \|^### ' "$root_file")

  echo ""

  # --- Phase 3: Complexity assessment ---
  echo "--- Complexity assessment ---"
  if [[ $total_lines -gt 250 ]]; then
    echo "  [HIGH] Root file is $total_lines lines (>250). Splitting is strongly recommended."
  elif [[ $total_lines -gt 120 ]]; then
    echo "  [MED] Root file is $total_lines lines (>120). Consider splitting."
  else
    echo "  [LOW] Root file is $total_lines lines (<=120). May not need splitting."
  fi

  local stack_count=$(( has_backend + has_frontend + has_mobile ))
  if [[ $stack_count -gt 1 ]]; then
    echo "  [MULTI-STACK] $stack_count stacks detected. Per-stack agents recommended."
  elif [[ $stack_count -eq 1 ]]; then
    echo "  [SINGLE-STACK] Only 1 stack. Add Role + NEVER + Superpowers + TDD to existing file."
  fi
  echo ""

  # --- Phase 4: Migration plan ---
  echo "--- Migration plan ---"
  echo "  1. Review the classification table above"
  echo "  2. AI: extract content blocks into their target files (semantic step)"
  echo "  3. Run 'scaffold.sh <project> --no-init' to generate openspec/ + agent skeletons"
  echo "  4. Rewrite root entry file as nav hub (<=120 lines)"
  echo "  5. Verify: no content lost, no duplication, cross-domain prohibition in each agent"
  echo ""
  echo "  See SKILL.md 'Mode: Restructure' Phase 1-5 for detailed extraction rules."
}

# ---------------- dispatch ----------------
_subcmd="scaffold"
case "${1:-}" in
  list|--list)                           _subcmd="list";  shift;;
  check|--check|self-check|--self-check) _subcmd="check"; shift;;
  tokens|--tokens)                       _subcmd="tokens"; shift;;
  validate|--validate)                   _subcmd="validate"; shift;;
  changes|--changes)                     _subcmd="changes"; shift;;
  doctor|--doctor)                       _subcmd="doctor"; shift;;
  version|--version|-V)                  _subcmd="version"; shift;;
  contract|--contract)                  _subcmd="contract"; shift;;
  restructure|--restructure)            _subcmd="restructure"; shift;;
esac
case "$_subcmd" in
  list)  cmd_list  "$@"; exit 0;;
  check) cmd_check "$@"; exit 0;;
  tokens) cmd_tokens "$@"; exit 0;;
  validate) cmd_validate "$@"; exit 0;;
  changes) cmd_changes "$@"; exit 0;;
  doctor)  cmd_doctor  "$@"; exit 0;;
  version)     cmd_version     "$@"; exit 0;;
  contract)    cmd_contract    "$@"; exit 0;;
  restructure) cmd_restructure "$@"; exit 0;;
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
