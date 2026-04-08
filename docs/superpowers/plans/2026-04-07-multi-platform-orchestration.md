# Multi-Platform Orchestration Implementation Plan

> **For agentic workers:** Execute tasks in order. Steps use checkbox (`- [ ]`) syntax for tracking. Each task is self-contained with complete code and verification commands.

**Goal:** Make codebase-analyzer a first-class experience on Claude Code, OpenCode, and Codex with honest degradation where full capabilities are unavailable.

**Architecture:** Single source of truth for platform capabilities (PLATFORM-NOTES.md), capability probing instead of identity detection, honest degradation instead of simulated agent dispatch, structural validation instead of qualitative testing.

**Tech Stack:** Markdown skills, bash hooks, ES module plugin (OpenCode), shell validation script

---

## File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `skills/using-codebase-analyzer/PLATFORM-NOTES.md` | Single source of truth for platform capabilities, tool mappings, degraded mode |
| Create | `scripts/validate.sh` | Structural validation for all skills, agents, hooks, plugin |
| Modify | `hooks/session-start` | Capability probing, degraded mode note for generic fallback |
| Modify | `.opencode/plugins/codebase-analyzer.js` | Fix @mention error, read tool mapping from PLATFORM-NOTES.md, degraded mode |
| Modify | `.codex/INSTALL.md` | Bootstrap explanation, sandbox mode, degraded analysis |
| Modify | `skills/using-codebase-analyzer/SKILL.md` | Platform capabilities section |
| Modify | `CLAUDE.md` | Multi-platform support section |
| Modify | `README.md` | Platform compatibility matrix |

---

### Task 1: Write the validation script (RED phase)

**Files:**
- Create: `scripts/validate.sh`

- [ ] **Step 1: Create validate.sh with all structural checks**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Structural validation for codebase-analyzer
# Usage: ./scripts/validate.sh
# All checks must pass for a healthy repo.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PASS=0
FAIL=0
WARN=0

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "  PASS: $description"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $description"
        FAIL=$((FAIL + 1))
    fi
}

warn() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "  PASS: $description"
        PASS=$((PASS + 1))
    else
        echo "  WARN: $description"
        WARN=$((WARN + 1))
    fi
}

echo "=== codebase-analyzer structural validation ==="
echo ""

# --- Platform infrastructure ---
echo "--- Platform Infrastructure ---"
check "PLATFORM-NOTES.md exists" test -f "$REPO_ROOT/skills/using-codebase-analyzer/PLATFORM-NOTES.md"
check "PLATFORM-NOTES.md has Capability Matrix" grep -q "Capability Matrix" "$REPO_ROOT/skills/using-codebase-analyzer/PLATFORM-NOTES.md"
check "PLATFORM-NOTES.md has Tool Substitution Table" grep -q "Tool Substitution" "$REPO_ROOT/skills/using-codebase-analyzer/PLATFORM-NOTES.md"
check "PLATFORM-NOTES.md has Degraded Mode" grep -q "Degraded Mode" "$REPO_ROOT/skills/using-codebase-analyzer/PLATFORM-NOTES.md"

# --- Skill frontmatter ---
echo ""
echo "--- Skill Frontmatter ---"
SKILL_COUNT=0
for skill_dir in "$REPO_ROOT"/skills/*/; do
    [[ "$(basename "$skill_dir")" == "_shared" ]] && continue
    skill_file="$skill_dir/SKILL.md"
    skill_name="$(basename "$skill_dir")"

    check "Skill $skill_name: SKILL.md exists" test -f "$skill_file"
    check "Skill $skill_name: has name field" grep -q "^name:" "$skill_file"
    check "Skill $skill_name: has description field" grep -q "^description:" "$skill_file"
    check "Skill $skill_name: description starts with 'Use when'" grep -q "^description: Use when" "$skill_file"
    SKILL_COUNT=$((SKILL_COUNT + 1))
done
echo "  (Found $SKILL_COUNT skills)"

# --- Output contracts ---
echo ""
echo "--- Output Contracts ---"
for skill_dir in "$REPO_ROOT"/skills/*/; do
    [[ "$(basename "$skill_dir")" == "_shared" ]] && continue
    skill_file="$skill_dir/SKILL.md"
    skill_name="$(basename "$skill_dir")"
    [[ "$skill_name" == "using-codebase-analyzer" ]] && continue
    check "Skill $skill_name: has Output Contract section" grep -q "## Output Contract\|## Output contract\|Write.*docs/analysis/" "$skill_file"
done

# --- Agent frontmatter ---
echo ""
echo "--- Agent Definitions ---"
for agent_file in "$REPO_ROOT"/agents/*.md; do
    agent_name="$(basename "$agent_file" .md)"
    check "Agent $agent_name: has name field" grep -q "^name:" "$agent_file"
    check "Agent $agent_name: has description field" grep -q "^description:" "$agent_file"
    check "Agent $agent_name: has tools field" grep -q "^tools:" "$agent_file"
    check "Agent $agent_name: has model field" grep -q "^model:" "$agent_file"
done

# --- Cross-references ---
echo ""
echo "--- Cross-References ---"
bootstrap="$REPO_ROOT/skills/using-codebase-analyzer/SKILL.md"
for skill_dir in "$REPO_ROOT"/skills/*/; do
    [[ "$(basename "$skill_dir")" == "_shared" ]] && continue
    [[ "$(basename "$skill_dir")" == "using-codebase-analyzer" ]] && continue
    skill_name="$(basename "$skill_dir")"
    check "Bootstrap references $skill_name" grep -q "$skill_name" "$bootstrap"
done

# --- Hook validation ---
echo ""
echo "--- Hooks ---"
check "hooks/session-start is executable" test -x "$REPO_ROOT/hooks/session-start"
check "hooks/session-start produces valid JSON (Claude Code mode)" bash -c 'CLAUDE_PLUGIN_ROOT=/tmp bash hooks/session-start 2>/dev/null | python3 -c "import sys,json; json.load(sys.stdin)"'
check "hooks/session-start produces valid JSON (generic mode)" bash -c 'bash hooks/session-start 2>/dev/null | python3 -c "import sys,json; json.load(sys.stdin)"'

# --- OpenCode plugin ---
echo ""
echo "--- OpenCode Plugin ---"
check "Plugin JS has no syntax errors" node --input-type=module -e "import('$REPO_ROOT/.opencode/plugins/codebase-analyzer.js')" 2>/dev/null
check "Plugin JS does NOT reference @mention for agent dispatch" bash -c '! grep -q "@mention" "$REPO_ROOT/.opencode/plugins/codebase-analyzer.js"'
check "Plugin JS reads from PLATFORM-NOTES.md" grep -q "PLATFORM-NOTES" "$REPO_ROOT/.opencode/plugins/codebase-analyzer.js"

# --- Version sync ---
echo ""
echo "--- Version Sync ---"
if command -v jq >/dev/null 2>&1; then
    check "Version bump script runs" bash "$REPO_ROOT/scripts/bump-version.sh" --check
else
    warn "jq not installed (skipping version sync check)" true
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed, $WARN warnings ==="
if [ "$FAIL" -gt 0 ]; then
    echo "FAILED: $FAIL checks did not pass"
    exit 1
fi
echo "ALL CHECKS PASSED"
```

- [ ] **Step 2: Make validate.sh executable**

Run: `chmod +x scripts/validate.sh`

- [ ] **Step 3: Run validate.sh to verify it fails (RED)**

Run: `bash scripts/validate.sh`
Expected: FAIL on "PLATFORM-NOTES.md exists", "Plugin JS reads from PLATFORM-NOTES.md", "Plugin JS does NOT reference @mention". These will be fixed in subsequent tasks.

- [ ] **Step 4: Commit**

```bash
git add scripts/validate.sh
git commit -m "test: add structural validation script (RED phase)"
```

---

### Task 2: Create PLATFORM-NOTES.md (GREEN phase -- platform infrastructure)

**Files:**
- Create: `skills/using-codebase-analyzer/PLATFORM-NOTES.md`

- [ ] **Step 1: Create PLATFORM-NOTES.md**

```markdown
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
```

- [ ] **Step 2: Run validate.sh to verify PLATFORM-NOTES.md checks pass**

Run: `bash scripts/validate.sh 2>&1 | grep -E "PLATFORM|Results"`
Expected: PASS for PLATFORM-NOTES.md exists, has Capability Matrix, has Tool Substitution, has Degraded Mode.

- [ ] **Step 3: Commit**

```bash
git add skills/using-codebase-analyzer/PLATFORM-NOTES.md
git commit -m "feat: add PLATFORM-NOTES.md -- single source of truth for platform capabilities"
```

---

### Task 3: Fix session-start hook (capability probing + degraded mode)

**Files:**
- Modify: `hooks/session-start` (current content at lines 1-29)

- [ ] **Step 1: Replace hooks/session-start with capability probing version**

Write the entire file with this content:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

content=$(cat "${PLUGIN_ROOT}/skills/using-codebase-analyzer/SKILL.md" 2>&1 || echo "Error reading skill")

escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

escaped=$(escape_for_json "$content")

# Degraded mode note for non-Claude Code platforms
platform_note="\\n\\n**Platform Compatibility:**\\n- Agent dispatch (code-explorer, behavior-simulator) is available ONLY on Claude Code.\\n- If you cannot dispatch agents, execute simplified single-pass analysis (max 3 trace levels).\\n- Mark output as partial: \`Status: partial | Platform: degraded (no agent dispatch)\`.\\n- See PLATFORM-NOTES.md for full capability matrix and tool substitution table."

ctx="<EXTREMELY_IMPORTANT>\\nYou have codebase analysis superpowers.\\n\\nBelow is your 'codebase-analyzer:using-codebase-analyzer' skill. For all other skills, use the Skill tool:\\n\\n${escaped}\\n</EXTREMELY_IMPORTANT>"

# Capability probing: two modes only.
# Claude Code: CLAUDE_PLUGIN_ROOT is set by the plugin runtime.
# OpenCode: does NOT use hooks (uses ESM plugin JS directly).
# Codex / future platforms: fall through to generic mode.
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    # Claude Code: nested hookSpecificOutput format
    printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$ctx"
else
    # Generic fallback: works for Codex and any unknown platform
    # Includes degraded mode note since agent dispatch is unavailable
    printf '{\n  "additionalContext": "%s%s"\n}\n' "$ctx" "$platform_note"
fi
exit 0
```

- [ ] **Step 2: Verify hook produces valid JSON in Claude Code mode**

Run: `CLAUDE_PLUGIN_ROOT=/tmp bash hooks/session-start 2>/dev/null | python3 -m json.tool | head -5`
Expected: Valid JSON starting with `{ "hookSpecificOutput": {`

- [ ] **Step 3: Verify hook produces valid JSON in generic mode with degraded note**

Run: `bash hooks/session-start 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); assert 'degraded' in d['additionalContext']; print('PASS: degraded mode note present')"`
Expected: `PASS: degraded mode note present`

- [ ] **Step 4: Commit**

```bash
git add hooks/session-start
git commit -m "fix: capability probing in session-start hook, add degraded mode note for non-Claude platforms"
```

---

### Task 4: Fix OpenCode plugin (@mention error + PLATFORM-NOTES.md source)

**Files:**
- Modify: `.opencode/plugins/codebase-analyzer.js` (current content at lines 1-105)

- [ ] **Step 1: Replace the plugin with PLATFORM-NOTES.md-reading version**

Write the entire file:

```javascript
/**
 * codebase-analyzer plugin for OpenCode.ai
 *
 * Injects bootstrap context via first user message transform.
 * Auto-registers skills directory via config hook (no symlinks needed).
 * Reads tool mapping from PLATFORM-NOTES.md (single source of truth).
 */

import path from 'path';
import fs from 'fs';
import os from 'os';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Simple frontmatter extraction
const extractAndStripFrontmatter = (content) => {
  const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { frontmatter: {}, content };

  const frontmatterStr = match[1];
  const body = match[2];
  const frontmatter = {};

  for (const line of frontmatterStr.split('\n')) {
    const colonIdx = line.indexOf(':');
    if (colonIdx > 0) {
      const key = line.slice(0, colonIdx).trim();
      const value = line.slice(colonIdx + 1).trim().replace(/^["']|["']$/g, '');
      frontmatter[key] = value;
    }
  }

  return { frontmatter, content: body };
};

// Normalize a path: trim whitespace, expand ~, resolve to absolute
const normalizePath = (p, homeDir) => {
  if (!p || typeof p !== 'string') return null;
  let normalized = p.trim();
  if (!normalized) return null;
  if (normalized.startsWith('~/')) {
    normalized = path.join(homeDir, normalized.slice(2));
  } else if (normalized === '~') {
    normalized = homeDir;
  }
  return path.resolve(normalized);
};

export const CodebaseAnalyzerPlugin = async ({ client, directory }) => {
  const homeDir = os.homedir();
  const skillsDir = path.resolve(__dirname, '../../skills');
  const envConfigDir = normalizePath(process.env.OPENCODE_CONFIG_DIR, homeDir);
  const configDir = envConfigDir || path.join(homeDir, '.config/opencode');

  const getToolMapping = () => {
    const mappingPath = path.join(skillsDir, 'using-codebase-analyzer', 'PLATFORM-NOTES.md');
    if (!fs.existsSync(mappingPath)) {
      // Fallback: minimal inline mapping if PLATFORM-NOTES.md is missing
      return `**Tool Mapping for OpenCode (fallback):**
- \`TodoWrite\` → \`todowrite\`
- \`Skill\` tool → OpenCode's native \`skill\` tool
- \`Read\`, \`Write\`, \`Edit\`, \`Bash\`, \`Glob\`, \`Grep\` → Your native tools (same names)
- \`Task\` tool (subagent) → Not available on OpenCode. Skills operate in degraded mode.
- Agent dispatch (code-explorer, behavior-simulator) → Not available. Simplified inline analysis instead.

Use OpenCode's native \`skill\` tool to list and load skills.`;
    }

    const platformNotes = fs.readFileSync(mappingPath, 'utf8');
    // Extract the OpenCode column from the Tool Substitution Table
    const tableMatch = platformNotes.match(/## Tool Substitution Table[\s\S]*?\n(\|.+\n)+/);
    const table = tableMatch ? tableMatch[0] : '';

    return `**Tool Mapping for OpenCode (from PLATFORM-NOTES.md):**

${table}

**Agent dispatch is NOT available on OpenCode.** Skills that normally dispatch agents (code-explorer, behavior-simulator) will execute simplified inline analysis instead. Output is marked as \`Status: partial\` with platform degradation note.

Use OpenCode's native \`skill\` tool to list and load skills.`;
  };

  const getBootstrapContent = () => {
    const skillPath = path.join(skillsDir, 'using-codebase-analyzer', 'SKILL.md');
    if (!fs.existsSync(skillPath)) return null;

    const fullContent = fs.readFileSync(skillPath, 'utf8');
    const { content } = extractAndStripFrontmatter(fullContent);

    const toolMapping = getToolMapping();

    return `<EXTREMELY_IMPORTANT>
You have codebase analysis superpowers.

**IMPORTANT: The using-codebase-analyzer skill content is included below. It is ALREADY LOADED - you are currently following it. Do NOT use the skill tool to load "using-codebase-analyzer" again - that would be redundant.**

${content}

${toolMapping}
</EXTREMELY_IMPORTANT>`;
  };

  return {
    // Inject skills path into live config so OpenCode discovers skills
    // without requiring manual symlinks or config file edits.
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(skillsDir)) {
        config.skills.paths.push(skillsDir);
      }
    },

    // Inject bootstrap into the first user message of each session.
    'experimental.chat.messages.transform': async (_input, output) => {
      const bootstrap = getBootstrapContent();
      if (!bootstrap || !output.messages.length) return;
      const firstUser = output.messages.find(m => m.info.role === 'user');
      if (!firstUser || !firstUser.parts.length) return;
      if (firstUser.parts.some(p => p.type === 'text' && p.text.includes('EXTREMELY_IMPORTANT'))) return;
      const ref = firstUser.parts[0];
      firstUser.parts.unshift({ ...ref, type: 'text', text: bootstrap });
    }
  };
};
```

- [ ] **Step 2: Verify plugin has no syntax errors**

Run: `node --input-type=module -e "import('./.opencode/plugins/codebase-analyzer.js')" 2>&1 || echo "SYNTAX ERROR"`
Expected: No output (no syntax error).

- [ ] **Step 3: Verify @mention reference is gone (CRITICAL fix)**

Run: `grep -n "@mention" .opencode/plugins/codebase-analyzer.js`
Expected: No output (no matches). The old incorrect `@mention` mapping is completely removed.

- [ ] **Step 4: Verify PLATFORM-NOTES.md is read**

Run: `grep -n "PLATFORM-NOTES" .opencode/plugins/codebase-analyzer.js`
Expected: At least 2 matches (the `mappingPath` variable and the fallback comment).

- [ ] **Step 5: Commit**

```bash
git add .opencode/plugins/codebase-analyzer.js
git commit -m "fix: remove incorrect @mention agent dispatch mapping, read tool mapping from PLATFORM-NOTES.md"
```

---

### Task 5: Update Codex install docs (bootstrap + sandbox + degraded)

**Files:**
- Modify: `.codex/INSTALL.md` (current content at lines 1-53)

- [ ] **Step 1: Rewrite .codex/INSTALL.md with complete content**

Write the entire file:

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add .codex/INSTALL.md
git commit -m "docs: add sandbox mode, bootstrap explanation, and degraded analysis to Codex install guide"
```

---

### Task 6: Add Platform Capabilities section to bootstrap skill

**Files:**
- Modify: `skills/using-codebase-analyzer/SKILL.md` (current content at lines 1-79)

- [ ] **Step 1: Add Platform Capabilities section after the Agent Dispatch Protocol table (after line 66)**

Insert after the line `Dispatch only when task exceeds native tool capability (5+ file reads across subsystems).` (line 66):

```markdown

**Platform Capabilities:**

Skills reference Claude Code tools and agent dispatch. On other platforms:

| Capability | Claude Code | OpenCode | Codex |
|-----------|-------------|----------|-------|
| Full Track A + Track B | Yes | Yes (degraded: no agents) | Yes (degraded: no agents) |
| Agent dispatch | Yes | No | No |
| docs/analysis/ output | Yes | Yes | May fall back to inline |

When agent dispatch is unavailable: warn user, execute simplified analysis (max 3 trace levels), mark output as `Status: partial` with degradation note.

See `PLATFORM-NOTES.md` for tool substitution table and per-platform details.
```

- [ ] **Step 2: Verify the section was added correctly**

Run: `grep -A3 "Platform Capabilities" skills/using-codebase-analyzer/SKILL.md`
Expected: Shows the table header row with Claude Code, OpenCode, Codex columns.

- [ ] **Step 3: Commit**

```bash
git add skills/using-codebase-analyzer/SKILL.md
git commit -m "feat: add platform capabilities section to bootstrap skill"
```

---

### Task 7: Update CLAUDE.md and README.md (documentation)

**Files:**
- Modify: `CLAUDE.md` (current content at lines 1-32)
- Modify: `README.md` (current content at lines 1-75)

- [ ] **Step 1: Add multi-platform section to CLAUDE.md**

Append after the `## Testing` section:

```markdown

## Multi-Platform Support
- **Claude Code**: Primary target. SessionStart hook, plugin manifests, Skill tool, full agent dispatch.
- **OpenCode**: ESM plugin at `.opencode/plugins/codebase-analyzer.js`. Config hook + message transform. No agent dispatch (degraded mode).
- **Codex**: Symlink-based skill discovery (`~/.agents/skills/`). AGENTS.md symlink. Sandbox fallback mode. No agent dispatch (degraded mode).
- **Platform capabilities**: Defined in `skills/using-codebase-analyzer/PLATFORM-NOTES.md` (single source of truth).
- **Validation**: `scripts/validate.sh` checks all skills, agents, hooks, and plugin health.
```

- [ ] **Step 2: Add platform compatibility matrix to README.md**

Insert after the `## How It Works` section (after line 70), before `## License`:

```markdown

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

```

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md README.md
git commit -m "docs: add multi-platform support section and platform compatibility matrix"
```

---

### Task 8: Run full validation (GREEN phase -- verify everything passes)

**Files:**
- No new files

- [ ] **Step 1: Run validate.sh and verify all checks pass**

Run: `bash scripts/validate.sh`
Expected: All checks PASS, zero FAIL. Some WARN for missing jq is acceptable.

- [ ] **Step 2: Verify Claude Code hook JSON**

Run: `CLAUDE_PLUGIN_ROOT=/tmp bash hooks/session-start 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); assert 'hookSpecificOutput' in d; assert 'codebase' in d['hookSpecificOutput']['additionalContext']; print('PASS: Claude Code JSON valid')"`
Expected: `PASS: Claude Code JSON valid`

- [ ] **Step 3: Verify generic hook JSON with degraded mode**

Run: `bash hooks/session-start 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); assert 'additionalContext' in d; assert 'degraded' in d['additionalContext']; assert 'PLATFORM-NOTES.md' in d['additionalContext']; print('PASS: Generic JSON valid with degraded mode')"`
Expected: `PASS: Generic JSON valid with degraded mode`

- [ ] **Step 4: Verify @mention is gone from plugin (CRITICAL fix)**

Run: `grep -c "@mention" .opencode/plugins/codebase-analyzer.js`
Expected: `0`

- [ ] **Step 5: Verify version sync**

Run: `bash scripts/bump-version.sh --check`
Expected: All 3 files show matching version `0.2.0`.

- [ ] **Step 6: Commit if any fixes were needed**

```bash
git add -A
git commit -m "fix: address validation failures from final check"
```

---

## Self-Review Checklist

### Spec Coverage
- [x] PLATFORM-NOTES.md (single source of truth) -- Task 2
- [x] Capability probing in hooks -- Task 3
- [x] Degraded mode for non-Claude platforms -- Tasks 2, 3, 4
- [x] Fix OpenCode @mention error (CRITICAL) -- Task 4
- [x] Plugin reads from PLATFORM-NOTES.md -- Task 4
- [x] Codex sandbox/degraded docs -- Task 5
- [x] Bootstrap skill platform capabilities -- Task 6
- [x] CLAUDE.md multi-platform section -- Task 7
- [x] README.md platform matrix -- Task 7
- [x] Structural validation script -- Task 1, 8

### Placeholder Scan
- No "TBD", "TODO", "implement later" -- all steps have complete code
- No "add appropriate error handling" -- validate.sh handles all paths
- No "write tests for the above" -- Task 8 is the test execution
- No "similar to Task N" -- all code is explicit

### Type Consistency
- `PLATFORM-NOTES.md` path referenced consistently across: validate.sh, session-start hook, plugin JS, SKILL.md, CLAUDE.md, README.md
- Degraded mode status string `Status: partial | Platform: degraded (no agent dispatch)` used consistently in PLATFORM-NOTES.md, session-start hook, and SKILL.md
- Agent names `code-explorer`, `behavior-simulator` consistent across all files

### Known Deferments (not in this plan)
- `.state` concurrency model (needs separate refactor)
- Output contract versioning (add `## Contract Version: 1` in future task)
- Error recovery / resume protocol for interrupted analysis
- GitHub issue/PR templates (premature for v0.2.0)
- Audit of all 20 skills for `<!-- platform-note -->` annotations (can be done incrementally)
