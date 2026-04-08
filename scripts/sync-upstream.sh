#!/usr/bin/env bash
set -euo pipefail

# Sync upstream superpowers: git subtree pull + rebuild
# Usage:
#   scripts/sync-upstream.sh              # full sync
#   scripts/sync-upstream.sh --dry-run    # show what would change

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

UPSTREAM_URL="https://github.com/obra/superpowers.git"
UPSTREAM_BRANCH="main"
SUBTREE_PREFIX="vendor/superpowers"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

echo "=== Syncing upstream superpowers ==="

if $DRY_RUN; then
  echo "DRY RUN: fetching upstream to check for changes..."
  git fetch "$UPSTREAM_URL" "$UPSTREAM_BRANCH" 2>&1
  DIFF=$(git diff "FETCH_HEAD" -- "$SUBTREE_PREFIX" 2>/dev/null || echo "")
  if [[ -z "$DIFF" ]]; then
    echo "No upstream changes detected."
  else
    echo "Upstream changes detected:"
    git diff --stat "FETCH_HEAD" -- "$SUBTREE_PREFIX" 2>/dev/null
  fi
  exit 0
fi

# Pull upstream changes into subtree
echo "Pulling upstream changes..."
git subtree pull --prefix="$SUBTREE_PREFIX" "$UPSTREAM_URL" "$UPSTREAM_BRANCH" --squash 2>&1 || {
  echo "ERROR: git subtree pull failed. Resolve conflicts and try again."
  exit 1
}

# Rebuild skills from updated vendor
echo "Rebuilding skills from updated vendor..."
bash "$SCRIPT_DIR/build-upstream-skills.sh"

echo ""
echo "=== Sync complete ==="
echo "Review changes with: git diff --stat skills/"
echo "Commit when satisfied: git add skills/ && git commit -m 'chore: sync upstream superpowers'"
