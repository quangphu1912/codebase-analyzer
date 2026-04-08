# Changelog

## 0.2.0 — 2026-04-07

### Breaking Changes
- Removed `map-conditional-behavior` — replaced by `extract-tool-graph` + `map-feature-gates`
- Removed `synthesize-findings` — replaced by `reconstruct-system-intent`

### New Skills (6 added, 2 removed = net +4)
- `trace-data-flows` — Track B Phase 2: data flow mapping across codebase
- `extract-tool-graph` — Track B Phase 3: extract tool availability maps
- `map-feature-gates` — Track B Phase 3: conditional behavior and feature gates
- `simulate-behavior` — Track B Phase 3: multi-scenario behavior testing
- `reconstruct-system-intent` — Track B Phase 4: synthesize system purpose
- `detect-hidden-contracts` — Special: find implicit APIs and undocumented contracts

### Improvements
- Track B expanded from 4 phases to structured 4-phase pipeline (8 -> 10 skills)
- Word budgets replaced with Three Depths Model (Surface, Deep, Intent)
- Agents updated with dispatch protocol (which skills may dispatch them)
- `behavior-simulator` agent references updated from removed skills

### Total: 20 skills + 2 agents

## 0.1.0 — 2026-04-07

Initial release.

- 14 analysis skills across two tracks (reconnaissance + deep dive)
- 2 special skills (test-hypothesis, synthesize-findings)
- 2 agents (code-explorer, behavior-simulator)
- Claude Code plugin with SessionStart hook and marketplace listing
- OpenCode plugin with config + chat.transform hooks
- Codex support via clone-and-symlink
- Cross-platform hook support (macOS, Linux, Windows)
