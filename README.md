# codebase-analyzer

Progressive-depth codebase analysis and reverse engineering plugin for Claude Code.

## Installation

### Claude Code

```bash
claude plugin install https://github.com/quangphu1912/codebase-analyzer.git
```

### OpenCode

See [.opencode/INSTALL.md](.opencode/INSTALL.md)

### Codex

See [.codex/INSTALL.md](.codex/INSTALL.md)

## Quick Start

1. Install the plugin (see Installation above)
2. Start a new Claude Code session in any codebase
3. Ask: "Analyze this codebase" — the plugin auto-classifies and runs Track A
4. Or test a hypothesis: "I think this app sends data to third parties"

## Updating

```bash
claude plugin update codebase-analyzer
```

For OpenCode, restart to auto-update.

## Skills

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
| `/codebase-analyzer:classify-analysis-target` | Determine what we're analyzing (runs first) |
| `/codebase-analyzer:detect-hidden-contracts` | Find implicit APIs and undocumented contracts |
| `/codebase-analyzer:test-hypothesis` | Hypothesis-driven targeted analysis |

## How It Works

Track A scans the surface. When it finds signals worth investigating deeper (with confidence scores), it offers to trigger Track B's phased deep dive. You can also jump straight to any skill or start a hypothesis test.

## License

MIT
