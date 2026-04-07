---
name: classify-repo-artifacts
description: Use when distinguishing core modules from support/generated/test/infrastructure code, separating signal from noise, or understanding which parts of a repo actually matter for analysis
---

## Announce at start: "Using codebase-analyzer to classify repo artifacts."

## Overview

Sort every module/file into categories: core, support, generated, test, infrastructure. Essential before deep analysis — don't waste tokens analyzing generated code.

**Prerequisite:** Reads `docs/analysis/provenance.md` and `docs/analysis/architecture.md`.

## Process

1. Load provenance map (which files are source vs derived)
2. Tag each top-level directory/module with category
3. Core: business logic, domain models, API handlers, data access
4. Support: utilities, helpers, shared libraries, middleware
5. Generated: build output, codegen, protobuf, graphql generated
6. Test: test files, fixtures, mocks, test utilities
7. Infrastructure: CI/CD, Docker, deployment scripts, config
8. Calculate signal-to-noise ratio: core / total

## Classification Heuristics

| Category | Indicators |
|----------|-----------|
| Core | Business logic, domain types, API handlers, data models |
| Support | utils/, helpers/, lib/, shared/, common/ |
| Generated | "DO NOT EDIT", codegen output, dist/ contents |
| Test | *.test.*, *.spec.*, __tests__/, test/, tests/ |
| Infra | Dockerfile, docker-compose, .github/, k8s/, terraform/ |

## Validation Checkpoint

After classification, verify against provenance:
- Does every "generated" file appear in the provenance map as derived?
- Are any "core" files actually generated but misidentified?
- Cross-reference with build pipeline output.

## Red Flags

- Classifying generated code as core (wastes downstream analysis tokens)
- Missing infrastructure-as-code files (Terraform, CloudFormation)
- Not validating classification against provenance map

## Output Contract

Write `docs/analysis/artifact-classification.md` using standard contract.
Include: category breakdown, signal-to-noise ratio, files per category, validation status.
