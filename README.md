# codebase-analyzer

Progressive-depth codebase analysis and reverse engineering plugin for Claude Code, OpenCode, and Codex.

## Installation

### Claude Code

```
/plugin marketplace add quangphu1912/ai-plugins
/plugin install codebase-analyzer@ai-plugins
/reload-plugins
```

### OpenCode

See [.opencode/INSTALL.md](.opencode/INSTALL.md)

### Codex

See [.codex/INSTALL.md](.codex/INSTALL.md)

## Quick Start

1. Install the plugin (see Installation above)
2. Start a new Claude Code session in any codebase
3. **For analysis:** Ask "Analyze this codebase" — the plugin auto-classifies and runs Track A
4. **For development:** Say "implement", "plan this", or "debug" — the plugin routes to orchestration skills
5. Or test a hypothesis: "I think this app sends data to third parties"

## Updating

```
/plugin marketplace update ai-plugins
/plugin update codebase-analyzer
/reload-plugins
```

## Skills

### Bootstrap
| Skill | Purpose |
|-------|---------|
| `/codebase-analyzer:using-codebase-analyzer` | Auto-loaded entry point — routes to the right skills |
| `/codebase-analyzer:classify-analysis-target` | Determine what we're analyzing (runs first) |

### Track A: Reconnaissance
| Skill | Purpose |
|-------|---------|
| `/codebase-analyzer:identifying-tech-stack` | Framework/library/version detection |
| `/codebase-analyzer:mapping-architecture` | Component relationships, layers |
| `/codebase-analyzer:tracing-dependencies` | Coupling, circular deps |
| `/codebase-analyzer:detecting-dead-code` | Unused code, orphaned files |
| `/codebase-analyzer:inventorying-api-surface` | Public interfaces, endpoints |
| `/codebase-analyzer:analyzing-code-quality` | Anti-patterns, hotspots |

### Track B: Deep Reverse Engineering
| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Establish Truth | `trace-codebase-provenance`, `analyze-build-pipeline` | Git archaeology, build reality |
| 2. Map Runtime | `classify-repo-artifacts`, `analyze-agent-loop`, `trace-data-flows` | Artifact classification, loops, data flows |
| 3. Gates & Behavior | `extract-tool-graph`, `map-feature-gates`, `simulate-behavior`, `analyze-prompt-influence` | Tool maps, feature gates, scenario testing |
| 4. System Intent | `reconstruct-system-intent` | What the system was built to do |

### Special Modes
| Skill | Purpose |
|-------|---------|
| `/codebase-analyzer:detect-hidden-contracts` | Find implicit APIs and undocumented contracts |
| `/codebase-analyzer:test-hypothesis` | Hypothesis-driven targeted analysis |

### Orchestration (Development Workflow)
| Skill | Purpose |
|-------|---------|
| `/codebase-analyzer:brainstorming` | Design-first approach before implementation |
| `/codebase-analyzer:writing-plans` | Break specs into bite-sized tasks |
| `/codebase-analyzer:subagent-driven-development` | Fresh subagent per task, review between |
| `/codebase-analyzer:executing-plans` | Batch execution with checkpoints |
| `/codebase-analyzer:dispatching-parallel-agents` | Concurrent subagent dispatch |
| `/codebase-analyzer:test-driven-development` | RED-GREEN-REFACTOR cycle |
| `/codebase-analyzer:systematic-debugging` | Root cause investigation process |
| `/codebase-analyzer:verification-before-completion` | Verify commands pass before finishing |
| `/codebase-analyzer:using-git-worktrees` | Isolated parallel workspace management |
| `/codebase-analyzer:finishing-a-development-branch` | Merge/PR workflow |
| `/codebase-analyzer:requesting-code-review` | Dispatch code-reviewer agent |
| `/codebase-analyzer:receiving-code-review` | Process and apply review feedback |

## How It Works

**Analysis workflow:** Track A scans the surface. When it finds signals worth investigating deeper (with confidence scores), it offers to trigger Track B's phased deep dive. You can also jump straight to any skill or start a hypothesis test.

**Development workflow:** The bootstrap skill also routes development triggers ("build", "plan", "debug", "test", "review") to orchestration skills cloned from the superpowers plugin. These skills provide structured development lifecycles — brainstorming, planning, implementation, testing, and review.

## Platform Compatibility

| Feature | Claude Code | OpenCode | Codex |
|---------|-------------|----------|-------|
| Auto-bootstrap | SessionStart hook | Plugin message transform | AGENTS.md symlink |
| Full Track A | Yes | Yes | Yes |
| Full Track B | Yes | Yes (degraded) | Yes (degraded) |
| Agent dispatch | Yes | No | No |
| docs/analysis/ output | Yes | Yes | Inline fallback |
| Skill tool | Native | Native | N/A |

See [PLATFORM-NOTES.md](skills/using-codebase-analyzer/PLATFORM-NOTES.md) for complete tool substitution table and degraded mode details.

## License

MIT
