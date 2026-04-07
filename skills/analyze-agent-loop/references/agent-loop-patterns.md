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

## Termination Conditions
- Max turns/iterations reached
- Stop sequence in model output
- User cancellation
- Error threshold exceeded
- Task completion signal
