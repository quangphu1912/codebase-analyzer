---
name: analyze-agent-loop
description: Use when tracing turn loops, tool continuations, state transitions, or understanding how an AI agent or complex system actually processes requests through its execution cycle
---

## Announce at start: "Using codebase-analyzer to analyze the agent loop."

## Overview

Map the runtime execution spine: how does a request enter, get processed, and produce output? Identify the turn loop, state machine, and tool continuation patterns.

**Prerequisite:** Reads `docs/analysis/artifact-classification.md` (need to know core vs support).

## Process

1. Identify the main entry point and request handler
2. Trace the turn/request loop: input -> processing -> tool call -> response -> next turn
3. Map state transitions: idle -> active -> waiting -> responding -> idle
4. Find tool continuation patterns: when does the system call another tool after receiving output?
5. Identify termination conditions: when does the loop stop?
6. Find state persistence: what survives between turns?
7. Produce execution spine diagram

## Quick Reference

| Component | What To Find |
|-----------|-------------|
| Entry point | Main function, request handler, message listener |
| Turn loop | while/for loop processing messages, recursive call pattern |
| State machine | switch/if-else on state, state object transitions |
| Tool dispatch | function call mapping, tool registry lookup |
| Continuation | re-entry after tool output, message chaining |
| Termination | break condition, max turns, completion signal |
| Persistence | state saved between turns, conversation history |

## Trigger Signals

- **HIGH confidence**: Conditional tool availability in the loop -> `map-conditional-behavior`
- **HIGH confidence**: State transitions gated by conditions -> `map-conditional-behavior`
- **MEDIUM confidence**: Complex multi-step processing -> refactoring candidate
- **LOW confidence**: Simple linear processing -> no deep dive needed

## Red Flags

- Only tracing the happy path, missing error/retry branches
- Not identifying state persistence mechanisms
- Missing the tool dispatch/registration pattern

## Output Contract

Write `docs/analysis/agent-loop.md` using standard contract.
Include: execution spine diagram, state machine, turn loop flow, termination conditions.
