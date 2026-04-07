---
name: identifying-tech-stack
description: Use when onboarding to a new project, evaluating migration feasibility, auditing dependency health, or needing to know what technologies power a codebase
---

## Announce at start: "Using codebase-analyzer to identify the tech stack."

## Overview

Catalog every technology, framework, library, and tool in use. First Track A skill — its output informs all subsequent analysis.

## Process

1. Read package manifests (package.json, Cargo.toml, go.mod, requirements.txt, pom.xml, .csproj, Gemfile, etc.)
2. Identify build tools from config files (webpack.config, vite.config, tsconfig, Makefile, Dockerfile, Jenkinsfile)
3. Detect frameworks from code patterns and dependencies
4. Identify runtime/language versions (engines field, .python-version, .nvmrc, rust-toolchain.toml)
5. Map deployment infrastructure (Docker, K8s, serverless, CI/CD)
6. Flag outdated or deprecated dependencies
7. Produce tech stack report

## Quick Reference

| Signal File | What It Reveals |
|-------------|----------------|
| package.json | Node.js deps, scripts, engines |
| Cargo.toml | Rust deps, features, targets |
| go.mod | Go module path, deps |
| requirements.txt / pyproject.toml | Python deps |
| Dockerfile / docker-compose.yml | Container config, base images |
| .github/workflows/ | CI/CD pipeline |
| tsconfig.json | TypeScript config, strictness |

## Trigger Signals

- **HIGH confidence**: Found .js.map files with no TypeScript source -> `trace-codebase-provenance`
- **HIGH confidence**: Unknown/custom build tools not in standard catalog -> `analyze-build-pipeline`
- **MEDIUM confidence**: Mixed language ecosystem -> affects analysis strategy
- **LOW confidence**: Standard tech stack, all well-known -> no deep dive needed

## Red Flags

- Reporting only top-level deps without checking transitive
- Missing the build tool chain (only listing languages)
- Not checking for lock files (package-lock, yarn.lock, Cargo.lock)

## Output Contract

Write `docs/analysis/tech-stack.md` using standard contract.
Include: languages, frameworks, build tools, runtime versions, CI/CD, dependency health.
