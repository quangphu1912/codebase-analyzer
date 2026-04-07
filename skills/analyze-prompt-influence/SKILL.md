---
name: analyze-prompt-influence
description: Use when separating prompt-driven behavior from code-driven behavior, understanding what system prompts actually control vs what's hardcoded, or testing how behavior changes under different prompt configurations
---

## Announce at start: "Using codebase-analyzer to analyze prompt influence."

## Overview

Compare two influence sources: (1) what the system prompt instructs, (2) what the code actually enforces. Determine the gap between "told to do" and "forced to do."

**Prerequisite:** Reads `docs/analysis/conditional-behavior.md` (need gate map).

## Part 1: Prompt Control Extraction

1. Find all system prompt templates and instructions
2. Map prompt-driven behaviors: what the prompt tells the system to do
3. Identify prompt variables and conditional sections
4. Find prompt versioning/A-B testing patterns
5. Note: prompt is not behavior. Prompt says "don't do X" but code may not enforce it.

## Part 2: Behavior Comparison

For each behavior dimension:
1. What does the prompt SAY to do? (prompt control)
2. What does the code ENFORCE? (runtime control)
3. What's the gap? (prompt-only vs code-enforced)
4. Which gates affect this behavior? (from conditional-behavior.md)

## Quick Reference

| Dimension | Prompt Control | Code Enforcement |
|-----------|---------------|-----------------|
| Tool usage | "Use tool X only when Y" | Tool X registered only if gate Y passes |
| Response style | "Be concise" | Token limit in code |
| Safety | "Don't generate harmful content" | Output filter in code |
| Capabilities | "You can do X" | X only available if feature flag on |

## Key Insight

**Prompt is not behavior.** A system prompt that says "don't do X" is a suggestion. Code that removes tool X is enforcement. The gap between them is where the real control architecture lives.

## Red Flags

- Treating prompt instructions as guaranteed behavior
- Not finding the code-level enforcement (or lack thereof)
- Missing conditional prompt sections that vary by user type

## Output Contract

Write `docs/analysis/prompt-influence.md` using standard contract.
Include: prompt controls, code controls, gap analysis, behavioral dimensions.
