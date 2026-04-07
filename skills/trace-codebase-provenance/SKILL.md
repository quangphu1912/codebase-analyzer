---
name: trace-codebase-provenance
description: Use when repo origin is unclear, dealing with leaks/sourcemaps/decompiled code, or needing to distinguish source of truth from derived, generated, or reconstructed layers
---

## Announce at start: "Using codebase-analyzer to trace codebase provenance."

## Overview

Distinguish source of truth from derived layers. Critical first step — if you misidentify generated code as source, every downstream analysis is poisoned.

**Prerequisite:** Reads `docs/analysis/target-classification.md` and `docs/analysis/tech-stack.md`.

## Process

1. Check for sourcemap files (*.map, .js.map) — if present without corresponding source, this is derived
2. Look for compilation markers: "DO NOT EDIT", "@generated", timestamps in headers
3. Identify hand-written vs machine-generated code patterns (see references/provenance-patterns.md)
4. Check git history: were files committed in batches (generated) or individually (hand-written)?
5. Identify the source-of-truth layer: where did this code originate?
6. Map derivation chain: source -> intermediate -> shipped -> runtime
7. Produce provenance map with build dimension catalogue

## Build Dimension Catalogue

Every analysis output MUST include which config axes were examined:

```
## Build Dimensions Analyzed
- ENVIRONMENT: development (current)
- USER_TYPE: external (assumed from build)
- PROVIDER: not determined

## Dimensions NOT Analyzed
- USER_TYPE: internal, admin
- PROVIDER: all variants
```

## Trigger Signals

- **HIGH confidence**: Sourcemap without source -> decompiled/derived
- **HIGH confidence**: Build filters code based on config -> `analyze-build-pipeline`
- **MEDIUM confidence**: Partial source with generated files -> mixed provenance

## Red Flags

- Assuming all .js files are source (could be compiled TS output)
- Not checking git history for batch-committed generated code
- Missing the build dimension catalogue (downstream skills depend on it)

## Output Contract

Write `docs/analysis/provenance.md` using standard contract.
Include: provenance map, source-of-truth location, derivation chain, build dimensions.
