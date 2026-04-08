# Platform Compatibility Notes

Skills are written using Claude Code tool names. Non-Claude Code platforms should substitute tools using the table below. Agent dispatch is available only on Claude Code.

## Capability Matrix

| Feature | Claude Code | OpenCode | Codex |
|---------|-------------|----------|-------|
| Auto-bootstrap | Yes (SessionStart hook) | Yes (plugin message transform) | Manual (AGENTS.md symlink + native skill discovery) |
| Skill tool | Native | Native | N/A (inline discovery via symlink) |
| Agent dispatch | Full (code-explorer, behavior-simulator) | Not available | Not available |
| docs/analysis/ output | Full | Full | Fallback to inline (sandbox) |
| Git commands | Full | Full | Sandbox-limited (may be detached HEAD) |
| Task tracking | TodoWrite | todowrite | Markdown checklist |

## Tool Substitution Table

| Claude Code | OpenCode | Codex |
|-------------|----------|-------|
| Read | Read | Native file read |
| Write | Write | Native file write |
| Edit | Edit | Native file edit |
| Glob | Glob | search / list_files |
| Grep | Grep | search |
| Bash | Bash | Native shell (may be sandboxed) |
| TodoWrite | todowrite | Markdown checklist in response |
| Task (subagent) | Not available | Not available |
| Skill tool | Native skill | Native skill | N/A (follow instructions directly) |
| Agent (code-explorer) | Not available | Not available | Not available |
| Agent (behavior-simulator) | Not available | Not available | Not available |

## Degraded Mode

When agent dispatch is unavailable (OpenCode, Codex):

1. Warn: "Full analysis requires agent dispatch (not available on this platform). Running in degraded mode."
2. Execute simplified single-pass analysis using native tools (max 3 trace levels deep).
3. Mark output as partial: `## Status: partial | Platform: degraded (no agent dispatch)`.
4. Note in findings which analysis steps were limited by platform constraints.

Users get a clear quality signal instead of misleading completeness.

### Skills affected by degraded mode

| Skill | Normal Mode | Degraded Mode |
|-------|-------------|---------------|
| extract-tool-graph | Dispatches code-explorer for 5+ file traces | Traces max 3 registration chains inline |
| simulate-behavior | Dispatches behavior-simulator for multi-scenario comparison | Traces 2 scenarios inline, limited comparison |
| trace-codebase-provenance | Dispatches code-explorer for chain-of-custody | Traces provenance inline, single pass |
| trace-data-flows | Dispatches code-explorer for 5+ file flows | Traces max 3 data flow chains inline |
| test-hypothesis | May dispatch either agent | Tests hypothesis with native tools only |

## Codex Sandbox Notes

- No hook mechanism. Bootstrap relies on AGENTS.md symlink (points to CLAUDE.md) + native skill discovery from `~/.agents/skills/`.
- git may be in detached HEAD: use `git log --all` instead of branch-specific commands.
- docs/analysis/ may not be writable in sandbox: fall back to inline output in response.
