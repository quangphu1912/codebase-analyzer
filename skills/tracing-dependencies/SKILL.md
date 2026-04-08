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
7. **Direction-check against architecture**: Map each dependency edge against declared architecture layers. If business logic depends on infrastructure, the Dependency Inversion Principle is violated. The DIRECTION of a dependency matters more than the COUNT. Flag any "lower->higher" import (e.g., `domain` importing `framework`) as an architectural violation.
8. **Detect dependency clusters**: Modules that always appear in the same import chains form a hidden bounded context. These clusters change together and should be evaluated as a unit. Look for 3+ modules that co-occur across multiple independent import paths.
9. **Check versioning conflicts**: Same transitive dependency resolved at different versions across module boundaries creates potential runtime inconsistency. Run `npm ls <pkg>`, `cargo tree -d`, or equivalent to detect duplicates.
10. Output dependency report with risk areas

## Quick Reference

| Smell | Signal | Risk |
|-------|--------|------|
| Circular dependency | A->B->A in import graph | High |
| God module | Fan-in >20 AND fan-out >10 | High |
| Volatile base | Low fan-in, high fan-out | Medium |
| Hidden coupling | Shared global state | High |
| Dynamic import | import() or __import__() | Medium |
| Architecture violation | Business logic imports infrastructure | High |
| Dependency cluster | 3+ modules always co-occur in import chains | Medium |
| Version conflict | Same package at multiple versions in tree | Medium |

## Trigger Signals

- **HIGH confidence**: Conditional imports that vary by config -> `map-feature-gates`
- **HIGH confidence**: Dynamic loading patterns (import(), require(variable)) -> `extract-tool-graph`
- **MEDIUM confidence**: Heavy coupling (god modules) -> refactoring candidate
- **LOW confidence**: Clean import graph, low coupling -> no deep dive needed

## SECURITY_SIGNAL

Dependencies with known CVEs, private package registries without integrity checks, or dependency confusion attack vectors. Run `npm audit`, `cargo audit`, or `pip audit` during analysis. Flag any package sourced from a different registry than the primary (e.g., mixing npmjs.com with a private registry without verification).

## Red Flags

- Only scanning static imports, missing dynamic ones
- Treating test dependencies as production coupling
- Not checking peer dependencies and optional imports

## Output Contract

Write `docs/analysis/dependencies.md` using standard contract.
Include: import graph summary, circular deps list, god modules, coupling metrics.
