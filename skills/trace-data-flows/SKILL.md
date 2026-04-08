---
name: trace-data-flows
description: Use when tracking how data enters, transforms, persists, and exits a system, or when investigating trust boundaries, validation gaps, and potential data exfiltration paths
---

Using codebase-analyzer to trace data flows.

## Overview

Follow the data, not the code. Code shows structure; data shows behavior. Where does untrusted data enter? Where is it validated? Where does it influence control flow? Where does it persist? Where does it exit?

Every bug is data taking an unexpected path. Every vulnerability is data reaching a dangerous destination without proper clearance.

## Prerequisites

Read these files first for context:
- `docs/analysis/tech-stack.md` — framework conventions for data handling
- `docs/analysis/build-pipeline.md` — build-time vs runtime data boundaries

## Five-Stage Data Flow Trace

### 1. Entry — Where Does External Data Arrive?

Map every point where data crosses the system boundary:

- **HTTP parameters** — query strings, headers, cookies, request bodies (JSON/form)
- **File uploads** — multipart data, file paths from user input
- **Environment variables** — configuration injected at runtime
- **IPC / message queues** — data from other services, event streams, pub/sub
- **Database reads** — data previously stored may have been poisoned
- **API responses** — third-party data is untrusted by definition

For each entry point, record: the source, the data shape expected, and the trust level assigned.

### 2. Validation — Where Is Data Checked?

If at all. Gaps between entry and usage are injection risks.

Search for:
- Schema validation (Zod, Joi, Pydantic, protobuf, JSON Schema)
- Input sanitization (escaping, trimming, type coercion)
- Allowlist validation (enum checks, regex patterns)
- Authorization checks (can this user access this data?)

**Critical**: Note every entry point that has NO corresponding validation before the data is used. These are vulnerabilities.

### 3. Control Flow — Where Does Data Influence Execution?

This is where injection lives. When untrusted data determines what code runs:

- **SQL queries** — string interpolation, concatenation in query building
- **Shell commands** — data passed to `exec()`, `system()`, backtick operators
- **Template rendering** — data injected into HTML (XSS), templates (SSTI)
- **Dynamic dispatch** — data used as function names, class names, file paths
- **Configuration** — data that alters application behavior (feature flags, routing)
- **Deserialization** — data decoded into objects (pickle, YAML.load, unserialize)

For each control-flow influence point, verify the data passed through validation first.

### 4. Persistence — Where Is Data Stored?

What schema enforces shape? What constraints prevent poisoning?

- **Databases** — column types, constraints, foreign keys, CHECK constraints
- **File system** — file names, paths, content types, size limits
- **Caches** — TTL, invalidation, cache poisoning potential
- **Session stores** — session fixation, session data tampering
- **Logs** — logged data is stored data (see side-channel analysis)

Check whether stored data is re-validated on read, or implicitly trusted because "it came from our database."

### 5. Exit — Where Does Data Leave?

Data leakage and exfiltration risks at every output boundary:

- **API responses** — sensitive fields included in responses, verbose error messages
- **Logging** — PII in log lines, secrets in error traces, debug output in production
- **Metrics** — behavioral patterns revealed through metric labels and values
- **Error messages** — internal state exposed to users, stack traces in responses
- **Redirect URLs** — open redirect via user-controlled data
- **Email / notifications** — user data sent to unintended recipients

For each exit point, verify: Is only the intended data leaving? Are sensitive fields redacted?

## Trust Boundary Mapping

At each transformation point, ask:

1. **What is the trust level of the incoming data?** (Untrusted / Partially trusted / Trusted)
2. **What is the trust level assumed on the other side?**
3. **Is the trust level changing?** — Data going from "untrusted" to "trusted" without validation is a vulnerability.
4. **Is there an explicit gate?** — Validation, sanitization, authorization. If not, flag it.

Common trust boundary violations:
- Data from a third-party API treated as trusted without validation
- Database reads treated as trusted (attacker may have poisoned the data)
- Internal service-to-service calls assumed safe (lateral movement risk)
- Configuration files treated as immutable (may be editable by other processes)

## Side-Channel Data Flows

These are data flows too. They often bypass normal security review:

- **Logging statements** that include user data, session tokens, PII
- **Error messages** that expose internal state, stack traces, file paths
- **Metrics** that reveal behavioral patterns, user counts, feature usage
- **Debug endpoints** that dump application state in non-production environments
- **CORS headers** that allow credential-bearing requests to external origins
- **Cache headers** that expose sensitive data to intermediary caches

Search the codebase for:
- Logger calls that interpolate user-supplied values
- Error handlers that return raw exceptions to clients
- Metric instrumentation that includes user identifiers
- Debug/trace endpoints accessible in production

## Dispatch Rule

If a data flow spans 5+ files across different subsystems, dispatch `code-explorer` agent to trace the full chain. Provide:
- The entry point file and function
- The data shape at entry
- The suspected validation points
- The exit point if known

The agent should return: the complete data path, any validation gaps, and trust boundary violations.

## SECURITY_SIGNAL

All findings produced by this skill are security-relevant. There is no "informational only" category for data flow analysis. Even seemingly benign observations (e.g., "this data is logged without redaction") represent security exposure.

## Red Flags

Stop and investigate immediately when you encounter:

1. **No validation between entry and control flow** — Data reaches code execution without any check. This is a confirmed injection vector.
2. **Data flowing to exit without passing through any check** — User data appears in responses, logs, or external calls without sanitization or authorization.
3. **Trust level changing without explicit gate** — Code assumes data is trusted without evidence of validation. Often appears as "data from database = safe" or "internal API = trusted."
4. **Validation present but bypassable** — Allowlist that can be circumvented, regex that does not cover all cases, type coercion that changes meaning.
5. **Side-channels carrying sensitive data** — Logging, metrics, or error messages that include PII, secrets, or user-controlled data without redaction.
6. **Missing trust boundary at service edge** — Internal services accepting data from each other without validation, enabling lateral movement.

## Output Contract

Write findings to `docs/analysis/data-flows.md` with the following structure:

```
# Data Flow Analysis

## Entry Points
(For each: source, data shape, trust level, file location)

## Validation Map
(For each entry point: validation present? location? type? gaps?)

## Trust Boundaries
(For each boundary: from trust level, to trust level, gate present, violations)

## Control Flow Influences
(For each: data source, influence point, risk level, validation status)

## Persistence Points
(For each: storage type, schema enforcement, re-validation on read)

## Exit Points
(For each: destination, data included, sensitive data risk, redaction status)

## Side-Channel Flows
(Logging, metrics, errors that carry user data)

## Findings Summary
(Critical / High / Medium / Low with specific file locations and remediation)
```

## Reference

- [data-flow-patterns.md](references/data-flow-patterns.md) — Framework-specific entry points, validation patterns, trust boundary markers, and exfiltration catalogs.
