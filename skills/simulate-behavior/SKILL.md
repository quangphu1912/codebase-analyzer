---
name: simulate-behavior
description: Use when predicting how a system behaves under different conditions, testing "what if" scenarios for gate combinations, or comparing behavioral fingerprints across configurations
---

## Announce at start: "Using codebase-analyzer to simulate behavior."

## Overview

Given a tool graph and gate map, predict behavior under different gate combinations. This is where analysis becomes prediction: you're not just mapping what exists, you're simulating what WOULD happen.

**Prerequisites:** Reads `docs/analysis/tool-graph.md` and `docs/analysis/gate-map.md`. Requires both Phase 3 prior skills complete.

## Behavioral Fingerprinting

For each gate combination, produce a behavioral fingerprint:

1. **Available tools** — which tools are active under this combination
2. **Active code paths** — which execution branches are reachable
3. **Accessible data** — what data stores, APIs, and resources are reachable
4. **Exposed capabilities** — what the system can actually do in this state

Compare fingerprints to find surprising differences. Two configurations that look similar may have radically different behavioral profiles.

## Temporal Analysis

How does behavior change over time?

1. **Feature flags** that are on in dev but off in prod
2. **Capabilities scheduled for removal** — deprecated tools still reachable
3. **Time-bombed code** — trial features, expiration logic, rollout schedules
4. **Environment drift** — config differences between dev/staging/production

## State-Space Exploration

Enumerate gate combinations systematically. For N binary gates, there are 2^N possible states. Prioritize exploration:

| Priority | Category | Example | Why |
|----------|----------|---------|-----|
| 1 | Most likely states | Production config | This is what users actually experience |
| 2 | Most surprising states | Admin + external | Capability escalation risk |
| 3 | Most different from baseline | All gates open | Reveals full attack surface |
| 4 | Edge cases | Single gate flipped | Isolation failure detection |

**Pruning:** For large gate counts, group gates by domain (auth, features, providers) and explore intra-domain combinations exhaustively, inter-domain combinations at boundaries only.

## Dispatch Rule

Dispatch `behavior-simulator` agent with gate map + scenarios. Agent traces code paths per scenario, recording:

- Entry points reachable under each combination
- Data flows activated or blocked
- Side effects triggered (file writes, network calls, state mutations)
- Error paths that become reachable

The agent should produce a scenario comparison table showing behavioral differences side-by-side.

## SECURITY_SIGNAL

Gate combinations that warrant immediate attention:

- Combinations exposing admin tools to external/unauthenticated users
- Production configs that skip authentication or authorization checks
- Capability escalation via gate manipulation (user-controlled gate values)
- Combinations where audit logging is disabled alongside sensitive operations
- States where data exfiltration paths become reachable

## Red Flags

- Only testing the default configuration — you're missing the edge cases that attackers exploit
- Not testing adversarial gate combinations — assume gates can be manipulated
- Ignoring compound effects — two benign gates together may create a vulnerability
- Treating all states as equally likely — focus effort on likely + dangerous intersections
- Skipping temporal analysis — behavior changes over time, not just across configs

## Output Contract

Write `docs/analysis/behavior-simulation.md` with:

- Scenario inventory (gate combinations tested)
- Behavioral fingerprints per scenario
- Scenario comparison table
- Temporal analysis findings
- Security signals discovered
- Recommendations for gate hardening
