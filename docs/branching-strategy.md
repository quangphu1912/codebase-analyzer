# Branch & Release Strategy

## Branch Model: GitHub Flow + Tags

```
main (stable, installable)
  │
  ├── feat/new-skill-name      ← skill development
  ├── fix/session-start-bug    ← bug fixes
  └── refactor/track-b-prereqs ← structural changes
```

## Rules

- `main` is always installable — direct repo installs (`/plugin install`) pull from `main` HEAD
- Marketplace installs are SHA-pinned — commits to `main` do **not** affect marketplace users
- Small, atomic changes (docs, single-skill fixes) can go directly to `main`
- Multi-commit work uses feature branches, squash merged back to `main`
- Tag releases: `git tag v0.2.0 && git push --tags`
- Users can pin versions: `codebase-analyzer.git#v0.1.0`

See `docs/releasing.md` for the full release process and post-release workflow.

## Branch Naming

| Prefix | Use |
|--------|-----|
| `feat/` | New skills, agents, or capabilities |
| `fix/` | Bug fixes to existing skills or hooks |
| `refactor/` | Structural changes, no behavior change |
| `docs/` | Documentation only |

## Versioning (Semver)

| Change | Bump | Example |
|--------|------|---------|
| New skills added | Minor | `0.1.0` → `0.2.0` |
| Skill behavior changes | Minor | `0.2.0` → `0.3.0` |
| Bug fixes only | Patch | `0.1.0` → `0.1.1` |
| Skill renamed/removed | Major | `0.x.y` → `1.0.0` |

## Release Process

```bash
# 1. Bump version across all manifests
./scripts/bump-version.sh 0.2.0

# 2. Update CHANGELOG.md

# 3. Commit
git add -A
git commit -m "release: v0.2.0"

# 4. Tag and push
git tag v0.2.0
git push && git push --tags
```

## When to Scale Up

| Trigger | Add |
|---------|-----|
| Multiple contributors | Protected `main`, require PR reviews |
| Testing unreleased skills | `next` branch for beta testing |
| Automated skill tests exist | CI pipeline on PRs |
| Maintaining old versions | Release branches (`release/0.x`) |

## What We Don't Need Yet

- `develop` branch — unnecessary indirection for a single-track plugin
- Release branches — not maintaining multiple versions
- CI testing — until automated skill evals exist
- GitFlow — adds ceremony with zero benefit for this project type
