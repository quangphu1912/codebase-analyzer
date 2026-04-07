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

## Verify

```bash
ls -la ~/.agents/skills/codebase-analyzer
```

You should see a symlink (or junction on Windows) pointing to your codebase-analyzer skills directory.

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
