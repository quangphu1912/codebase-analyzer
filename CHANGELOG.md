# Changelog

## 0.2.0 — 2026-04-07

### Breaking Changes
- Removed `map-conditional-behavior` — replaced by `extract-tool-graph` + `map-feature-gates`
- Removed `synthesize-findings` — replaced by `reconstruct-system-intent`

### New Analysis Skills (6 added, 2 removed = net +4)
- `trace-data-flows` — Track B Phase 2: data flow mapping across codebase
- `extract-tool-graph` — Track B Phase 3: extract tool availability maps
- `map-feature-gates` — Track B Phase 3: conditional behavior and feature gates
- `simulate-behavior` — Track B Phase 3: multi-scenario behavior testing
- `reconstruct-system-intent` — Track B Phase 4: synthesize system purpose
- `detect-hidden-contracts` — Special: find implicit APIs and undocumented contracts

### Orchestration Skills (12 added — cloned from superpowers via git subtree)
- `brainstorming` — Design-first approach before implementation
- `writing-plans` — Spec to bite-sized task breakdown
- `subagent-driven-development` — Fresh subagent per task with review between
- `executing-plans` — Batch execution with checkpoints
- `dispatching-parallel-agents` — Concurrent subagent dispatch
- `test-driven-development` — RED-GREEN-REFACTOR cycle
- `systematic-debugging` — Root cause investigation process
- `verification-before-completion` — Verify commands pass before finishing
- `using-git-worktrees` — Isolated parallel workspace management
- `finishing-a-development-branch` — Merge/PR workflow
- `requesting-code-review` — Dispatch code-reviewer agent
- `receiving-code-review` — Process and apply review feedback

### New Agent
- `code-reviewer` — Production readiness code review (dispatched by requesting-code-review, subagent-driven-development)

### Multi-Platform Support
- Platform capability matrix: Claude Code (full), OpenCode (degraded: no agents), Codex (degraded: no agents)
- PLATFORM-NOTES.md: single source of truth for tool substitution table
- session-start hook rewritten for capability probing + degraded mode fallback
- OpenCode plugin fixed (removed incorrect @mention)
- validate.sh: 193 structural checks for skills, agents, hooks, and plugin health

### Bootstrap Skill Enhancement
- `using-codebase-analyzer` now routes both analysis triggers AND development workflow triggers
- Development keywords ("build", "plan", "debug", "test", "review") dispatch to orchestration skills

### Infrastructure
- GitHub issue templates (bug report, skill request) and PR template
- Upstream sync script: `scripts/sync-upstream.sh` pulls superpowers via git subtree

### Improvements
- Track B expanded from 4 phases to structured 4-phase pipeline (8 -> 10 analysis skills)
- Word budgets replaced with Three Depths Model (Surface, Deep, Intent)
- Agents updated with dispatch protocol (which skills may dispatch them)
- `behavior-simulator` agent references updated from removed skills
- Orchestration skills stored in `vendor/superpowers/` and transformed via `scripts/build-upstream-skills.sh`

### Total: 32 skills + 3 agents

## 0.1.0 — 2026-04-07

Initial release.

- 14 analysis skills across two tracks (reconnaissance + deep dive)
- 2 special skills (test-hypothesis, synthesize-findings)
- 2 agents (code-explorer, behavior-simulator)
- Claude Code plugin with SessionStart hook and marketplace listing
- OpenCode plugin with config + chat.transform hooks
- Codex support via clone-and-symlink
- Cross-platform hook support (macOS, Linux, Windows)
