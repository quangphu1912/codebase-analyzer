# Releasing

Step-by-step guide for publishing a new version of codebase-analyzer.

## Prerequisites

- `jq` installed (used by `bump-version.sh`)
- `gh` CLI authenticated (`gh auth status`)
- Clean working tree (`git status` shows nothing)

## Steps

### 1. Update CHANGELOG.md

Add a new section at the top (below the `# Changelog` header):

```markdown
## vX.Y.Z — YYYY-MM-DD

### Breaking Changes
- ...

### New
- ...

### Fixed
- ...
```

Convention: always use the `v` prefix to match git tags.

### 2. Bump version in all files

```bash
scripts/bump-version.sh X.Y.Z
```

This updates `package.json`, `.claude-plugin/plugin.json`, and `.claude-plugin/marketplace.json` (configured in `.version-bump.json`).

Verify:

```bash
scripts/bump-version.sh --check
```

### 3. Commit

```bash
git add -A
git commit -m "chore: release vX.Y.Z"
```

### 4. Tag and push

```bash
git tag vX.Y.Z
git push origin main
git push origin vX.Y.Z
```

### 5. Create GitHub release

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z" \
  --notes "One-line summary of the release.

$(sed -n '/^## vX\.Y\.Z/,/^## v/{ /^## v[^X]/d; p; }' CHANGELOG.md)"
```

Or write the notes to a temp file first if the sed is unwieldy:

```bash
sed -n '/^## vX\.Y\.Z/,/^## v/{/^## v.*—/!p;}' CHANGELOG.md > /tmp/notes.md
# Edit /tmp/notes.md — add a summary line at the top
gh release create vX.Y.Z --title "vX.Y.Z" --notes-file /tmp/notes.md
```

### 6. Update the marketplace repo

If the SHA in `ai-plugins/.claude-plugin/marketplace.json` pins a specific commit:

```bash
cd ~/GitHub/projects/ai-plugins
# Update the sha field to the new tag's commit
git add -A && git commit -m "chore: bump codebase-analyzer to vX.Y.Z" && git push
```

### 7. Verify

In a fresh Claude Code session:

```
/plugin marketplace add quangphu1912/ai-plugins
/plugin install codebase-analyzer@ai-plugins
```

Start a new session and confirm the bootstrap skill auto-loads.

## Validation

Run before tagging to catch structural issues:

```bash
scripts/validate.sh
```

All 193+ checks should pass with 0 failures.

## Version files

Managed by `scripts/bump-version.sh` via `.version-bump.json`:

| File | Field |
|------|-------|
| `package.json` | `version` |
| `.claude-plugin/plugin.json` | `version` |
| `.claude-plugin/marketplace.json` | `plugins[0].version` |

## Reference: v0.2.0 release (2026-04-08)

Actual commands run for the v0.2.0 release:

```bash
# 1. CHANGELOG.md and version bumps were already committed

# 2. Verify versions are in sync
scripts/bump-version.sh --check
#   package.json (version)                        0.2.0
#   .claude-plugin/plugin.json (version)          0.2.0
#   .claude-plugin/marketplace.json (plugins.0.version) 0.2.0

# 3. Run validation
scripts/validate.sh
#   === Results: 193 passed, 0 failed, 0 warnings ===

# 4. Tag and push
git tag v0.2.0
git push origin v0.2.0

# 5. Create GitHub release
gh release create v0.2.0 --title "v0.2.0" --notes-file CHANGELOG.md

# 6. Post-release fix: added one-line summary to release notes
gh release edit v0.2.0 --notes "32 skills + 3 agents — adds 6 deep analysis skills, \
12 orchestration/dev-workflow skills, multi-platform support, and a code-reviewer agent.

$(gh release view v0.2.0 --json body -q .body)"

# 7. Fixed marketplace repo (ai-plugins)
#    - Moved marketplace.json from repo root to .claude-plugin/marketplace.json
#    - Added $schema and proper source format with pinned SHA
#    - Removed stale root marketplace.json

# 8. Post-release doc fix: added v prefix to CHANGELOG headers
#    (CHANGELOG said "## 0.2.0", tags use "v0.2.0" — now consistent)
git commit -m "docs: add v prefix to CHANGELOG headers for tag consistency"
git push origin main
```

### Lessons learned

- `marketplace.json` must live at `.claude-plugin/marketplace.json`, not the repo root
- CHANGELOG headers should use the `v` prefix from day one to match git tags
- Always add a one-line summary at the top of GitHub release notes — the full changelog is detailed but needs a quick overview
