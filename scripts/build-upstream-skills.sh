#!/usr/bin/env bash
set -euo pipefail

# Selective copy + transform: vendor/superpowers/skills/ -> skills/
# This script IS the manifest of which upstream skills we ship.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VENDOR="$REPO_ROOT/vendor/superpowers/skills"
OUTPUT="$REPO_ROOT/skills"

# Skills to clone from upstream (the manifest)
SKILLS=(
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

# Cross-cutting transforms applied to every cloned file
cross_cutting_transforms() {
  local file="$1"
  # Namespace rename
  sed -i '' 's/superpowers:/codebase-analyzer:/g' "$file"
  # Agent reference rename
  sed -i '' 's/codebase-analyzer:code-reviewer/codebase-analyzer:code-reviewer/g' "$file"
  # Config path update
  sed -i '' 's|~/.config/superpowers/|~/.config/codebase-analyzer/|g' "$file"
}

# Per-skill transforms
per_skill_transform() {
  local skill_name="$1"
  local file="$2"

  if [[ "$skill_name" == "brainstorming" ]]; then
    # Strip visual companion references
    sed -i '' '/visual-companion/d' "$file"
    sed -i '' '/start-server/d' "$file"
    sed -i '' '/stop-server/d' "$file"
  fi
}

# Per-skill file-level cleanup (remove unwanted files from copied skills)
per_skill_cleanup() {
  local skill_name="$1"
  local dst="$2"

  if [[ "$skill_name" == "brainstorming" ]]; then
    # Remove visual companion server (not needed, browser-only tool)
    rm -rf "$dst/scripts" "$dst/visual-companion.md" "$dst/frame-template.html" 2>/dev/null || true
  fi
}

echo "=== Building upstream skills ==="
echo ""

UPDATED=0
SKIPPED=0

for skill in "${SKILLS[@]}"; do
  src="$VENDOR/$skill"
  dst="$OUTPUT/$skill"

  if [[ ! -d "$src" ]]; then
    echo "  SKIP: $skill (not found in vendor/)"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Copy skill directory
  rm -rf "$dst"
  cp -r "$src" "$dst"

  # Remove unwanted files
  per_skill_cleanup "$skill" "$dst"

  # Apply transforms to all files in the skill
  for file in "$dst"/**/*.md "$dst"/*.md; do
    [[ -f "$file" ]] || continue
    cross_cutting_transforms "$file"
    per_skill_transform "$skill" "$file"
  done

  echo "  COPIED: $skill"
  UPDATED=$((UPDATED + 1))
done

echo ""
echo "=== Results: $UPDATED copied, $SKIPPED skipped ==="

# Verify no untransformed references remain
SUPERPOWERS_REFS=$(grep -r "superpowers:" "$OUTPUT/" 2>/dev/null | wc -l | tr -d ' ' || true)
if [[ "$SUPERPOWERS_REFS" -gt 0 ]]; then
  echo "WARNING: $SUPERPOWERS_REFS untransformed 'superpowers:' references remain in skills/"
  grep -r "superpowers:" "$OUTPUT/" 2>/dev/null | head -10
  exit 1
fi

echo "All namespace references transformed successfully."
