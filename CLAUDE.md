# codebase-analyzer Plugin

## Architecture
- 14 skills + 2 agents
- Track A (reconnaissance) -> Track B (deep dive) -> Synthesis
- Standard output contract in `docs/analysis/`

## Skill Standards
- Bootstrap skill: 250-350 words
- Track A skills: <300 words + references
- Track B skills: <400 words + references
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
