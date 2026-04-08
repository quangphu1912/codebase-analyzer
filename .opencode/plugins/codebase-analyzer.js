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
