# codebase-analyzer Plugin

## Architecture
- 20 skills + 2 agents
- Track A (reconnaissance) -> Track B (deep dive) -> System Intent
- Standard output contract in `docs/analysis/`

## Three Depths Model
- **Surface** (Track A): Fast structural scans, architecture maps
- **Deep** (Track B Phases 1-3): Git archaeology, gate extraction, behavior simulation
- **Intent** (Track B Phase 4): Reconstruct what the system was built to do

## Skill Standards
- Description field: starts with "Use when...", triggers only, no workflow summary
- Every skill writes to `docs/analysis/` using standard contract
- Trigger signals include: priority (high/med/low), confidence (high/med/low), evidence (file:line)

## Behavioral Engineering
- Skills are behavioral software, not reference documentation
- Every skill includes: announce line, red flags, output contract
- Critical skills include: Iron Law, rationalization table, HARD-GATE
- Description field: trigger-only (CSO rule), never summarize workflow

## File Naming
- Skills: `skills/<verb>-<noun>/SKILL.md`
- References: `skills/<verb>-<noun>/references/<topic>.md`
- Agents: `agents/<noun>.md`

## Testing
- RED-GREEN-REFACTOR for each skill
- Test against diverse repo types (web app, library, IaC, monorepo)
