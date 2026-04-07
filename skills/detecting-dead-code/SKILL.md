---
name: detecting-dead-code
description: Use when reducing codebase size, cleaning up before refactoring, investigating slow builds, or auditing for unused code and orphaned files
---

## Announce at start: "Using codebase-analyzer to detect dead code."

## Overview

Find code that is unreachable, unused, or orphaned. Classify findings by removal safety.

## Process

1. Find unused exports: symbols exported but never imported elsewhere
2. Find unreachable code: after return/throw, behind false conditions
3. Find orphaned files: files not imported/required by anything
4. Find dead config: config keys no code reads
5. Find unused dependencies in package manifests
6. Classify: safe-to-remove, needs-verification, keep-for-compat

## Classification

| Category | Confidence | Action |
|----------|-----------|--------|
| Exported, nothing imports it | HIGH safe | Remove |
| Behind false compile condition | HIGH safe | Remove |
| Not imported but may be dynamic | MEDIUM verify | Check dynamic imports |
| Platform-conditional code | LOW verify | May be alive in other builds |
| Public API for external use | KEEP | Document if missing |

## Trigger Signals

- **HIGH confidence**: Code dead in THIS build but build flags suggest alive in other configs -> `map-conditional-behavior`
- **HIGH confidence**: Significant dead code behind feature flags -> `analyze-build-pipeline`
- **MEDIUM confidence**: Dead code that was recently killed -> `analyze-agent-loop` (check git history)
- **LOW confidence**: Standard unused code -> refactoring candidate only

## Warning: False Positives

Dynamic imports, reflection, plugin systems, and eval() can make live code appear dead. Always check for these before reporting.

## Red Flags

- Reporting code as dead without checking dynamic imports
- Not checking reflection/eval patterns
- Ignoring platform-specific code paths

## Output Contract

Write `docs/analysis/dead-code.md` using standard contract.
Include: unused exports list, orphaned files, classification breakdown, removal recommendations.
