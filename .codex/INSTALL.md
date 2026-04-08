# Installing codebase-analyzer for Codex

Enable codebase-analyzer skills in Codex via native skill discovery. Just clone and symlink.

## Prerequisites

- Git

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/quangphu1912/codebase-analyzer.git ~/.codex/codebase-analyzer
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/codebase-analyzer/skills ~/.agents/skills/codebase-analyzer
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
   cmd /c mklink /J "$env:USERPROFILE\.agents\skills\codebase-analyzer" "$env:USERPROFILE\.codex\codebase-analyzer\skills"
   ```

3. **Restart Codex** (quit and relaunch the CLI) to discover the skills.

## How Bootstrap Works on Codex

Codex discovers skills via the symlink at `~/.agents/skills/codebase-analyzer`. The `using-codebase-analyzer` skill loads automatically through native skill discovery -- no hook configuration needed.

The `AGENTS.md` file (symlink to CLAUDE.md) provides project-level instructions that Codex reads at session start.

## Verify

```bash
ls -la ~/.agents/skills/codebase-analyzer
```

You should see a symlink (or junction on Windows) pointing to your codebase-analyzer skills directory.

## Sandbox Mode (Codex App)

If you are running Codex in sandboxed mode (Codex App):

- **Git access:** May be in detached HEAD. Skills use `git log --all` instead of branch-specific commands.
- **File output:** `docs/analysis/` may not be writable. Skills fall back to inline output in your response.
- **Agent dispatch:** Not available. Skills run in degraded mode with simplified single-pass analysis. Output is marked as `Status: partial`.

No additional configuration needed -- skills detect constraints automatically.

## Optional: Multi-Agent Support

For `spawn_agent` support (limited agent dispatch), add to `~/.codex/config.toml`:

```toml
[features]
multi_agent = true
```

Note: Even with multi_agent enabled, codebase-analyzer's named agents (code-explorer, behavior-simulator) are not available via Codex. Skills continue in degraded mode.

## Updating

```bash
cd ~/.codex/codebase-analyzer && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/codebase-analyzer
```

Optionally delete the clone: `rm -rf ~/.codex/codebase-analyzer`.
