---
name: test-hypothesis
description: Use when you have a specific suspicion about a codebase and want targeted analysis to confirm or deny it with evidence, rather than exploratory analysis
---

## Announce at start: "Using codebase-analyzer to test hypothesis: [hypothesis]."

## Overview

User states a hypothesis. Plugin runs targeted analysis focused on confirming or denying it. This is hypothesis-driven analysis, not exploratory scanning.

## Process

1. **Parse hypothesis**: Extract the specific claim and what evidence would confirm/deny it
2. **Select relevant skills**: Which Track A/B skills address this hypothesis?
3. **Run targeted analysis**: Only invoke skills relevant to the hypothesis
4. **Gather evidence**: Collect file:line references that support or contradict
5. **Render verdict**: CONFIRMED / DENIED / PARTIALLY CONFIRMED / INCONCLUSIVE
6. **Present evidence**: For each piece of evidence, explain how it relates to the hypothesis

## Example Hypotheses

| Hypothesis | Skills to Run | Evidence to Find |
|-----------|---------------|-----------------|
| "This app sends data to third parties" | tech-stack, deps, api-surface | Outbound HTTP calls to non-first-party domains |
| "There's a hidden admin panel" | architecture, api-surface, conditional-behavior | Routes gated by role, undocumented endpoints |
| "This code was decompiled, not original" | provenance, build-pipeline | Sourcemap artifacts, decompiled patterns |
| "Feature X is coming but not yet released" | dead-code, conditional-behavior | Dead code behind feature flags, unreleased API endpoints |
| "This system can do more than it exposes" | conditional-behavior, prompt-influence | Tools defined but gated, capabilities hidden behind config |

## Verdict Format

```
## Hypothesis: [statement]
## Verdict: CONFIRMED | DENIED | PARTIALLY CONFIRMED | INCONCLUSIVE
## Confidence: HIGH | MEDIUM | LOW

### Supporting Evidence
- [file:line] [description of evidence]

### Contradicting Evidence
- [file:line] [description of evidence]

### Missing Evidence
- [what we'd need to check but couldn't access]

### Recommendation
- [what to investigate further, if anything]
```

## Red Flags

- Running full Track A when only 1-2 skills are needed
- Declaring CONFIRMED/DENIED with weak evidence
- Not listing contradicting evidence even when confirming

## Output Contract

Write `docs/analysis/hypothesis-test.md` using standard contract.
Include: hypothesis, verdict, confidence, evidence list, recommendations.
