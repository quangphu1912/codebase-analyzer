#!/usr/bin/env bash
set -euo pipefail

# Structural validation for codebase-analyzer
# Usage: ./scripts/validate.sh
# All checks must pass for a healthy repo.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PASS=0
FAIL=0
WARN=0

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "  PASS: $description"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $description"
        FAIL=$((FAIL + 1))
    fi
}

warn() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "  PASS: $description"
        PASS=$((PASS + 1))
    else
        echo "  WARN: $description"
        WARN=$((WARN + 1))
    fi
}

echo "=== codebase-analyzer structural validation ==="
echo ""

# Cloned orchestration skills (different conventions from analysis skills)
ORCHESTRATION_SKILLS=(
  brainstorming
  writing-plans
  subagent-driven-development
  executing-plans
  dispatching-parallel-agents
  test-driven-development
  systematic-debugging
  verification-before-completion
  using-git-worktrees
  finishing-a-development-branch
  requesting-code-review
  receiving-code-review
)
is_orchestration() {
  local name="$1"
  for s in "${ORCHESTRATION_SKILLS[@]}"; do
    [[ "$s" == "$name" ]] && return 0
  done
  return 1
}

# --- Platform infrastructure ---
echo "--- Platform Infrastructure ---"
check "PLATFORM-NOTES.md exists" test -f "$REPO_ROOT/skills/using-codebase-analyzer/PLATFORM-NOTES.md"
check "PLATFORM-NOTES.md has Capability Matrix" grep -q "Capability Matrix" "$REPO_ROOT/skills/using-codebase-analyzer/PLATFORM-NOTES.md"
check "PLATFORM-NOTES.md has Tool Substitution Table" grep -q "Tool Substitution" "$REPO_ROOT/skills/using-codebase-analyzer/PLATFORM-NOTES.md"
check "PLATFORM-NOTES.md has Degraded Mode" grep -q "Degraded Mode" "$REPO_ROOT/skills/using-codebase-analyzer/PLATFORM-NOTES.md"

# --- Skill frontmatter ---
echo ""
echo "--- Skill Frontmatter ---"
SKILL_COUNT=0
for skill_dir in "$REPO_ROOT"/skills/*/; do
    [[ "$(basename "$skill_dir")" == "_shared" ]] && continue
    skill_file="$skill_dir/SKILL.md"
    skill_name="$(basename "$skill_dir")"

    check "Skill $skill_name: SKILL.md exists" test -f "$skill_file"
    check "Skill $skill_name: has name field" grep -q "^name:" "$skill_file"
    check "Skill $skill_name: has description field" grep -q "^description:" "$skill_file"
    if is_orchestration "$skill_name"; then
        check "Skill $skill_name: description starts with 'Use when'" grep -q "^description:" "$skill_file"
    else
        check "Skill $skill_name: description starts with 'Use when'" grep -q "^description: Use when" "$skill_file"
    fi
    SKILL_COUNT=$((SKILL_COUNT + 1))
done
echo "  (Found $SKILL_COUNT skills)"

# --- Output contracts ---
echo ""
echo "--- Output Contracts ---"
for skill_dir in "$REPO_ROOT"/skills/*/; do
    [[ "$(basename "$skill_dir")" == "_shared" ]] && continue
    skill_file="$skill_dir/SKILL.md"
    skill_name="$(basename "$skill_dir")"
    [[ "$skill_name" == "using-codebase-analyzer" ]] && continue
    is_orchestration "$skill_name" && continue
    check "Skill $skill_name: has Output Contract section" grep -q "## Output Contract\|## Output contract\|Write.*docs/analysis/" "$skill_file"
done

# --- Agent frontmatter ---
echo ""
echo "--- Agent Definitions ---"
for agent_file in "$REPO_ROOT"/agents/*.md; do
    agent_name="$(basename "$agent_file" .md)"
    check "Agent $agent_name: has name field" grep -q "^name:" "$agent_file"
    check "Agent $agent_name: has description field" grep -q "^description:" "$agent_file"
    check "Agent $agent_name: has tools field" grep -q "^tools:" "$agent_file"
    check "Agent $agent_name: has model field" grep -q "^model:" "$agent_file"
done

# --- Cross-references ---
echo ""
echo "--- Cross-References ---"
bootstrap="$REPO_ROOT/skills/using-codebase-analyzer/SKILL.md"
for skill_dir in "$REPO_ROOT"/skills/*/; do
    [[ "$(basename "$skill_dir")" == "_shared" ]] && continue
    [[ "$(basename "$skill_dir")" == "using-codebase-analyzer" ]] && continue
    skill_name="$(basename "$skill_dir")"
    is_orchestration "$skill_name" && continue
    check "Bootstrap references $skill_name" grep -q "$skill_name" "$bootstrap"
done

# --- Hook validation ---
echo ""
echo "--- Hooks ---"
check "hooks/session-start is executable" test -x "$REPO_ROOT/hooks/session-start"
check "hooks/session-start produces valid JSON (Claude Code mode)" bash -c 'CLAUDE_PLUGIN_ROOT=/tmp bash hooks/session-start 2>/dev/null | python3 -c "import sys,json; json.load(sys.stdin)"'
check "hooks/session-start produces valid JSON (generic mode)" bash -c 'bash hooks/session-start 2>/dev/null | python3 -c "import sys,json; json.load(sys.stdin)"'

# --- OpenCode plugin ---
echo ""
echo "--- OpenCode Plugin ---"
check "Plugin JS has no syntax errors" node --input-type=module -e "import('$REPO_ROOT/.opencode/plugins/codebase-analyzer.js')" 2>/dev/null
check "Plugin JS does NOT reference @mention for agent dispatch" bash -c '! grep -q "@mention" "$REPO_ROOT/.opencode/plugins/codebase-analyzer.js"'
check "Plugin JS reads from PLATFORM-NOTES.md" grep -q "PLATFORM-NOTES" "$REPO_ROOT/.opencode/plugins/codebase-analyzer.js"

# --- Upstream skill transforms ---
echo ""
echo "--- Upstream Skill Transforms ---"
SUPERPOWERS_REFS=$(grep -r "superpowers:" "$REPO_ROOT/skills/" 2>/dev/null | wc -l | tr -d ' ' || true)
if [[ "$SUPERPOWERS_REFS" -eq 0 ]]; then
    echo "  PASS: No untransformed 'superpowers:' references in skills/"
    PASS=$((PASS + 1))
else
    echo "  FAIL: $SUPERPOWERS_REFS untransformed 'superpowers:' references in skills/"
    FAIL=$((FAIL + 1))
fi

# --- Version sync ---
echo ""
echo "--- Version Sync ---"
if command -v jq >/dev/null 2>&1; then
    check "Version bump script runs" bash "$REPO_ROOT/scripts/bump-version.sh" --check
else
    warn "jq not installed (skipping version sync check)" true
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed, $WARN warnings ==="
if [ "$FAIL" -gt 0 ]; then
    echo "FAILED: $FAIL checks did not pass"
    exit 1
fi
echo "ALL CHECKS PASSED"
