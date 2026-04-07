# Prompt Control Patterns

## System Prompt Structures
- Static prompts: hardcoded string, never changes
- Template prompts: string with variables (user type, context, date)
- Composed prompts: multiple sections assembled at runtime
- Conditional prompts: sections included/excluded based on gates

## Prompt Variables
- {{user_type}}: external, internal, admin
- {{capabilities}}: list of available tools
- {{context}}: conversation history, retrieved docs
- {{instructions}}: behavioral guidelines

## Prompt vs Code Control Matrix

| Behavior | Prompt Can | Code Can | Gap Risk |
|----------|-----------|---------|----------|
| Refuse request | "Don't do X" (soft) | Block tool X (hard) | High if prompt-only |
| Limit scope | "Focus on Y" | Filter results to Y | Medium if partially coded |
| Style/tone | "Be professional" | N/A | Low risk |
| Safety | "Don't harm" | Output classifier + filter | Critical if prompt-only |
| Capability | "You can do X" | Tool X exists in code | Medium if misaligned |
