# codebase-analyzer

Progressive-depth codebase analysis and reverse engineering plugin for Claude Code.

## Quick Start

```bash
claude plugin install https://github.com/quangphu1912/codebase-analyzer.git
```

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
| Phase | Skills |
|-------|--------|
| 1. Establish Truth | `trace-codebase-provenance`, `analyze-build-pipeline` |
| 2. Map Runtime | `classify-repo-artifacts`, `analyze-agent-loop` |
| 3. Gates & Behavior | `map-conditional-behavior`, `analyze-prompt-influence` |
| 4. System Intent | `reconstructing-system-intent` (via synthesize-findings) |

### Special Modes
| Skill | Purpose |
|-------|---------|
| `/codebase-analyzer:classify-analysis-target` | Determine what we're analyzing (runs first) |
| `/codebase-analyzer:test-hypothesis` | Hypothesis-driven targeted analysis |
| `/codebase-analyzer:synthesize-findings` | Comprehensive analysis report |

## How It Works

Track A scans the surface. When it finds signals worth investigating deeper (with confidence scores), it offers to trigger Track B's phased deep dive. You can also jump straight to any skill or start a hypothesis test.

## License

MIT
