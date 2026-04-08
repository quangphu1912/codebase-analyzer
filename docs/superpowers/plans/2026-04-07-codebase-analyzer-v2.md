# codebase-analyzer v2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deepen codebase-analyzer from 16 shallow skills to 20 world-class skills with diagnostic reasoning, unmerge Phase 3, add trace-data-flows and detect-hidden-contracts.

**Architecture:** Two-track progressive depth. Track A (6 recon skills at Instrument depth) produces trigger signals feeding Track B (phased deep dive at Framework depth). Skills teach analytical reasoning, not grep automation. Three Depths Model: Trigger/Router (50-150w), Instrument (300-600w), Framework (600-1000w).

**Tech Stack:** Claude Code plugin (SKILL.md markdown skills, bash hooks, JSON manifests). Cross-platform: Claude Code, OpenCode, Cursor, Codex.

**Spec:** `docs/superpowers/specs/2026-04-07-codebase-analyzer-design.md`
**Plugin root:** `/Users/WangFu/GitHub/projects/codebase-analyzer/`

---

## File Structure

### New Files (7)

| File | Purpose |
|------|---------|
| `skills/extract-tool-graph/SKILL.md` | Phase 3: tool graph extraction (from split) |
| `skills/extract-tool-graph/references/tool-graph-patterns.md` | Tool registration detection patterns |
| `skills/map-feature-gates/SKILL.md` | Phase 3: gate mapping (from split) |
| `skills/map-feature-gates/references/gate-patterns.md` | Gate classification patterns (move from map-conditional-behavior) |
| `skills/simulate-behavior/SKILL.md` | Phase 3: behavioral simulation |
| `skills/trace-data-flows/SKILL.md` | Phase 2: data flow tracing with trust boundaries |
| `skills/trace-data-flows/references/data-flow-patterns.md` | Data flow detection patterns |
| `skills/detect-hidden-contracts/SKILL.md` | Special: implicit contract detection |
| `skills/reconstruct-system-intent/SKILL.md` | Phase 4: replaces synthesize-findings |
| `skills/reconstruct-system-intent/references/intent-signals.md` | System intent signals (move from synthesize-findings) |
| `skills/_shared/references/git-archaeology-techniques.md` | Shared git archaeology technique |

### Modified Files (14)

| File | Change |
|------|--------|
| `skills/using-codebase-analyzer/SKILL.md` | Add dispatch protocol, .state rules, express-lane, updated skill list |
| `skills/classify-analysis-target/SKILL.md` | Add .state creation, updated target type table |
| `skills/identifying-tech-stack/SKILL.md` | Replace lookup table with diagnostic reasoning |
| `skills/identifying-tech-stack/references/tech-stack-signatures.md` | Rewrite as analytical guide |
| `skills/mapping-architecture/SKILL.md` | Add layer violation detection, name-honesty checks |
| `skills/mapping-architecture/references/architecture-mapping-patterns.md` | Add failure modes per pattern |
| `skills/tracing-dependencies/SKILL.md` | Add direction-checking against architecture |
| `skills/detecting-dead-code/SKILL.md` | Add dead code archaeology, zombie code patterns |
| `skills/inventorying-api-surface/SKILL.md` | Add implicit entry points, API-to-data-flow mapping |
| `skills/inventorying-api-surface/references/api-surface-patterns.md` | Add implicit API detection techniques |
| `skills/analyzing-code-quality/SKILL.md` | Add quality-churn correlation, quality gradients |
| `skills/analyzing-code-quality/references/anti-pattern-catalog.md` | Replace grep commands with correlation methodology |
| `skills/trace-codebase-provenance/SKILL.md` | Add deception-awareness, intent-implementation gaps |
| `skills/trace-codebase-provenance/references/provenance-patterns.md` | Add deception detection patterns |
| `skills/analyze-build-pipeline/SKILL.md` | Add transformation chain reasoning |
| `skills/analyze-build-pipeline/references/build-pipeline-patterns.md` | Add configuration axis discovery techniques |
| `skills/classify-repo-artifacts/SKILL.md` | Add entropy analysis, naming entropy metrics |
| `skills/classify-repo-artifacts/references/artifact-classification.md` | Add entropy-based classification techniques |
| `skills/analyze-agent-loop/SKILL.md` | Add state machine decomposition methodology |
| `skills/analyze-agent-loop/references/agent-loop-patterns.md` | Add state transition detection patterns |
| `skills/analyze-prompt-influence/SKILL.md` | Add gap analysis methodology |
| `skills/analyze-prompt-influence/references/prompt-control-patterns.md` | Add prompt-code gap analysis techniques |
| `skills/test-hypothesis/SKILL.md` | Add prerequisite bypass, updated skill references |
| `agents/code-explorer.md` | Update dispatch protocol reference |
| `agents/behavior-simulator.md` | Update dispatch protocol reference |

### Deleted Files (2)

| File | Reason |
|------|--------|
| `skills/map-conditional-behavior/` (directory) | Split into extract-tool-graph + map-feature-gates |
| `skills/synthesize-findings/` (directory) | Folded into reconstruct-system-intent |

### Documentation Updates (7)

| File | Change |
|------|--------|
| `README.md` | Rewrite skill tables to 20 skills |
| `CLAUDE.md` | Update to 20 skills, three-depth model |
| `.opencode/INSTALL.md` | Update skill count to 20 |
| `CHANGELOG.md` | Add v0.2.0 entry |
| `package.json` | Bump version to 0.2.0 |
| `.claude-plugin/plugin.json` | Bump version to 0.2.0 |
| `.claude-plugin/marketplace.json` | Bump version to 0.2.0 |

---

## Phase 0: Infrastructure

### Task 1: Create shared git archaeology reference

**Files:**
- Create: `skills/_shared/references/git-archaeology-techniques.md`

- [ ] **Step 1: Create `_shared/references` directory**

Run: `mkdir -p /Users/WangFu/GitHub/projects/codebase-analyzer/skills/_shared/references`

- [ ] **Step 2: Write git-archaeology-techniques.md**

Write a Framework-depth reference (~600w) covering:
1. **Commit archaeology** — `git log --all --diff-filter=D -- '*.ts'` finds deleted files; abandoned branches reveal abandoned features; renamed files (`git log --follow`) reveal evolution of abstractions
2. **Churn correlation** — `git log --format='%H' --name-only | awk '{files[$0]++} END {for(f in files) print files[f], f}' | sort -rn | head -20` finds files that change together = hidden module boundaries
3. **Ownership archaeology** — `git shortlog -sn` reveals ownership patterns; 8 authors in 8 styles on one file = ownership ambiguity
4. **Message archaeology** — `git log --oneline --grep='fix(auth)'` reveals systemic problems from repeated fixes
5. **Temporal correlation** — files with identical commit timestamps change together = coupling not visible in imports
6. **Dead code stories** — `git log -p -- <file>` tells WHY code died: behind feature flag (upcoming), recently deleted (changed requirement), commented out (broken migration)

Each technique includes: command, what it reveals, worked example with interpretation.

- [ ] **Step 3: Verify**

Check file exists, is readable, contains all 6 techniques.

- [ ] **Step 4: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/_shared/references/git-archaeology-techniques.md
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: add shared git archaeology technique reference"
```

### Task 2: Update bootstrap skill

**Files:**
- Modify: `skills/using-codebase-analyzer/SKILL.md`

- [ ] **Step 1: Rewrite using-codebase-analyzer/SKILL.md to Trigger/Router depth**

Replace current content. New content must include:

1. **Frontmatter** (unchanged name/description)
2. **SUBAGENT-STOP** and **EXTREMELY-IMPORTANT** tags (keep)
3. **Updated skill list** — Track B Phase 2 now has 3 skills (add trace-data-flows), Phase 3 now has 4 skills (extract-tool-graph, map-feature-gates, simulate-behavior, analyze-prompt-influence), Special now has test-hypothesis + detect-hidden-contracts, remove synthesize-findings
4. **Express-lane path** — "Skip Track A, go straight to a specific Track B skill by invoking it directly. Warn that missing Track A context may produce shallower analysis."
5. **Agent dispatch protocol** — table: which skills dispatch which agents, when to dispatch (5+ file reads), input/output format
6. **`.state` rules** — "classify-analysis-target creates `.state`. Every skill appends its status. Check before Track B phases (warn-but-continue)."
7. **Confidence propagation** — "Trigger signals carry confidence. If all Track A signals are LOW, Track B may not be needed."
8. **Orchestration rules** — updated with security signals + warn-but-continue
9. **Red flags table** — keep, add: "I'll just run all skills" -> "Target type determines which phases apply. Running irrelevant skills wastes tokens."

Target: ~150 words (Trigger/Router depth). Keep terse. Decision tree, not exposition.

- [ ] **Step 2: Verify skill loads**

Read the file back. Check frontmatter has `name` and `description`. Check all 20 skills are listed. Check dispatch protocol table is present.

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/using-codebase-analyzer/SKILL.md
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: update bootstrap skill with dispatch protocol, express-lane, 20-skill listing"
```

### Task 3: Update classify-analysis-target gate

**Files:**
- Modify: `skills/classify-analysis-target/SKILL.md`

- [ ] **Step 1: Add .state creation and updated target table**

Add after HARD-GATE section:
1. **`.state` creation** — "This skill creates `docs/analysis/.state` on first run. Write initial state with target classification."
2. **Updated target type table** — Phase 2 now has 3 skills, Phase 3 now has 4 skills. Update the applicable skills columns.
3. **Security signal awareness** — "Note: all Track A skills emit SECURITY_SIGNAL. Aggregate these in Track A summary."

Keep at Trigger/Router depth (~100-150w). This is a gate, not a methodology.

- [ ] **Step 2: Verify HARD-GATE is preserved, .state creation is added**

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/classify-analysis-target/SKILL.md
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: add .state creation and updated target types to classify-analysis-target"
```

## Phase 1: Track A Deepening (6 skills)

Each skill upgraded from lookup-table style to diagnostic reasoning at Instrument depth (300-600w). Pattern for all Track A skills:

**Template per skill:**
- Frontmatter: `name`, `description` (CSO trigger-only format)
- Announce line
- Overview (1-2 sentences with analytical lens question)
- When to Use / When NOT to Use
- Diagnostic Reasoning (the core — replace Quick Reference tables with "If you see X AND Y, this reveals Z")
- SECURITY_SIGNAL guidance (what security findings this lens can produce)
- Trigger Signals (with confidence)
- Red Flags
- Output Contract (writes to `docs/analysis/` using standard contract + SECURITY_SIGNAL + TRIGGER_SIGNAL + NEGATIVE_SIGNALS)

### Task 4: Deepen identifying-tech-stack

**Files:**
- Modify: `skills/identifying-tech-stack/SKILL.md`
- Modify: `skills/identifying-tech-stack/references/tech-stack-signatures.md`

- [ ] **Step 1: Rewrite SKILL.md with diagnostic reasoning**

Replace Quick Reference lookup table with diagnostic reasoning section. Key content:

```
## Diagnostic Reasoning

1. **Read package manifests in dependency order:** Lock files first (ground truth of what's actually installed), then manifests (declared intent). Divergence = dependency drift.

2. **Check scripts before dependencies:** package.json "scripts" reveal the ACTUAL build pipeline. If "build" runs webpack but devDependencies lists vite, someone migrated partially. The declared deps lie; the scripts tell the truth.

3. **Compare dependencies vs devDependencies placement:** Business logic in devDependencies = build-time-only (code generation). Test utilities in dependencies = production monitoring/instrumentation. Misplaced deps reveal team confusion about build vs runtime.

4. **Look for overrides/resolutions:** Each override in package.json is a hidden story about a transitive dependency conflict. Count them — more than 5 indicates dependency hell.

5. **Check engine pinning:** Pinned engines ("node": "18.x") reveal deployment constraints. Absent engines with cutting-edge syntax = only runs on developer machines.

6. **Detect migration fossils:** Both webpack.config AND vite.config = migration in progress. Both .eslintrc AND eslint.config = migration stalled. Coexistence = incomplete transition.
```

Add: When NOT to Use ("When you only need to know 'is this Python or JS?' — just check file extensions"), SECURITY_SIGNAL guidance ("Outdated deps with known CVEs, private registries without auth, build tools with known supply-chain attacks").

- [ ] **Step 2: Rewrite tech-stack-signatures.md reference**

Replace lookup table with analytical guide. For each major manifest type:
- What to read FIRST (priority order)
- What divergences reveal
- Worked example with interpretation

Example:
```
## package.json Diagnostic Guide

Read in this order: scripts -> overrides/resolutions -> engines -> dependencies -> devDependencies

### Worked Example
```json
{
  "scripts": { "build": "webpack" },
  "devDependencies": { "vite": "^5.0.0", "webpack": "^5.0.0" },
  "overrides": { "nth-check": "^2.0.1" }
}
```
Interpretation: Build uses webpack but vite is installed. Migration from webpack to vite started but not completed.
The nth-check override reveals a known ReDoS vulnerability was patched at the resolution level.
```

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/identifying-tech-stack/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen identifying-tech-stack with diagnostic reasoning"
```

### Task 5: Deepen mapping-architecture

**Files:**
- Modify: `skills/mapping-architecture/SKILL.md`
- Modify: `skills/mapping-architecture/references/architecture-mapping-patterns.md`

- [ ] **Step 1: Rewrite SKILL.md**

Key additions:
1. **Layer violation detection** — "If `services/` imports from `controllers/`, the layer boundary is violated and this isn't actually layered. Map actual dependency flow, not declared structure."
2. **Name-honesty check** — "Directory names claim one thing, imports reveal another. `utils/shared` that everything imports from = hidden god module, not shared utilities."
3. **Diagnostic reasoning** — "If every module imports from a common `utils/`, you don't have a shared layer — you have a hidden god module. The import fan-in tells you more than the directory structure."
4. SECURITY_SIGNAL: "Authentication logic in presentation layer, data access without authorization checks, mixed public/private in same module"

- [ ] **Step 2: Update architecture-mapping-patterns.md**

Add failure modes per pattern:
- MVC: "Controllers >200 lines = team uses controllers as service layer (actual pattern: Transaction Script)"
- Microservices: "Shared database = distributed monolith, not microservices"
- Clean Architecture: "If domain layer imports infrastructure, dependency inversion failed"
- Monorepo: "If packages/ has cross-dependencies, it's a modular monolith, not independent packages"

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/mapping-architecture/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen mapping-architecture with layer violation detection"
```

### Task 6: Deepen tracing-dependencies

**Files:**
- Modify: `skills/tracing-dependencies/SKILL.md`
- Modify: `skills/tracing-dependencies/references/dependency-metrics.md`

- [ ] **Step 1: Rewrite SKILL.md**

Key additions:
1. **Direction-checking against architecture** — "Map dependency direction against declared architecture direction. If business logic depends on infrastructure, Dependency Inversion Principle is violated. The DIRECTION matters more than the COUNT."
2. **Dependency cluster detection** — "Modules that always appear in the same import chains form a hidden bounded context. These clusters change together and should be evaluated as a unit."
3. **Versioning conflict detection** — "Same transitive dependency at different versions across module boundaries = potential runtime inconsistency"

- [ ] **Step 2: Update dependency-metrics.md**

Expand Instability metric with worked examples. Add: direction analysis technique, cluster detection via co-occurrence, versioning conflict detection commands.

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/tracing-dependencies/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen tracing-dependencies with direction-checking and cluster detection"
```

### Task 7: Deepen detecting-dead-code

**Files:**
- Modify: `skills/detecting-dead-code/SKILL.md`

- [ ] **Step 1: Rewrite SKILL.md**

Key additions:
1. **Dead code archaeology** — "Why did this code die? Use `git log -p -- <file>` to determine: behind feature flag = upcoming (not dead), recently deleted = changed requirement, commented out = broken migration, conditionally excluded = configuration-dependent (may be alive in other builds)"
2. **Zombie code detection** — "Code that appears dead but is loaded via reflection, plugin systems, or string-based dynamic imports. Search for: `require(variable)`, `import(variable)`, `Reflect.get`, plugin registries that load by name, framework auto-discovery patterns."
3. **Reference to git-archaeology-techniques.md** — "For detailed git archaeology commands, see `_shared/references/git-archaeology-techniques.md`"
4. SECURITY_SIGNAL: "Dead auth checks may indicate removed security, dead data validation may indicate intentional bypass"

No reference file changes needed — this skill now points to shared git archaeology reference.

- [ ] **Step 2: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/detecting-dead-code/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen detecting-dead-code with archaeology and zombie detection"
```

### Task 8: Deepen inventorying-api-surface

**Files:**
- Modify: `skills/inventorying-api-surface/SKILL.md`
- Modify: `skills/inventorying-api-surface/references/api-surface-patterns.md`

- [ ] **Step 1: Rewrite SKILL.md**

Key additions:
1. **Scope clarification** — "This skill finds implicit ENTRY POINTS (how you get in). For implicit BEHAVIORAL ASSUMPTIONS (how code expects to be used), use `detect-hidden-contracts`."
2. **API-to-data-flow mapping** — "Every endpoint should be traceable to a data mutation or query. Endpoints that don't touch data are either proxies, health checks, or dead endpoints. Chain detection: if endpoint A's response shape matches endpoint B's request body, they're designed to be chained."
3. **Implicit entry points** — "Not just HTTP: IPC channels, WebSocket message types, CLI argument schemas, environment variable contracts, plugin hooks. The implicit API is often larger than the explicit one."
4. SECURITY_SIGNAL: "Undocumented endpoints, admin routes without auth, API versions that expose more than documented"

- [ ] **Step 2: Update api-surface-patterns.md**

Add: implicit API detection techniques (IPC, env vars, CLI, WebSocket), API chaining detection, implicit entry point patterns.

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/inventorying-api-surface/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen inventorying-api-surface with implicit entry points and API chaining"
```

### Task 9: Deepen analyzing-code-quality

**Files:**
- Modify: `skills/analyzing-code-quality/SKILL.md`
- Modify: `skills/analyzing-code-quality/references/anti-pattern-catalog.md`

- [ ] **Step 1: Rewrite SKILL.md**

Key additions:
1. **Quality-churn correlation** — "A file that changes frequently AND has high complexity is a bug factory. A file that changes frequently but is simple is just a configuration hub. The CORRELATION is the insight, not the individual metrics. Use `git log --format='%H' --name-only` to find high-churn files, then cross-reference with complexity."
2. **Quality gradients** — "Code quality degrades from edges inward. Entry points and API handlers are polished. Internal services and data access layers accumulate debt. Check the gradient to find where debt hides."
3. **Reference to git-archaeology-techniques.md** for churn analysis commands.
4. SECURITY_SIGNAL: "High churn in auth/security files = unstable security posture, complexity in data handling = injection risk"

- [ ] **Step 2: Update anti-pattern-catalog.md**

Replace grep commands with correlation methodology. Add: churn-complexity matrix, quality gradient detection, worked examples.

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/analyzing-code-quality/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen analyzing-code-quality with churn correlation and quality gradients"
```

## Phase 2: Track B Deepening + New Skills

### Task 10: Deepen trace-codebase-provenance

**Files:**
- Modify: `skills/trace-codebase-provenance/SKILL.md`
- Modify: `skills/trace-codebase-provenance/references/provenance-patterns.md`

- [ ] **Step 1: Rewrite SKILL.md at Framework depth**

Key additions:
1. **Deception awareness** — "Assume the codebase may be trying to hide things. Look for: deliberately misleading variable names, code structured to look like one thing but do another, comments describing intent that doesn't match implementation, obfuscated strings, encoded URLs."
2. **Intent-implementation gap** — "Comments say 'validates user input' but the function only trims whitespace. Function named `sanitize` that passes data through unchanged. The gap between stated purpose and actual behavior is where the truth lives."
3. **Iron Law:** "Never confuse sourcemap with source, build output with source, decompiled code with original code."
4. **Rationalization table** — add rows for "looks like original source" shortcut
5. SECURITY_SIGNAL: "Decompiled code masquerading as original, obfuscated sections, hidden API endpoints in strings"

- [ ] **Step 2: Update provenance-patterns.md**

Add: deception detection patterns (misleading names, intent-implementation gaps), obfuscation indicators, decompiled code signatures.

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/trace-codebase-provenance/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen trace-codebase-provenance with deception awareness"
```

### Task 11: Deepen analyze-build-pipeline

**Files:**
- Modify: `skills/analyze-build-pipeline/SKILL.md`
- Modify: `skills/analyze-build-pipeline/references/build-pipeline-patterns.md`

- [ ] **Step 1: Rewrite SKILL.md at Framework depth**

Key additions:
1. **Transformation chain reasoning** — "Map the full chain: source -> preprocessor -> compiler -> bundler -> optimizer -> minifier -> output. At each stage: what's added? what's removed? what's transformed? The chain reveals what the final artifact went through."
2. **Configuration axis discovery** — "Every build has axes: ENVIRONMENT, USER_TYPE, PROVIDER, FEATURE_FLAGS. Document each axis and its values. This is the Build Dimension Catalogue that downstream skills depend on."
3. **Iron Law:** "Every analyzed build is one filtered slice. You are never seeing the full capability surface."

- [ ] **Step 2: Update build-pipeline-patterns.md**

Add: transformation chain detection per tool (webpack/vite/esbuild/rollup), configuration axis extraction techniques, build-time code injection patterns.

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/analyze-build-pipeline/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen analyze-build-pipeline with transformation chain reasoning"
```

### Task 12: Deepen classify-repo-artifacts

**Files:**
- Modify: `skills/classify-repo-artifacts/SKILL.md`
- Modify: `skills/classify-repo-artifacts/references/artifact-classification.md`

- [ ] **Step 1: Rewrite SKILL.md at Framework depth**

Key additions:
1. **Entropy analysis** — "Files with abnormally high information density (many distinct operations per line) are either highly optimized or obfuscated. Files with abnormally low density are scaffolding or generated. This is a signal, not a verdict."
2. **Naming entropy** — "Modules with many unique identifiers = business-logic-dense. Modules with repetitive naming (same prefixes everywhere) = boilerplate or generated. The naming pattern reveals the module's nature."
3. **Tautology elimination** — Don't classify as "domain-specific logic" without explaining HOW to identify domain without prior knowledge. Instead: "domain logic = code that uses business vocabulary from the project's naming, not generic CS terms."

- [ ] **Step 2: Update artifact-classification.md**

Add: entropy-based classification techniques, naming entropy metrics, worked examples.

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/classify-repo-artifacts/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen classify-repo-artifacts with entropy analysis"
```

### Task 13: Create trace-data-flows (NEW)

**Files:**
- Create: `skills/trace-data-flows/SKILL.md`
- Create: `skills/trace-data-flows/references/data-flow-patterns.md`

- [ ] **Step 1: Create directory**

Run: `mkdir -p /Users/WangFu/GitHub/projects/codebase-analyzer/skills/trace-data-flows/references`

- [ ] **Step 2: Write SKILL.md at Framework depth (~700w)**

Frontmatter:
```yaml
---
name: trace-data-flows
description: Use when tracking how data enters, transforms, persists, and exits a system, or when investigating trust boundaries, validation gaps, and potential data exfiltration paths
---
```

Content structure:
1. **Announce line**
2. **Overview** — "Follow the data, not the code. Code shows structure; data shows behavior. Where does untrusted data enter? Where is it validated? Where does it influence control flow? Where does it persist? Where does it exit?"
3. **Prerequisite** — Reads `docs/analysis/tech-stack.md`, `docs/analysis/build-pipeline.md`
4. **Five-stage data flow trace:**
   - **Entry** — Where does external data enter? (HTTP params, file uploads, env vars, IPC, database reads, API responses)
   - **Validation** — Where is data checked? (If at all. Gaps = injection risk.)
   - **Control flow** — Where does data influence what code runs? (This is where injection lives.)
   - **Persistence** — Where is data stored? What schema enforces shape?
   - **Exit** — Where does data leave for external systems? (Logging, metrics, error messages, API responses = data leakage risk.)
5. **Trust boundary mapping** — At each transformation point: "Is the trust level changing? Is untrusted data now being trusted?"
6. **Side-channel data** — "Logging statements that include user data. Error messages that expose internal state. Metrics that reveal behavioral patterns. These are data flows too."
7. **Dispatch rule** — "If a data flow spans 5+ files across different subsystems, dispatch `code-explorer` agent to trace the full chain."
8. SECURITY_SIGNAL section (this skill IS a security skill — all findings are security-relevant)
9. Red flags
10. Output Contract

- [ ] **Step 3: Write data-flow-patterns.md reference**

Cover: data entry point patterns per framework, validation gap detection commands, trust boundary markers, side-channel data in logging/metrics frameworks, data exfiltration pattern catalog.

- [ ] **Step 4: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/trace-data-flows/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: add trace-data-flows skill (data flow tracing with trust boundaries)"
```

### Task 14: Deepen analyze-agent-loop

**Files:**
- Modify: `skills/analyze-agent-loop/SKILL.md`
- Modify: `skills/analyze-agent-loop/references/agent-loop-patterns.md`

- [ ] **Step 1: Rewrite SKILL.md at Framework depth**

Key additions:
1. **State machine decomposition** — "Break the agent loop into states: IDLE -> RECEIVING -> PROCESSING -> TOOL_CALL -> WAITING -> RESPONDING -> IDLE. Map transitions between states and what triggers each."
2. **Turn loop tracing** — "Count turns, map tool continuations, identify state transitions. How many turns before the loop terminates? What conditions cause termination? What causes infinite loops?"
3. **Iron Law:** "Prompt != behavior. The prompt says what to do; the code determines what CAN be done. Map both separately."

- [ ] **Step 2: Update agent-loop-patterns.md**

Add: state machine decomposition techniques, turn loop tracing patterns, termination condition analysis.

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/analyze-agent-loop/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen analyze-agent-loop with state machine decomposition"
```

## Phase 3: Phase 3 Unmerge + Phase 4 + Special Skills

### Task 15: Split map-conditional-behavior into extract-tool-graph

**Files:**
- Create: `skills/extract-tool-graph/SKILL.md`
- Create: `skills/extract-tool-graph/references/tool-graph-patterns.md`

- [ ] **Step 1: Create directory**

Run: `mkdir -p /Users/WangFu/GitHub/projects/codebase-analyzer/skills/extract-tool-graph/references`

- [ ] **Step 2: Write SKILL.md at Framework depth (~700w)**

Extract the "Pass 1: Tool Graph" section from current `map-conditional-behavior/SKILL.md` and expand into full skill.

Frontmatter:
```yaml
---
name: extract-tool-graph
description: Use when investigating conditional tool availability, finding tools that exist but are hidden behind gates, or mapping the full capability surface of a system
---
```

Content structure:
1. **Announce line**
2. **Overview** — "Map ALL tools/capabilities that exist in the codebase, including those conditionally excluded. The tool graph reveals what the system CAN do, even if it doesn't currently expose it."
3. **Prerequisite** — Reads `docs/analysis/agent-loop.md` and `docs/analysis/build-pipeline.md`
4. **Process:**
   - Find all tool definitions (function handlers, API endpoints, CLI commands, plugin hooks)
   - Map tool registry: how tools are registered and discovered
   - Identify conditional registration: tools defined but only registered under certain conditions
   - Find dynamic tool registration: tools loaded from config, database, or external sources
   - Map tool parameters, constraints, and side effects
5. **Dispatch rule** — "If tool graph spans 5+ files, dispatch `code-explorer` to trace registration chains"
6. **Cross-gate-tool matrix** — "Produce as output format: rows = tools, columns = gate types, cells = available (Y/N/conditional)"
7. **Red flags** — "Only finding registered tools, missing defined-but-excluded tools"
8. Output Contract

- [ ] **Step 3: Write tool-graph-patterns.md reference**

Cover: tool registration patterns per framework, conditional registration detection, dynamic loading patterns, plugin hook discovery.

- [ ] **Step 4: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/extract-tool-graph/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: add extract-tool-graph skill (from map-conditional-behavior split)"
```

### Task 16: Create map-feature-gates (from split)

**Files:**
- Create: `skills/map-feature-gates/SKILL.md`
- Move: `skills/map-conditional-behavior/references/gate-patterns.md` -> `skills/map-feature-gates/references/gate-patterns.md`

- [ ] **Step 1: Create directory**

Run: `mkdir -p /Users/WangFu/GitHub/projects/codebase-analyzer/skills/map-feature-gates/references`

- [ ] **Step 2: Copy gate-patterns.md reference**

Run: `cp /Users/WangFu/GitHub/projects/codebase-analyzer/skills/map-conditional-behavior/references/gate-patterns.md /Users/WangFu/GitHub/projects/codebase-analyzer/skills/map-feature-gates/references/gate-patterns.md`

- [ ] **Step 3: Write SKILL.md at Framework depth (~700w)**

Extract the "Pass 2: Gate Mapping" section from current `map-conditional-behavior/SKILL.md` and expand.

Frontmatter:
```yaml
---
name: map-feature-gates
description: Use when you need to understand why capabilities differ across configurations, user types, or deployment environments, or when investigating feature flags and capability gates
---
```

Content structure:
1. **Announce line**
2. **Overview** — "Map the gates that control which capabilities are available under which conditions. Gates are the control plane of the system — understanding them reveals what the system was designed to restrict and to whom."
3. **Prerequisite** — Reads `docs/analysis/conditional-behavior.md` (tool graph from extract-tool-graph) and `docs/analysis/build-pipeline.md`
4. **Five gate types with detection:**
   - **Build-time gates** — tools filtered during compilation (#ifdef, process.env checks in build scripts)
   - **Runtime gates** — tools enabled/disabled based on runtime state (config reads, feature flags)
   - **Permission gates** — tools restricted by role/permission level (auth checks)
   - **Provider gates** — tools available only for specific backends (provider === 'openai')
   - **Config gates** — tools controlled by environment variables, settings files
5. **Hidden capability detection** — "Tools that are defined but never registered in any gate configuration = dead, hidden, or upcoming. Cross-reference with dead-code analysis."
6. **Red flags**
7. Output Contract

- [ ] **Step 4: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/map-feature-gates/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: add map-feature-gates skill (from map-conditional-behavior split)"
```

### Task 17: Create simulate-behavior

**Files:**
- Create: `skills/simulate-behavior/SKILL.md`

- [ ] **Step 1: Create directory**

Run: `mkdir -p /Users/WangFu/GitHub/projects/codebase-analyzer/skills/simulate-behavior`

- [ ] **Step 2: Write SKILL.md at Framework depth (~700w)**

Frontmatter:
```yaml
---
name: simulate-behavior
description: Use when predicting how a system behaves under different conditions, testing "what if" scenarios for gate combinations, or comparing behavioral fingerprints across configurations
---
```

Content structure:
1. **Announce line**
2. **Overview** — "Given a tool graph and gate map, predict behavior under different gate combinations. This is where analysis becomes prediction: you're not just mapping what exists, you're simulating what WOULD happen."
3. **Prerequisites** — Reads `docs/analysis/conditional-behavior.md` (tool graph) and `docs/analysis/gate-map.md` (gates). Requires both Phase 3 prior skills complete.
4. **Behavioral fingerprinting** — "For each gate combination, produce a behavioral fingerprint: available tools, active code paths, accessible data, exposed capabilities. Compare fingerprints to find surprising differences."
5. **Temporal analysis** — "How does behavior change over time? Feature flags that are on in dev but off in prod. Capabilities that are scheduled for removal."
6. **State-space exploration** — "Enumerate gate combinations systematically. For N binary gates, there are 2^N possible states. Prioritize: most likely states (production config), most surprising states (admin + external), most different from baseline."
7. **Dispatch rule** — "Dispatch `behavior-simulator` agent with gate map + scenarios. Agent traces code paths per scenario."
8. **Red flags**
9. Output Contract — writes `docs/analysis/behavior-simulation.md` with scenario comparisons

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/simulate-behavior/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: add simulate-behavior skill (behavioral prediction under gate combinations)"
```

### Task 18: Deepen analyze-prompt-influence

**Files:**
- Modify: `skills/analyze-prompt-influence/SKILL.md`
- Modify: `skills/analyze-prompt-influence/references/prompt-control-patterns.md`

- [ ] **Step 1: Rewrite SKILL.md at Framework depth**

Key additions:
1. **Gap analysis methodology** — "For each behavior dimension: (1) what does the prompt SAY to do? (2) what does the code ENFORCE? (3) what's the gap? The gap is where the real control architecture lives."
2. **Expanded comparison** — Tool usage, response style, safety, capabilities, data access, error handling — for each, map prompt vs code control
3. **"Brilliant secret" framing** — "Prompt is not behavior. A system prompt saying 'don't do X' is a suggestion. Code removing tool X is enforcement. The gap between them reveals where control really lives."

- [ ] **Step 2: Update prompt-control-patterns.md**

Add: gap analysis techniques, prompt-code comparison patterns, worked examples of prompt-code gaps.

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/analyze-prompt-influence/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen analyze-prompt-influence with gap analysis methodology"
```

### Task 19: Create reconstruct-system-intent (replaces synthesize-findings)

**Files:**
- Create: `skills/reconstruct-system-intent/SKILL.md`
- Create: `skills/reconstruct-system-intent/references/intent-signals.md`

- [ ] **Step 1: Create directory**

Run: `mkdir -p /Users/WangFu/GitHub/projects/codebase-analyzer/skills/reconstruct-system-intent/references`

- [ ] **Step 2: Write SKILL.md at Framework depth (~800w)**

Frontmatter:
```yaml
---
name: reconstruct-system-intent
description: Use when you need to understand what a system was truly designed to become, where its real moat lies, or to produce a comprehensive analysis report combining all prior findings
---
```

Content structure:
1. **Announce line**
2. **Overview** — "What was this system designed to become? Not what it claims to do, but what the architecture, gates, and hidden capabilities reveal about its true purpose. The real moat is rarely in the client binary — it's in the service/backend layer."
3. **Prerequisite** — Reads ALL completed analysis files from `docs/analysis/`. This is the terminal skill.
4. **Five intent questions:**
   - What is this system designed to become? (from architecture + capabilities + evolution)
   - Where is the moat? (from gate analysis — client vs service vs ecosystem)
   - What can it do that it doesn't expose? (from conditional-behavior + dead-code)
   - How is behavior really controlled? (from prompt-influence + gates)
   - What are the hidden dependencies? (from provenance + build-pipeline)
5. **Synthesis output** (replaces synthesize-findings):
   - Executive Summary
   - Track A findings summary with refactoring recommendations
   - Track B findings summary with threat model
   - System intent narrative (the 5 questions answered)
   - Confidence-weighted evidence map
   - Priority actions
6. **Reference to git-archaeology-techniques.md** for evolution evidence
7. **Iron Law:** "Moat location: never assume the interesting behavior is in the client. Check the service layer first."
8. Output Contract — writes `docs/analysis/analysis-report-[YYYY-MM-DD].md`

- [ ] **Step 3: Write intent-signals.md reference**

Cover: intent signal patterns (abandoned features reveal planned direction, gate complexity reveals competitive sensitivity, hidden APIs reveal integration strategy), moat detection heuristics, confidence weighting for evidence.

- [ ] **Step 4: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/reconstruct-system-intent/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: add reconstruct-system-intent skill (replaces synthesize-findings)"
```

### Task 20: Deepen test-hypothesis

**Files:**
- Modify: `skills/test-hypothesis/SKILL.md`

- [ ] **Step 1: Rewrite SKILL.md at Instrument depth**

Key additions:
1. **Prerequisite bypass** — "This skill carries its own prerequisite resolution. It can invoke ANY skill (Track A or Track B) regardless of normal phase prerequisites. Trade-off: invoking Track B without Phase 1 produces shallower analysis, but still produces a valid verdict. Check `.state` and note which prerequisites were unavailable."
2. **Updated skill references** — Example hypotheses table: replace `conditional-behavior` with `extract-tool-graph + map-feature-gates`, add `trace-data-flows` for data exfiltration hypotheses, add `detect-hidden-contracts` for assumption-testing hypotheses.
3. **Evidence quality tiers** — "CONFIRMED requires file:line evidence. INCONCLUSIVE means you checked but couldn't access. DENIED requires both absence of evidence AND evidence of absence."

- [ ] **Step 2: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/test-hypothesis/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: deepen test-hypothesis with prerequisite bypass and updated skill references"
```

### Task 21: Create detect-hidden-contracts (NEW)

**Files:**
- Create: `skills/detect-hidden-contracts/SKILL.md`

- [ ] **Step 1: Create directory**

Run: `mkdir -p /Users/WangFu/GitHub/projects/codebase-analyzer/skills/detect-hidden-contracts`

- [ ] **Step 2: Write SKILL.md at Instrument depth (~400-500w)**

Frontmatter:
```yaml
---
name: detect-hidden-contracts
description: Use when investigating implicit assumptions in code — ordering dependencies, unvalidated environment variables, assumed object shapes, or temporal state requirements that aren't enforced by types or tests
---
```

Content structure:
1. **Announce line**
2. **Overview** — "Find implicit contracts not documented in types, interfaces, or API schemas. These are the assumptions that code makes but never states — where real bugs and hidden behaviors live."
3. **Boundary with inventorying-api-surface** — "API surface finds implicit ENTRY POINTS (how you get in). This skill finds implicit BEHAVIORAL ASSUMPTIONS (what the code assumes about how it's used)."
4. **Five contract types with detection:**
   - **Environment variable contracts** — `process.env.X` used without validation/default. Search: `process.env.` without `||` or `??` or `if (!process.env.X)`. Pattern: "code assumes ENV vars exist — what breaks when they don't?"
   - **Ordering contracts** — Function A must be called before function B but nothing enforces it. Search: shared mutable state, global variables set in one function and read in another. Pattern: "what if B is called before A?"
   - **Shape contracts** — Code accesses `obj.field.subfield` without null checks. Search: chained property access without optional chaining (`?.`). Pattern: "what shape does this code assume?"
   - **Temporal contracts** — Code assumes certain state exists at certain times. Search: state flags, booleans that gate behavior, `initialized` patterns. Pattern: "what if this runs at the wrong time?"
   - **Error contracts** — Code catches specific error types but throwers may throw differently. Search: `catch (e)` vs `catch (SpecificError)`, generic re-throws. Pattern: "what errors does this code expect vs what actually gets thrown?"
5. **Red flags**
6. Output Contract

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add skills/detect-hidden-contracts/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: add detect-hidden-contracts skill (implicit contract detection)"
```

## Phase 4: Cleanup, Agents, Documentation

### Task 22: Remove old skills

**Files:**
- Delete: `skills/map-conditional-behavior/` (directory)
- Delete: `skills/synthesize-findings/` (directory)

- [ ] **Step 1: Verify replacement skills exist**

Run: `ls /Users/WangFu/GitHub/projects/codebase-analyzer/skills/extract-tool-graph/SKILL.md /Users/WangFu/GitHub/projects/codebase-analyzer/skills/map-feature-gates/SKILL.md /Users/WangFu/GitHub/projects/codebase-analyzer/skills/reconstruct-system-intent/SKILL.md`

Expected: All three files exist.

- [ ] **Step 2: Remove old directories**

Run: `rm -rf /Users/WangFu/GitHub/projects/codebase-analyzer/skills/map-conditional-behavior /Users/WangFu/GitHub/projects/codebase-analyzer/skills/synthesize-findings`

- [ ] **Step 3: Verify skill count**

Run: `ls -d /Users/WangFu/GitHub/projects/codebase-analyzer/skills/*/ | wc -l`

Expected: 20 (plus `_shared` directory = 21 entries)

- [ ] **Step 4: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add -A skills/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "refactor: remove map-conditional-behavior and synthesize-findings (replaced by new skills)"
```

### Task 23: Update agents

**Files:**
- Modify: `agents/code-explorer.md`
- Modify: `agents/behavior-simulator.md`

- [ ] **Step 1: Update code-explorer.md**

Add dispatch protocol reference to the agent's "Rules" section:
```
- You may be dispatched by: extract-tool-graph, trace-codebase-provenance, test-hypothesis
- Your parent skill will read your findings from docs/analysis/
```

Update `description` frontmatter to mention dispatch protocol awareness.

- [ ] **Step 2: Update behavior-simulator.md**

Add dispatch protocol reference:
```
- You may be dispatched by: simulate-behavior, test-hypothesis
- Your parent skill will provide a gate map and scenario list
```

Update `description` frontmatter. Update output format to reference the gate map source skill names (extract-tool-graph, map-feature-gates) instead of old `map-conditional-behavior`.

- [ ] **Step 3: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add agents/
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "feat: update agents with dispatch protocol references"
```

### Task 24: Update documentation and version bump

**Files:**
- Modify: `README.md`
- Modify: `CLAUDE.md`
- Modify: `.opencode/INSTALL.md`
- Modify: `CHANGELOG.md`
- Modify: `package.json`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Update README.md**

Rewrite skill tables:
- Track A: unchanged (6 skills)
- Track B Phase 1: unchanged (2 skills)
- Track B Phase 2: add `trace-data-flows`
- Track B Phase 3: replace `map-conditional-behavior` + `analyze-prompt-influence` with 4 skills: `extract-tool-graph`, `map-feature-gates`, `simulate-behavior`, `analyze-prompt-influence`
- Phase 4: replace `synthesize-findings` reference with `reconstruct-system-intent`
- Special: add `detect-hidden-contracts`
- Total: 20 skills

- [ ] **Step 2: Update CLAUDE.md**

- Change "14 skills + 2 agents" to "20 skills + 2 agents"
- Replace word budgets with Three Depths Model:
  ```
  - Trigger/Router depth: 50-150w (bootstrap, gate)
  - Instrument depth: 300-600w (Track A, special skills)
  - Framework depth: 600-1000w (Track B, synthesis)
  ```
- Add: "Core principle: diagnostic reasoning over lookup tables"

- [ ] **Step 3: Update .opencode/INSTALL.md**

Change "16 analysis skills" to "20 analysis skills".

- [ ] **Step 4: Add CHANGELOG.md entry**

Read existing CHANGELOG.md first. Add v0.2.0 entry:
```markdown
## v0.2.0 (2026-04-07)

### Breaking Changes
- `map-conditional-behavior` split into `extract-tool-graph` + `map-feature-gates`
- `synthesize-findings` replaced by `reconstruct-system-intent`

### New Skills
- `trace-data-flows` — data flow tracing with trust boundaries
- `detect-hidden-contracts` — implicit contract detection
- `extract-tool-graph` — tool graph extraction (from split)
- `map-feature-gates` — gate mapping (from split)
- `simulate-behavior` — behavioral simulation under gate combinations
- `reconstruct-system-intent` — system intent reconstruction + synthesis

### Improvements
- All skills upgraded to diagnostic reasoning (replaces lookup tables)
- Three Depths Model (Trigger/Router, Instrument, Framework)
- Agent dispatch protocol for code-explorer and behavior-simulator
- Security signals emitted by all skills (cross-cutting concern)
- Shared git archaeology technique reference
- Warn-but-continue prerequisites
```

- [ ] **Step 5: Bump versions in package.json, plugin.json, marketplace.json**

Change `"version": "0.1.0"` to `"version": "0.2.0"` in all three files.

- [ ] **Step 6: Verify all JSON files parse**

Run: `for f in package.json .claude-plugin/plugin.json .claude-plugin/marketplace.json; do python3 -c "import json; json.load(open('/Users/WangFu/GitHub/projects/codebase-analyzer/$f'))" && echo "$f: OK"; done`

- [ ] **Step 7: Commit**

```bash
git -C /Users/WangFu/GitHub/projects/codebase-analyzer add README.md CLAUDE.md .opencode/INSTALL.md CHANGELOG.md package.json .claude-plugin/plugin.json .claude-plugin/marketplace.json
git -C /Users/WangFu/GitHub/projects/codebase-analyzer commit -m "docs: update all documentation for v0.2.0 (20 skills, three-depth model)"
```

### Task 25: Final validation

- [ ] **Step 1: Count skills**

Run: `ls -d /Users/WangFu/GitHub/projects/codebase-analyzer/skills/*/SKILL.md | wc -l`

Expected: 20

- [ ] **Step 2: Verify no references to removed skills**

Run: `grep -r 'map-conditional-behavior\|synthesize-findings' /Users/WangFu/GitHub/projects/codebase-analyzer/skills/ --include='*.md' || echo "Clean: no references to removed skills"`

Expected: "Clean" (no references to removed skill names)

- [ ] **Step 3: Verify all skill frontmatter**

Run: `for f in /Users/WangFu/GitHub/projects/codebase-analyzer/skills/*/SKILL.md; do name=$(head -5 "$f" | grep 'name:' | sed 's/name: //'); desc=$(head -5 "$f" | grep 'description:'); echo "$name: ${desc:0:60}..."; done`

Expected: 20 skills listed, each with a CSO-format description starting with "Use when..."

- [ ] **Step 4: Verify version consistency**

Run: `grep -h '"version"' /Users/WangFu/GitHub/projects/codebase-analyzer/package.json /Users/WangFu/GitHub/projects/codebase-analyzer/.claude-plugin/plugin.json /Users/WangFu/GitHub/projects/codebase-analyzer/.claude-plugin/marketplace.json`

Expected: All three show "0.2.0"

---

## Task Summary

| # | Task | Phase | Type |
|---|------|-------|------|
| 1 | Create shared git archaeology reference | Infrastructure | Create |
| 2 | Update bootstrap skill | Infrastructure | Modify |
| 3 | Update classify-analysis-target gate | Infrastructure | Modify |
| 4 | Deepen identifying-tech-stack | Track A | Modify |
| 5 | Deepen mapping-architecture | Track A | Modify |
| 6 | Deepen tracing-dependencies | Track A | Modify |
| 7 | Deepen detecting-dead-code | Track A | Modify |
| 8 | Deepen inventorying-api-surface | Track A | Modify |
| 9 | Deepen analyzing-code-quality | Track A | Modify |
| 10 | Deepen trace-codebase-provenance | Track B P1 | Modify |
| 11 | Deepen analyze-build-pipeline | Track B P1 | Modify |
| 12 | Deepen classify-repo-artifacts | Track B P2 | Modify |
| 13 | Create trace-data-flows | Track B P2 | Create |
| 14 | Deepen analyze-agent-loop | Track B P2 | Modify |
| 15 | Create extract-tool-graph (from split) | Track B P3 | Create |
| 16 | Create map-feature-gates (from split) | Track B P3 | Create |
| 17 | Create simulate-behavior | Track B P3 | Create |
| 18 | Deepen analyze-prompt-influence | Track B P3 | Modify |
| 19 | Create reconstruct-system-intent | Phase 4 | Create |
| 20 | Deepen test-hypothesis | Special | Modify |
| 21 | Create detect-hidden-contracts | Special | Create |
| 22 | Remove old skills | Cleanup | Delete |
| 23 | Update agents | Cleanup | Modify |
| 24 | Update documentation + version bump | Docs | Modify |
| 25 | Final validation | Validation | Verify |

**25 tasks total.** Estimated commits: ~25 (one per task).
