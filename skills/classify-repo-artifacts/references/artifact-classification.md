# Artifact Classification Heuristics

## Core Indicators
- Contains domain-specific logic (not framework boilerplate)
- Files that import from support/ but are not imported by infrastructure/
- Contains business rules, validation logic, data transformation
- Named after domain concepts (not "utils" or "helpers")

## Support Indicators
- Generic utility functions (formatDate, debounce, deepClone)
- Shared types and interfaces
- Re-export files (index.ts that re-exports from sub-modules)
- Framework adapters and wrappers

## Generated Indicators
- Provenance map marks as derived
- "DO NOT EDIT" or "@generated" in file header
- Located in dist/, build/, generated/, __generated__/
- Produced by codegen tools listed in build pipeline

## Test Indicators
- File matches *.test.*, *.spec.*, *_test.*
- Contains describe(), it(), test(), expect() calls
- Located in test/, tests/, __tests__/, spec/
- Contains mock data and fixtures

## Infrastructure Indicators
- Dockerfile, docker-compose.yml
- .github/workflows/, Jenkinsfile, .gitlab-ci.yml
- k8s/, terraform/, cloudformation/
- Makefile, scripts/, tools/
