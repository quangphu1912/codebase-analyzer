---
name: classify-analysis-target
description: Use before any codebase analysis — determines target type, feasibility, and which skills apply
---

## Announce at start: "Using codebase-analyzer to classify the analysis target."

<HARD-GATE>
NO TRACK A SKILLS WITHOUT TARGET CLASSIFICATION FIRST.
An unclassified target is an unanalyzable target.
</HARD-GATE>

## Overview

Classify what we're analyzing before burning tokens. This skill determines target type, analysis feasibility, and applicable skills.

## Process

1. **Scan top-level files**: Look for manifest files (package.json, Cargo.toml, go.mod, requirements.txt, Dockerfile, .tf files, .csproj, pom.xml)
2. **Check file types**: `find . -maxdepth 2 -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -20`
3. **Detect obfuscation/minification**: Check for single-line JS files, .pyc-only directories, .wasm files, packed binaries
4. **Identify repo structure**: Single repo, monorepo (packages/ or workspaces/), multi-service (docker-compose)
5. **Classify target type** and applicable skills

## Target Types and Applicable Skills

| Target Type | Track A | Track B Phases |
|-------------|---------|---------------|
| Web app (standard) | All 6 | All phases |
| Mobile (decompiled) | Tech stack only | All phases |
| IaC (Terraform/CF) | Tech stack + deps | Phase 2-3 (no agent loop, no prompts) |
| Library/SDK | All 6 | If gated features found |
| Monorepo | All 6 | All phases |
| Container image | Tech stack only | All phases |
| Obfuscated/minified | **BLOCK** | Fail fast |

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Looks like a standard web app" | Similar apps differ. Check manifests before assuming. |
| "I can skip this and just start analyzing" | Wrong skills produce garbage. 30 seconds saves hours. |
| "The user asked a specific question" | Specific questions still need classification to know WHERE to look. |

## Red Flags

- Skipping this skill because "it's obviously a web app"
- Proceeding with Track A before writing target-classification.md
- Not checking for obfuscation/minification before analysis

## Output Contract

Write `docs/analysis/target-classification.md` using standard contract.
