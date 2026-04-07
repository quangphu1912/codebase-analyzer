---
name: synthesize-findings
description: Use when delivering a comprehensive analysis report, creating a handoff document, or synthesizing all analysis findings into actionable recommendations and system intent reconstruction
---

## Announce at start: "Using codebase-analyzer to synthesize all findings."

## Overview

Combine all analysis outputs into one coherent document. Includes Track A refactoring recommendations and Track B system intent reconstruction.

**Prerequisite:** At minimum, reads all completed analysis files from `docs/analysis/`.

## Report Structure

```markdown
# Codebase Analysis Report
## Date: [YYYY-MM-DD]
## Target: [repo path/description]

### 1. Executive Summary (1 paragraph)
### 2. Target Classification (from classify-analysis-target)
### 3. Tech Stack (from identifying-tech-stack)
### 4. Architecture Overview (from mapping-architecture)
### 5. Dependency Health (from tracing-dependencies)
### 6. Dead Code Inventory (from detecting-dead-code)
### 7. API Surface (from inventorying-api-surface)
### 8. Code Quality (from analyzing-code-quality)

### [Track B sections if available]
### 9. Provenance Analysis (from trace-codebase-provenance)
### 10. Build Pipeline (from analyze-build-pipeline)
### 11. Artifact Classification (from classify-repo-artifacts)
### 12. Agent Loop Analysis (from analyze-agent-loop)
### 13. Conditional Behavior (from map-conditional-behavior)
### 14. Prompt Influence (from analyze-prompt-influence)
### 15. System Intent (reconstructed from all evidence)
### 16. Moat Analysis (where the real control lies)

### Action Items
### Priority Actions (high impact, low effort)
### Refactoring Recommendations (from Track A findings)
### Investigation Recommendations (from Track B findings)

### Appendices
### Build Dimensions Analyzed / Not Analyzed
### Confidence Notes
### Files Analyzed vs Skipped
```

## System Intent Reconstruction (if Track B complete)

Synthesize evidence from all phases:
1. What is this system designed to become? (from architecture + capabilities)
2. Where is the moat? (from gate analysis — client vs service vs ecosystem)
3. What can it do that it doesn't expose? (from conditional-behavior + dead-code)
4. How is behavior really controlled? (from prompt-influence + gates)
5. What are the hidden dependencies? (from provenance + build-pipeline)

## Output Contract

Write `docs/analysis/analysis-report-[YYYY-MM-DD].md`.
This is the final output — no separate status needed.
