# codebase-analyzer Plugin Design Spec v2

## Overview

A Claude Code plugin for progressive-depth codebase analysis and reverse engineering. Inspired by Uncle Dao's Reverse Engineering Suite v1 — a 4-phase methodology analyzing codebases from file -> architecture -> runtime -> control -> behavior -> intent.

**Core principle:** Skills must teach analytical reasoning, not automate grep. Every skill changes how you SEE a codebase, not just what you find.

## Revised Architecture (20 skills + 2 agents)

### Bootstrap + Gate (2 skills)

**`using-codebase-analyzer`** — SessionStart-injected, Trigger/Router depth (50-150w). Contains:
- `<EXTREMELY-IMPORTANT>` behavioral override for skill discovery
- `<SUBAGENT-STOP>` tag for dispatched subagents
- DOT flowchart for skill routing decisions
- Express-lane path (skip Track A, go straight to specific Track B skill)
- Confidence propagation rules (not hard phase gates)
- Warn-but-continue prerequisites

**`classify-analysis-target`** — First skill invoked, Trigger/Router depth. Hard gate.
- `<HARD-GATE>`: NO TRACK A SKILLS WITHOUT TARGET CLASSIFICATION FIRST
- Fail-fast decision tree for obfuscated/minified/binary targets
- Determines target type, applicable skills, analysis feasibility

### Track A: Reconnaissance (6 skills, Instrument depth: 300-600w each)

Each skill is an **analytical lens**, not a checklist. They produce trigger signals + security signals feeding Track B.

The critical distinction: mediocre skills map file patterns to categories. World-class skills teach **diagnostic reasoning** — "If you see X AND Y together, this reveals Z about the project's state and constraints."

| Skill | Analytical Lens | Deep-Dive Triggers |
|-------|----------------|-------------------|
| `identifying-tech-stack` | What constraints does this stack impose on what's possible? | Unknown build tools, sourcemap refs, standard tools only |
| `mapping-architecture` | Where are the trust boundaries? Do names match reality? | Layer violations, hidden god modules, generated+hand-written mixed |
| `tracing-dependencies` | Map dependency direction against architecture direction | Conditional imports, dynamic loading, versioning conflicts |
| `detecting-dead-code` | Why did this code die? What does dead code's story reveal? | Dead in this build but alive in flags, zombie code |
| `inventorying-api-surface` | Map explicit AND implicit entry points — HTTP, GraphQL, IPC, CLI, WebSocket | Undocumented endpoints, conditionally exposed routes |
| `analyzing-code-quality` | Correlate quality with churn — quality gradients from edge to core | Code generation evidence, quality-churn correlation hotspots |

**Standard output contract for all Track A skills:**
```
FINDINGS: [structured discoveries]
SECURITY_SIGNAL: [security-relevant findings from this lens]
TRIGGER_SIGNAL: [what deeper analysis is needed, with priority + confidence]
NEGATIVE_SIGNALS: [what we expected but didn't find]
```

### Track B Phase 1: Establish Truth (2 skills, Framework depth: 600-1000w each)

**Iron Law:** Never confuse sourcemap with source, build output with source.

| Skill | Analytical Lens | Key Techniques |
|-------|----------------|----------------|
| `trace-codebase-provenance` | What is the source of truth? Assume deception, verify everything. | Source vs derived detection, misleading markers, intent-implementation gaps, obfuscated strings |
| `analyze-build-pipeline` | How does source transform to runtime? Every analyzed build is one filtered slice. | Transformation chain reasoning, configuration axis discovery, build-time code injection |

**Phase 1 Critical Output:** Build Dimension Catalogue — lists all known configuration axes (USER_TYPE, PROVIDER, ENVIRONMENT) that affect what gets built.

### Track B Phase 2: Map Runtime (3 skills, Framework depth: 600-1000w each)

| Skill | Analytical Lens | Key Techniques |
|-------|----------------|----------------|
| `classify-repo-artifacts` | Which modules actually matter? Distinguish signal from noise. | Artifact classification with entropy analysis (abnormal density = obfuscated or generated), naming entropy metrics |
| `trace-data-flows` **(NEW)** | Follow the data, not the code. Where does untrusted data enter, where is it validated, where does it influence control flow, where does it persist, where does it exit? | Trust boundary mapping, validation gap detection, persistence tracking, exfiltration paths, side-channel data (logging/metrics/error messages that leak data) |
| `analyze-agent-loop` | What does runtime actually execute? Prompt != behavior. | State machine decomposition, turn loop tracing, state transition mapping |

### Track B Phase 3: Gates & Behavior (4 skills, restored to Uncle Dao original, Framework depth: 600-1000w each)

**Iron Law:** Real behavior lives in runtime, permissions, classifiers, gates — not in code.

| Skill | Analytical Lens | Key Techniques |
|-------|----------------|----------------|
| `extract-tool-graph` | Which tools exist conditionally? Map all tools, conditional exposure, availability. | Cross-gate matrix as output format (not separate skill), availability under different conditions |
| `map-feature-gates` | What gates control capabilities? Find build-time/runtime/permission/provider gates. | Gate classification, capability exposure analysis, hidden capabilities |
| `simulate-behavior` | How does behavior change across gate combinations? Predict under different states. | Temporal analysis, behavioral fingerprinting, state-space exploration |
| `analyze-prompt-influence` | What does the prompt actually control vs what's hardcoded? | Gap analysis (stated intent vs actual behavior), prompt-driven vs code-driven behavior separation |

### Phase 4: System Intent (1 skill, Framework depth: 600-1000w)

**`reconstruct-system-intent`** — What was this system designed to become? The real moat is rarely in the client binary, it's in the service/backend layer. Combines evolution evidence + behavior analysis + provenance findings into a coherent intent narrative.

Includes synthesis output (replaces separate `synthesize-findings` skill):
- Refactoring recommendations (from Track A findings)
- Threat model (from security signals accumulated across all phases)
- System intent narrative (from Phase 4 analysis)
- Confidence-weighted evidence map

### Hypothesis-Driven Analysis (1 skill, Instrument depth: 300-600w)

**`test-hypothesis`** — User states a hypothesis, plugin runs targeted analysis:
```
User: "I think this app sends user data to a third-party analytics service"
Plugin: Runs targeted Track A (tech stack + API surface + deps)
        -> Targeted Track B (trace-data-flows, outbound network calls, third-party SDKs)
        -> Verdict: CONFIRMED / DENIED / PARTIALLY CONFIRMED with evidence
```

**"Brilliant secret" skill** — no other analysis tool offers hypothesis-driven investigation.

**Prerequisite resolution:** `test-hypothesis` carries its own prerequisite logic. It can invoke ANY skill (Track A or Track B) regardless of normal phase prerequisites. Trade-off: invoking Track B skills without Phase 1 completion produces shallower analysis (missing build dimension context), but still produces a valid verdict. The skill checks `.state` and notes in its output which prerequisite outputs were unavailable.

### Shared Technique: Git Archaeology (reference file, not standalone skill)

**`references/git-archaeology-techniques.md`** — Shared reference file used by multiple skills:
- `detecting-dead-code`: Why did this code die? (recently killed = changed requirement, behind feature flag = upcoming)
- `analyzing-code-quality`: Churn patterns (files that always change together = hidden module boundary)
- `reconstruct-system-intent`: Abandoned features, renamed abstractions, deleted modules reveal intent

This replaces the proposed `trace-evolution-patterns` standalone skill. Git archaeology is a technique, not a skill — embedding it as a shared reference avoids awkward phase placement and lets multiple skills draw from it.

### Detect Hidden Contracts (1 skill, Instrument depth: 300-600w)

**`detect-hidden-contracts`** **(NEW)** — Find implicit contracts not documented in types, interfaces, or API schemas:
- **Environment variable contracts** — code assumes ENV vars exist without validation
- **Ordering contracts** — function A must be called before function B but nothing enforces it
- **Shape contracts** — code assumes objects have certain fields without type checking
- **Temporal contracts** — code assumes certain state exists at certain times
- **Error contracts** — code assumes errors of certain types but catches generic Exception

**"Brilliant secret" skill** — current skills find explicit contracts (APIs, types, exports) but miss implicit contracts where real bugs and hidden behaviors live.

**Boundary with `inventorying-api-surface`:** API surface finds implicit **entry points** (undocumented endpoints, conditionally exposed routes, IPC channels). This skill finds implicit **behavioral assumptions** (ordering dependencies, shape expectations, temporal state requirements). Same codebase, different analytical lens: "how do you get in?" vs "what does the code assume about how it's used?"

## Agents (2)

| Agent | Purpose | Model | Tools |
|-------|---------|-------|-------|
| `code-explorer` | Deep file traversal, call chain tracing, multi-step exploration | sonnet | Glob, Grep, Read, Bash |
| `behavior-simulator` | Multi-scenario reasoning, gate combination testing, "what if" analysis | sonnet | Glob, Grep, Read, Bash |

### Agent Dispatch Protocol

Skills dispatch agents when multi-step exploration exceeds what a single skill should do inline. The bootstrap skill (`using-codebase-analyzer`) defines these dispatch rules:

| Dispatching Skill | Agent | Input | Output Consumption |
|-------------------|-------|-------|--------------------|
| `extract-tool-graph` | `code-explorer` | Target subsystem to trace | Agent returns key files list; skill incorporates into tool graph |
| `simulate-behavior` | `behavior-simulator` | Gate map + scenarios to test | Agent returns scenario comparison; skill produces behavioral fingerprint |
| `trace-codebase-provenance` | `code-explorer` | Suspect file/directory to verify | Agent traces chain-of-custody; skill validates provenance |
| `test-hypothesis` | Either | Targeted investigation scope | Agent returns evidence; skill renders verdict |

**Dispatch format:** Skill passes a natural language investigation brief to the agent. Agent returns its findings to `docs/analysis/` using the standard contract. The dispatching skill reads the agent's output file and incorporates findings.

**Rule:** Skills MUST NOT dispatch agents for tasks they can accomplish with native tools (Glob, Grep, Read). Agents are for multi-step tracing that requires 5+ file reads across different subsystems.

## Inter-Skill Communication Contract

Every skill writes to `docs/analysis/` using this standard format:

```markdown
# Analysis: [skill-name]
## Status: complete | partial | blocked | skipped
## Target: [repo path or description]
## Prerequisites
  - Reads: docs/analysis/tech-stack.md (from identifying-tech-stack)
  - Writes: docs/analysis/[this-skill-output].md
## Findings
  [structured discoveries with file:line evidence]
## Security Signals
  [security-relevant findings]
## Trigger Signals (Track A skills only)
  - skill: [target skill name]
    reason: [one sentence]
    priority: high | medium | low
    confidence: high | medium | low
    evidence: [file:line references]
## Negative Signals
  [what we expected but didn't find]
## Build Dimensions Analyzed
  [which config axes this analysis covers]
```

## Orchestration Rules (in bootstrap skill)

```markdown
After any Track A skill completes:
1. Read its output for trigger signals + security signals
2. Aggregate all triggers by priority:
   - HIGH: Pause, present to user, offer immediate deep dive
   - MEDIUM: Continue Track A, present after all complete
   - LOW: Note for final summary, don't interrupt
3. If user accepts deep dive:
   - Check .state for phase prerequisites (warn-but-continue, not hard-block)
   - Invoke appropriate Track B phase
   - After phase completes, offer to continue or return to Track A
4. Prerequisites: WARN if missing, but CONTINUE if user wants
```

### `.state` File Contract

**Location:** `docs/analysis/.state`

**Schema:**
```markdown
# Analysis State
classify-analysis-target: complete
identifying-tech-stack: complete
mapping-architecture: partial
trace-codebase-provenance: blocked
```

**Writers:**
- `classify-analysis-target` CREATES `.state` on first run (initializes with target classification)
- Every subsequent skill APPENDS its status (`complete | partial | blocked | skipped`) on completion

**Readers:**
- Bootstrap skill reads `.state` to check prerequisites (warn-but-continue)
- `test-hypothesis` reads `.state` to determine which analyses already exist
- Orchestration logic reads `.state` to determine which Track B phases are unblocked

## Phase Gate Rules (conditional on target type)

| Target Type | Track A | Phase 1 | Phase 2 | Phase 3 | Phase 4 |
|-------------|---------|---------|---------|---------|---------|
| Standard web app | All 6 | Yes | Yes | Yes | Yes |
| Mobile (decompiled) | Tech stack only | Yes | Yes | Yes | Yes |
| IaC (Terraform/CF) | Tech stack + deps | No | Yes (skip agent loop) | Partial (no prompts) | Partial |
| Library/SDK | All 6 | No (you have source) | Partial | If gated | No |
| Monorepo | All 6 | Yes | Yes | Yes | Yes |
| Container image | Tech stack only | Yes | Yes | Yes | If applicable |
| Obfuscated/minified | BLOCK -- fail fast with message | -- | -- | -- | -- |

## Quality Model: Three Depths

Not uniform word counts. Skills have different depth needs:

| Type | Words | Content Model | Skills In This Category |
|------|-------|---------------|------------------------|
| Trigger/Router | 50-150 | Decision tree only. Zero exposition. | using-codebase-analyzer, classify-analysis-target |
| Instrument | 300-600 | Diagnostic reasoning chains, worked examples, failure modes | All Track A, test-hypothesis, detect-hidden-contracts |
| Framework | 600-1000 | Full methodology, multiple techniques, edge cases, real examples | All Track B, reconstruct-system-intent |

**The difference:** Instrument skills teach one analytical lens well. Framework skills teach a complete methodology with multiple lenses and worked examples.

## Skill Content Quality: What Makes World-Class

The bar-raiser's test: **Does this skill teach the analyst something they didn't know to look for?**

**Glorified Grep (BAD):**
```
| Signal File | What It Reveals |
|-------------|----------------|
| package.json | Node.js deps, scripts, engines |
```

**Diagnostic Reasoning (GOOD):**
```
When reading package.json:
1. Check "scripts" first. Scripts reveal the ACTUAL build pipeline,
   not declared dependencies. If "build" runs webpack but devDependencies
   lists vite, someone migrated partially.

2. Compare dependencies vs devDependencies. Business logic in
   devDependencies = build-time-only (likely code generation).
   Test utilities in dependencies = production monitoring.

3. Look for overrides/resolutions. Each override is a hidden story
   about a transitive dependency conflict.
```

**Same length, 10x more analytical value.** Teaches HOW TO THINK, not WHAT TO FIND.

### Skills Most At Risk of "Glorified Grep" Trap

| Risk Level | Skill | Current Problem | Fix |
|------------|-------|-----------------|-----|
| CRITICAL | identifying-tech-stack | Reference file is lookup table | Replace with diagnostic reasoning chains |
| CRITICAL | inventorying-api-surface | "Express uses app.get()" is not analysis | Map API to data flows, find implicit API |
| HIGH | mapping-architecture | Assumes directory names are honest | Detect when names LIE (layer violations) |
| HIGH | classify-repo-artifacts | "Domain-specific logic" is tautological | Teach how to identify domain without prior knowledge |
| MEDIUM | analyzing-code-quality | Anti-pattern grep commands | Correlate quality metrics with churn patterns |
| MEDIUM | detecting-dead-code | Good classification, weak archaeology | Add "why did this die" + zombie code detection |

### Reference Files: Elevate from Lookup to Analytical Guide

Current state: most reference files are lookup tables (file patterns -> categories).
Target state: reference files teach TECHNIQUES with worked examples.

Model after Superpowers' `systematic-debugging/root-cause-tracing.md`:
- SKILL.md teaches the THINKING (reasoning framework)
- Reference file teaches the TECHNIQUE (detailed detection with real examples)

## Design Decisions

1. **Diagnostic reasoning over lookup tables** — every skill teaches how to think, not what to find
2. **Three Depths Model** — Trigger/Router (50-150w), Instrument (300-600w), Framework (600-1000w)
3. **Unmerge Phase 3** — restore Uncle Dao's 4 original skills (extract-tool-graph, map-feature-gates, simulate-behavior, analyze-prompt-influence)
4. **Security is cross-cutting** — every skill emits SECURITY_SIGNAL; no separate security phase
5. **Git archaeology is a shared technique** — not a standalone skill, referenced by multiple skills
6. **New skills: trace-data-flows + detect-hidden-contracts** — fill genuine analytical gaps
7. **Removed: detect-side-channels + map-trust-boundaries** — scope creep, folded into trace-data-flows
8. **Removed: synthesize-findings as separate skill** — folded into reconstruct-system-intent
9. **Warn-but-continue prerequisites** — don't hard-block on missing prerequisites
10. **Skills over agents** for most tasks; agents for multi-step exploration and simulation
11. **No MCP server** — instruction-only, native tools sufficient for first version
12. **Standard output contract** — every skill writes structured markdown to docs/analysis/

## Skill Count Summary

| Category | Count | Skills |
|----------|-------|--------|
| Bootstrap | 1 | using-codebase-analyzer |
| Gate | 1 | classify-analysis-target |
| Track A | 6 | identifying-tech-stack, mapping-architecture, tracing-dependencies, detecting-dead-code, inventorying-api-surface, analyzing-code-quality |
| Phase 1 | 2 | trace-codebase-provenance, analyze-build-pipeline |
| Phase 2 | 3 | classify-repo-artifacts, **trace-data-flows** (NEW), analyze-agent-loop |
| Phase 3 | 4 | extract-tool-graph, map-feature-gates, simulate-behavior, analyze-prompt-influence |
| Phase 4 | 1 | reconstruct-system-intent (includes synthesis) |
| Special | 2 | test-hypothesis, **detect-hidden-contracts** (NEW) |
| **Total** | **20** | |

## Changes from v1 (Current Implementation)

| Change | Detail |
|--------|--------|
| Unmerge Phase 3 | 2 skills -> 4 skills (restore Uncle Dao) |
| New skill: trace-data-flows | Data entry->transform->exit with trust boundaries |
| New skill: detect-hidden-contracts | Implicit contracts (ENV, ordering, shape, temporal, error) |
| Remove: synthesize-findings | Folded into reconstruct-system-intent |
| Remove: map-conditional-behavior | Split back into extract-tool-graph + map-feature-gates |
| Remove: analyze-prompt-influence merged | Restored as standalone |
| Shared reference: git-archaeology-techniques | Used by detecting-dead-code, analyzing-code-quality, reconstruct-system-intent |
| All skills: diagnostic reasoning | Replace lookup tables with reasoning chains |
| All skills: security signals | Every skill emits SECURITY_SIGNAL in output |
| Prerequisites: warn-but-continue | No hard blocks on missing prerequisites |
| 3 depth tiers | Trigger/Router, Instrument, Framework instead of uniform word counts |

## Hook Platform Compatibility

All hooks must support macOS (bash) and Windows (cmd.exe via Git Bash). The polyglot wrapper pattern from `run-hook.cmd` is mandatory for new hooks. The `session-start` hook already handles Cursor (`CURSOR_PLUGIN_ROOT`), Claude Code (`CLAUDE_PLUGIN_ROOT`), and Copilot CLI (`COPILOT_CLI`) — any new hooks must follow the same detection pattern.

## CSO Descriptions for New/Restored Skills

Description fields use trigger-only CSO format (describe WHEN to use, not WHAT it does):

| Skill | CSO Description |
|-------|----------------|
| `extract-tool-graph` | Use when investigating conditional tool availability, finding tools that exist but are hidden behind gates, or mapping the full capability surface of a system |
| `map-feature-gates` | Use when you need to understand why capabilities differ across configurations, user types, or deployment environments, or when investigating feature flags and capability gates |
| `simulate-behavior` | Use when predicting how a system behaves under different conditions, testing "what if" scenarios for gate combinations, or comparing behavioral fingerprints across configurations |
| `trace-data-flows` | Use when tracking how data enters, transforms, persists, and exits a system, or when investigating trust boundaries, validation gaps, and potential data exfiltration paths |
| `detect-hidden-contracts` | Use when investigating implicit assumptions in code — ordering dependencies, unvalidated environment variables, assumed object shapes, or temporal state requirements that aren't enforced by types or tests |

## Migration from v1 (16 skills) to v2 (20 skills)

### Directory Changes

| Action | Directory | Target |
|--------|-----------|--------|
| SPLIT | `skills/map-conditional-behavior/` | -> `skills/extract-tool-graph/` + `skills/map-feature-gates/` |
| RENAME | `skills/analyze-prompt-influence/` | Keep as-is (already correct name) |
| CREATE | `skills/simulate-behavior/` | New skill directory |
| CREATE | `skills/trace-data-flows/` | New skill directory + references |
| CREATE | `skills/detect-hidden-contracts/` | New skill directory + references |
| DELETE | `skills/synthesize-findings/` | Folded into `reconstruct-system-intent` |
| CREATE | `skills/reconstruct-system-intent/` | Replaces synthesize-findings |
| CREATE | `skills/_shared/references/git-archaeology-techniques.md` | Shared technique reference |

### Rename Mapping (for users with saved workflows)

| Old Skill | New Skill | Notes |
|-----------|-----------|-------|
| `/codebase-analyzer:map-conditional-behavior` | `/codebase-analyzer:extract-tool-graph` | Tool graph extraction split out |
| `/codebase-analyzer:map-conditional-behavior` | `/codebase-analyzer:map-feature-gates` | Gate mapping split out |
| `/codebase-analyzer:synthesize-findings` | `/codebase-analyzer:reconstruct-system-intent` | Synthesis folded into intent |

## Documentation Updates Required

| File | Current State | Required Change |
|------|---------------|-----------------|
| `README.md` | Lists 14+2, Phase 3 shows merged `map-conditional-behavior` | Rewrite to 20 skills, split Phase 3 into 4, add new skills, remove synthesize-findings |
| `CLAUDE.md` | Says "14 skills + 2 agents", old word budgets | Update to 20 skills, three-depth model, diagnostic reasoning principle |
| `.opencode/INSTALL.md` | Says "16 analysis skills" | Update to 20 |
| `CHANGELOG.md` | v0.1.0 only | Add v0.2.0 entry with migration notes |
| `package.json` | version 0.1.0 | Bump to 0.2.0 |
| `.claude-plugin/plugin.json` | version 0.1.0 | Bump to 0.2.0 |
| `.claude-plugin/marketplace.json` | version 0.1.0 | Bump to 0.2.0 |
