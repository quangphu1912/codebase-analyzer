---
name: using-codebase-analyzer
description: Use when analyzing, auditing, reverse engineering, or understanding any codebase — especially unfamiliar, inherited, leaked, or complex systems
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance an analysis skill might apply to what you are doing, you ABSOLUTELY MUST invoke it. This is not negotiable.
</EXTREMELY-IMPORTANT>

Two tracks, progressive depth:

**Track A (Reconnaissance)** — surface scan, each skill outputs trigger signals:
- `/codebase-analyzer:classify-analysis-target` — **FIRST. ALWAYS. No exceptions.**
- `/codebase-analyzer:identifying-tech-stack`
- `/codebase-analyzer:mapping-architecture`
- `/codebase-analyzer:tracing-dependencies`
- `/codebase-analyzer:detecting-dead-code`
- `/codebase-analyzer:inventorying-api-surface`
- `/codebase-analyzer:analyzing-code-quality`

**Track B (Deep Dive)** — phased investigation, conditional on target type:
- Phase 1: `trace-codebase-provenance`, `analyze-build-pipeline`
- Phase 2: `classify-repo-artifacts`, `trace-data-flows`, `analyze-agent-loop`
- Phase 3: `extract-tool-graph`, `map-feature-gates`, `simulate-behavior`, `analyze-prompt-influence`
- Phase 4: `reconstruct-system-intent`

**Special:**
- `/codebase-analyzer:test-hypothesis` — state hypothesis, get verdict with evidence
- `/codebase-analyzer:detect-hidden-contracts` — uncover implicit interfaces

**Express lane:** Skip Track A, invoke any Track B skill directly. Missing context may produce shallower analysis.

**Agent Dispatch Protocol:**

| Skill | Dispatches Agent | When |
|-------|-----------------|------|
| extract-tool-graph | code-explorer | Tool graph spans 5+ files |
| simulate-behavior | behavior-simulator | Multiple scenarios to compare |
| trace-codebase-provenance | code-explorer | Chain-of-custody tracing |
| test-hypothesis | Either | Targeted investigation |

Dispatch only when task exceeds native tool capability (5+ file reads across subsystems).

**`.state` rules:** classify-analysis-target creates `docs/analysis/.state`. Every skill appends its status. Check before Track B (warn-but-continue).

**Orchestration:** After Track A, check trigger signals + security signals. HIGH: pause, offer deep dive. MEDIUM: continue. LOW: note.

**Red Flags — STOP and check yourself:**

| Thought | Reality |
|---------|---------|
| "I can just read the codebase directly" | Without classification you'll miss target-specific patterns |
| "Track A is overkill for this" | Skipping reconnaissance means missing trigger signals |
| "I'll skip to Track B directly" | Phase 1 errors cascade into every downstream analysis |
| "This is just a standard web app" | Similar apps differ. Classify first, assume nothing. |
| "I'll just run all skills" | Target type determines applicable phases. |
