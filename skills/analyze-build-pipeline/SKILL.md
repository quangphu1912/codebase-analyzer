---
name: analyze-build-pipeline
description: Use when understanding how source transforms to runtime, what gets filtered/compiled/generated, or tracing build-time shaping that affects what code actually runs
---

## Announce at start: "Using codebase-analyzer to analyze the build pipeline."

## Overview

Trace the source -> runtime transformation pipeline. Find filtering, compilation, code generation, and build-time shaping.

**Prerequisite:** Reads `docs/analysis/provenance.md` (from trace-codebase-provenance).

## Process

1. Identify build config files (webpack.config, vite.config, tsconfig, Cargo.toml, Makefile)
2. Map build stages: lint -> compile -> bundle -> optimize -> package -> deploy
3. Find code filtering: what gets included/excluded by build conditions
4. Identify code generation: Protobuf, GraphQL, OpenAPI generators
5. Find build-time constants injected into code
6. Trace environment variable usage in build
7. Produce build pipeline map with filtering report

## Quick Reference

| Build Tool | Config Location | Key Features |
|-----------|----------------|--------------|
| webpack | webpack.config.* | Loaders, plugins, code splitting |
| Vite | vite.config.* | Plugins, define, env replacement |
| esbuild | build script | Bundle, define, external |
| Cargo | Cargo.toml | Features, profiles, build scripts |
| Make | Makefile | Targets, variables, recipes |
| Bazel | BUILD, WORKSPACE | Rules, targets, toolchains |

## Trigger Signals

- **HIGH confidence**: Build conditions that filter tools/capabilities -> `map-conditional-behavior`
- **HIGH confidence**: Environment-specific code paths -> affects all downstream analysis
- **MEDIUM confidence**: Code generation step -> provenance verified
- **LOW confidence**: Standard build, no filtering -> no additional deep dive

## Red Flags

- Not checking for code generation steps that modify source
- Missing build-time constant injection (DefinePlugin, etc.)
- Ignoring environment-specific build variants

## Output Contract

Write `docs/analysis/build-pipeline.md` using standard contract.
Include: pipeline stages, filtering rules, code generation, build-time constants, config axes discovered.
