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

You have codebase analysis skills. Two tracks, progressive depth:

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
- Phase 2: `classify-repo-artifacts`, `analyze-agent-loop`
- Phase 3: `map-conditional-behavior`, `analyze-prompt-influence`

**Special:**
- `/codebase-analyzer:test-hypothesis` — state hypothesis, get verdict with evidence
- `/codebase-analyzer:synthesize-findings` — comprehensive report from all analyses

**Orchestration:** After any Track A skill, check its output for trigger signals. HIGH priority -> pause, offer immediate deep dive. MEDIUM -> continue Track A, present after all complete. LOW -> note for summary. Track B phases require prior phase completion (check `docs/analysis/.state`). Track B skills MUST announce: "Using codebase-analyzer to [skill purpose]."

**Red Flags — STOP and check yourself:**

| Thought | Reality |
|---------|---------|
| "I can just read the codebase directly" | Without classification you'll miss target-specific patterns |
| "Track A is overkill for this" | Skipping reconnaissance means missing trigger signals |
| "I'll skip to Track B directly" | Phase 1 errors cascade into every downstream analysis |
| "This is just a standard web app" | Similar apps differ. Classify first, assume nothing. |
