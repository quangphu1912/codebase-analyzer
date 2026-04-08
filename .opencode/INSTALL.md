# Installing codebase-analyzer for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed

## Installation

Add codebase-analyzer to the `plugin` array in your `opencode.json` (global or project-level):

```json
{
  "plugin": ["codebase-analyzer@git+https://github.com/quangphu1912/codebase-analyzer.git"]
}
```

Restart OpenCode. The plugin auto-installs and registers all 32 skills (20 analysis + 12 orchestration).

Verify by asking: "Analyze this codebase" or "What analysis skills do you have?"

## Usage

Use OpenCode's native `skill` tool:

```
use skill tool to list skills
use skill tool to load codebase-analyzer/classify-analysis-target
```

## Updating

codebase-analyzer updates automatically when you restart OpenCode.

To pin a specific version:
```json
{
  "plugin": ["codebase-analyzer@git+https://github.com/quangphu1912/codebase-analyzer.git#v0.2.0"]
}
```

## Troubleshooting

### Plugin not loading

1. Check logs: `opencode run --print-logs "hello" 2>&1 | grep -i codebase`
2. Verify the plugin line in your `opencode.json`
3. Make sure you're running a recent version of OpenCode

### Skills not found

1. Use `skill` tool to list what's discovered
2. Check that the plugin is loading (see above)
