# Agent Loop Patterns

## Standard Agent Loop
```
while not terminated:
    1. Receive input (user message, tool result)
    2. Build context (conversation history + system prompt)
    3. Call LLM/model
    4. Parse response (text + tool calls)
    5. If tool calls: execute tools, append results, go to 1
    6. If text only: return to user
    7. Check termination (max turns, stop sequence, user cancel)
```

## State Machine Pattern
- States: IDLE, THINKING, EXECUTING_TOOL, WAITING_INPUT, COMPLETED, ERROR
- Transitions triggered by: new message, tool result, error, timeout
- Persistence: state stored in conversation object or separate state store

## Tool Dispatch Patterns
- Registry: { tool_name: handler_function } mapping
- Dynamic: tools resolved at runtime from config or capability query
- Conditional: some tools only available based on state/permissions
- Chained: tool A output feeds directly to tool B

## Continuation Patterns
- Re-entrant: same function called again with tool output
- Recursive: nested processing of tool results
- Event-driven: tool completion triggers next step via event
- Queue-based: tool requests queued, processed in order

## State Machine Decomposition Techniques

### Full State Enumeration
1. Read the loop body and identify every branching path -- each branch is a potential state
2. Name each state explicitly (even if the code does not)
3. For each state, document: entry condition, actions, exit transitions, error paths
4. Draw the transition graph -- look for states with no exit (stalls), unreachable states (dead code), and cycles without escape (infinite loops)

### Implicit State Detection
Code that uses flags, counters, or conditionals to manage flow often implements an implicit state machine. Detect these patterns:
- `if (waiting_for_tool) ... else if (processing) ...` -- explicit states disguised as conditionals
- Variables like `phase`, `step`, `status` -- implicit state variables
- Error retry counters and backoff flags -- implicit ERROR and RATE_LIMITED states
- Streaming or partial-response flags -- implicit STREAMING state

### Transition Guard Analysis
Every transition has a trigger and a guard. The trigger is the event; the guard is the condition that must be true. Map guards to find:
- Preconditions that can never be satisfied (dead transitions)
- Guards that overlap (non-deterministic behavior)
- Missing guards (unrestricted transitions leading to invalid states)

## Turn Loop Tracing Patterns

### Turn Counter Tracing
For each turn in the loop, record:
```
Turn N:
  Input: <message type and source>
  State entry: <state at start of turn>
  Decision: <what the processing logic chose>
  Tool calls: <ordered list, with continuation depth>
  State exit: <state at end of turn>
  Context delta: <what changed in conversation state>
```

### Continuation Depth Mapping
Tool calls can chain: tool A result feeds into tool B within the same turn. Map the depth:
```
Turn 3:
  Tool call: read_file("config.json")          [depth 1]
  Continuation: parse_result -> extract_paths   [depth 2]
  Continuation: read_file(paths[0])             [depth 3]
  No more tool calls -> return to user
  Max continuation depth: 3
```

High continuation depth (>5) signals potential infinite-loop risk or missing early-exit conditions.

### Termination Condition Analysis

**Categories of termination:**
| Category | Trigger | Risk |
|----------|---------|------|
| Max-turns guard | Counter exceeds limit | Safe but may truncate work |
| Completion signal | Model outputs stop sequence or "done" token | Safe if model is reliable |
| User cancellation | External abort event | Safe, requires event handling |
| Error threshold | Consecutive errors exceed limit | Safe if counter resets correctly |
| Token budget | Total tokens exceed budget | Safe, prevents cost overruns |
| Empty response | Model returns no content | Rare, may cause stall |

**Infinite loop causes:**
1. **Missing break condition** -- loop checks no termination signal
2. **Replay loop** -- tool result always triggers the same tool call with identical input
3. **State stuck** -- transition guard never satisfied, loop spins in same state
4. **Counter reset** -- error recovery resets turn counter, preventing max-turns escape
5. **Recursive continuation** -- tool chain has no base case

**Audit checklist:**
- [ ] Max-turns guard exists and is enforced in code (not just prompt)
- [ ] Completion signal is checked after every turn
- [ ] Error paths terminate or retry with bounded attempts
- [ ] No state can cycle without making progress (no-op cycles)
- [ ] Token/cost budget prevents unbounded API calls
- [ ] User cancellation propagates into the loop

## Termination Conditions
- Max turns/iterations reached
- Stop sequence in model output
- User cancellation
- Error threshold exceeded
- Task completion signal
