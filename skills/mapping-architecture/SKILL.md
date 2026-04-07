---
name: mapping-architecture
description: Use when needing component relationships, layer boundaries, module structure, or understanding how parts of a codebase fit together before modification or refactoring
---

## Announce at start: "Using codebase-analyzer to map the architecture."

## Overview

Map the codebase's structural architecture: components, layers, boundaries, and communication patterns.

## Process

1. Identify entry points (main files, index files, routing, public API exports)
2. Map directory structure to logical layers (presentation, business, data, infrastructure)
3. Trace component boundaries — which dirs/modules form cohesive units
4. Identify cross-cutting concerns (auth, logging, config, error handling)
5. Map communication between components (imports, function calls, events, message queues)
6. Find shared state and coupling points

## Quick Reference

| Signal | Layer |
|--------|-------|
| routes/, pages/, views/, controllers/ | Presentation |
| services/, domain/, business/, use-cases/ | Business Logic |
| models/, repositories/, data/, db/ | Data Access |
| config/, middleware/, utils/, lib/ | Infrastructure |
| tests/, __tests__/, spec/ | Test |

## Trigger Signals

- **HIGH confidence**: Generated code mixed with hand-written (e.g., GraphQLcodegen output in src/) -> `trace-codebase-provenance`
- **HIGH confidence**: Hidden/private modules not referenced from entry points -> `classify-repo-artifacts`
- **MEDIUM confidence**: Unclear layer boundaries, tangled imports -> `tracing-dependencies`
- **LOW confidence**: Clean separation, well-defined layers -> no deep dive needed

## Red Flags

- Assuming directory names map directly to layers without verification
- Missing internal packages that aren't obvious from top-level structure
- Not checking for generated code markers

## Output Contract

Write `docs/analysis/architecture.md` using standard contract.
Include: layer diagram, component list, cross-cutting concerns, coupling points.
