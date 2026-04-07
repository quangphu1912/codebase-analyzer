---
name: inventorying-api-surface
description: Use when documenting public interfaces, planning API changes, evaluating backward compatibility, or understanding what a module exposes to consumers
---

## Announce at start: "Using codebase-analyzer to inventory the API surface."

## Overview

Catalog every public interface: exported functions, classes, types, REST/GraphQL endpoints, and their contracts.

## Process

1. Find public exports (export, module.exports, pub fn, def with __all__)
2. Map REST/GraphQL/RPC endpoints if applicable
3. Document function signatures and type contracts
4. Find breaking change risks (widely-used public APIs)
5. Find undocumented public APIs
6. Categorize by stability: stable, experimental, deprecated, internal-but-exported

## Quick Reference

| Signal | API Type |
|--------|----------|
| export function, export class, module.exports | JS/TS public API |
| pub fn, pub struct, pub enum | Rust public API |
| @app.route, router.get/post | REST endpoint |
| type Query, type Mutation | GraphQL endpoint |
| @public, @api in JSDoc | Documented public API |

## Trigger Signals

- **HIGH confidence**: APIs exposed conditionally behind feature flags -> `map-conditional-behavior`
- **HIGH confidence**: Internal APIs exposed without documentation -> `classify-repo-artifacts`
- **MEDIUM confidence**: Versioned APIs with deprecation patterns -> refactoring candidate
- **LOW confidence**: Well-documented, stable API surface -> no deep dive needed

## Red Flags

- Only checking explicit exports, missing re-exports
- Not checking REST/GraphQL endpoints if they exist
- Ignoring type-level API (exported interfaces, types)

## Output Contract

Write `docs/analysis/api-surface.md` using standard contract.
Include: exported symbols, endpoints, stability categories, undocumented APIs.
