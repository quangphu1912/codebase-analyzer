---
name: map-conditional-behavior
description: Use when mapping all available tools/capabilities and their conditional exposure, finding which tools exist under what conditions, or understanding feature gates that control what the system can do
---

## Announce at start: "Using codebase-analyzer to map conditional behavior."

## Overview

Two-pass analysis: (1) map ALL tools/capabilities that exist in the codebase, (2) map the gates that control which tools are available under which conditions.

**Prerequisite:** Reads `docs/analysis/agent-loop.md` and `docs/analysis/build-pipeline.md`.

## Pass 1: Tool Graph

1. Find all tool definitions (function handlers, API endpoints, CLI commands)
2. Map tool registry: which tools are registered and how
3. Identify tool parameters and constraints
4. Find tools that are defined but conditionally registered
5. Note: the `behavior-simulator` agent can perform deep multi-file tracing for this

## Pass 2: Gate Mapping

1. Build-time gates: tools filtered during compilation (from build pipeline analysis)
2. Runtime gates: tools enabled/disabled based on runtime conditions
3. Permission gates: tools restricted by user role or permission level
4. Provider gates: tools available only for specific providers/backends
5. Config gates: tools controlled by feature flags or config values

## Quick Reference

| Gate Type | Where To Look | Example |
|-----------|--------------|---------|
| Build-time | Build config, #ifdef, conditional compilation | `if (process.env.NODE_ENV === 'production')` |
| Runtime | State checks, config reads, feature flags | `if (user.type === 'admin')` |
| Permission | Auth checks, role verification | `if (hasPermission('write'))` |
| Provider | Provider-specific code paths | `if (provider === 'openai')` |
| Config | Feature flags, settings, environment | `if (config.featureEnabled('x'))` |

## Cross-Gate-Tool Matrix

Produce a matrix: rows = tools, columns = gate types, cells = available (Y/N/conditional).

## Red Flags

- Only finding registered tools, missing tools that are defined but conditionally excluded
- Not cross-referencing with build pipeline output for build-time gates
- Missing dynamic tool registration patterns

## Output Contract

Write `docs/analysis/conditional-behavior.md` using standard contract.
Include: tool graph, gate inventory, cross-gate-tool matrix.
