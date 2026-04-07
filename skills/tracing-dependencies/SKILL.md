---
name: tracing-dependencies
description: Use when investigating coupling between modules, finding circular dependencies, understanding change impact, or before modifying shared code
---

## Announce at start: "Using codebase-analyzer to trace dependencies."

## Overview

Build the import/require dependency graph. Find coupling, circular deps, and modules that everything depends on.

## Process

1. Build import graph: grep for import/require/from statements across source files
2. Identify circular dependencies (A imports B imports A)
3. Calculate fan-in/fan-out per module (see references/dependency-metrics.md)
4. Detect god modules (high fan-in + high fan-out)
5. Find stable vs volatile dependencies (many depend on = stable)
6. Identify implicit deps (shared state, env vars, global config)
7. Output dependency report with risk areas

## Quick Reference

| Smell | Signal | Risk |
|-------|--------|------|
| Circular dependency | A->B->A in import graph | High |
| God module | Fan-in >20 AND fan-out >10 | High |
| Volatile base | Low fan-in, high fan-out | Medium |
| Hidden coupling | Shared global state | High |
| Dynamic import | import() or __import__() | Medium |

## Trigger Signals

- **HIGH confidence**: Conditional imports that vary by config -> `map-conditional-behavior`
- **HIGH confidence**: Dynamic loading patterns (import(), require(variable)) -> `map-conditional-behavior`
- **MEDIUM confidence**: Heavy coupling (god modules) -> refactoring candidate
- **LOW confidence**: Clean import graph, low coupling -> no deep dive needed

## Red Flags

- Only scanning static imports, missing dynamic ones
- Treating test dependencies as production coupling
- Not checking peer dependencies and optional imports

## Output Contract

Write `docs/analysis/dependencies.md` using standard contract.
Include: import graph summary, circular deps list, god modules, coupling metrics.
