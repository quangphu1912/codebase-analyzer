# Intent Signal Patterns

## Core Principle

Code tells you what a system does. Structure tells you what it was designed to become. The gap between the two reveals intent.

## Intent Signal Patterns

### Abandoned Features Reveal Planned Direction

Abandoned code is not noise -- it is a roadmap of attempted directions.

**What to look for:**
- Feature branches that were merged then reverted
- Dead code behind feature flags that are always off
- TODO comments with future-dated milestones
- Partially implemented interfaces with stub methods
- Commented-out configuration for unreleased features

**How to read it:**
- A feature built 80% then abandoned reveals the direction better than a feature shipped at 100%
- The *why* of abandonment matters: technical debt (will revisit), strategic pivot (dead direction), regulatory (blocked externally)
- Look for patterns: multiple abandoned features pointing toward the same capability reveal sustained intent

**Example signals:**
```
// Phase 2: Enterprise SSO integration (paused Q3)
// TODO: Re-enable when enterprise tier launches
if (config.tier === 'enterprise') { /* stub */ }
```

### Gate Complexity Reveals Competitive Sensitivity

The more complex the gating mechanism, the more strategically important the capability.

**Gate complexity spectrum:**

| Complexity | Example | Inference |
|-----------|---------|-----------|
| Simple boolean | `if (featureEnabled)` | Standard feature flag |
| Multi-condition | `if (tier && region && rolloutPct)` | Carefully controlled release |
| Remote-evaluated | `if (server.evalGate(user, feature))` | Server-controlled access |
| Cryptographic | `if (verifyLicense(key, feature))` | Revenue-protected capability |
| Computed | `if (mlModel.predict(eligibility) > threshold)` | Behaviorally-controlled access |

**How to read it:**
- Simple gates on complex capabilities suggest late-stage feature trimming
- Complex gates on simple capabilities suggest those capabilities are strategically important
- Server-side gates mean the capability can be revoked or modified without client updates
- Gates that vary by geography suggest regulatory or competitive fencing

### Hidden APIs Reveal Integration Strategy

Undocumented or conditionally-exposed APIs show where the system intends to integrate.

**What to look for:**
- API routes defined but not listed in documentation generation
- Endpoints that respond to different auth mechanisms than the public API
- Internal service-to-service communication protocols
- Protobuf/gRPC definitions without REST counterparts
- WebSocket channels with no UI component consuming them

**How to read it:**
- Internal APIs that are more capable than public APIs suggest a platform play (third-party integrations planned)
- APIs that accept richer payloads than the UI generates suggest the UI is a subset of the planned experience
- Service-to-service APIs that cross organizational boundaries suggest partner/ecosystem strategy
- Versioned internal APIs (v1, v2) suggest long-term integration commitments

## Moat Detection Heuristics

### Where Is the Moat?

The moat is the capability that is hardest to replicate and most central to the system's value.

**Detection method:**

1. **Map where complexity lives**
   - Count cyclomatic complexity by module/layer
   - The layer with disproportionate complexity is likely the moat

2. **Map where data flows converge**
   - Trace data from all inputs to all outputs
   - The convergence point is where value is created (and where the moat is)

3. **Map what the service layer controls**
   - Capabilities that require server round-trips are server-controlled
   - The more the server controls, the more the moat is in the backend

4. **Map what changes frequently**
   - High-churn areas are actively developed (competitive advantage in progress)
   - Stable areas may be mature or abandoned (check git blame for recency)

### Moat Location Patterns

| Signal | Client Moat | Service Moat | Ecosystem Moat |
|--------|------------|-------------|----------------|
| Complex local algorithms | Yes | No | No |
| Server-side model inference | No | Yes | No |
| API rate limits | No | Yes | Maybe |
| Plugin/extension system | Maybe | No | Yes |
| Data network effects | No | Maybe | Yes |
| Lock-in via proprietary format | Yes | No | Maybe |
| Telemetry dependency | No | Yes | Yes |

## Confidence Weighting for Evidence

### Confidence Levels

| Level | Meaning | Action |
|-------|---------|--------|
| **High** | Multiple independent sources confirm, structural evidence supports | State as finding |
| **Medium** | Single strong source or multiple weak sources | State as hypothesis with evidence gaps |
| **Low** | Speculative, based on pattern matching alone | State as possibility, flag for investigation |

### Confidence Boosters

These increase confidence in a finding:
- Structural evidence (architecture) supports behavioral evidence (code patterns)
- Multiple independent code paths lead to the same conclusion
- Git history shows sustained investment in the capability over time
- The finding is consistent with the system's market positioning

### Confidence Reducers

These decrease confidence:
- Single source of evidence
- Evidence could be explained by coincidence or standard practices
- Contradictory evidence exists (note both sides)
- The system is early-stage and intent may not yet be formed

### Evidence Combination Rules

- **High + High** = High (strengthened)
- **High + Medium** = High
- **High + Low** = Medium (the Low source introduces doubt about specificity)
- **Medium + Medium** = Medium-High (converging evidence)
- **Medium + Low** = Medium
- **Low + Low** = Low (insufficient, flag as speculation)

When sources conflict, confidence drops one level and both positions are documented.

## Applying Intent Signals to the Five Questions

### What Is This System Designed to Become?

Best answered by: evolution evidence + gate complexity + hidden APIs
Confidence base: Medium (architecture is structural, but future intent is inherently uncertain)
Booster: if multiple abandoned features point in the same direction

### Where Is the Moat?

Best answered by: complexity distribution + data flow convergence + service-layer control
Confidence base: Medium-High (structural evidence is strong)
Reducer: if the system is a thin client wrapper, the moat may be external

### What Can It Do That It Does Not Expose?

Best answered by: conditional behavior analysis + dead code inventory
Confidence base: Medium (code exists, but intent behind dormancy is ambiguous)
Booster: if dormant capabilities have complex implementations (not stubs)

### How Is Behavior Really Controlled?

Best answered by: prompt influence analysis + gate mapping
Confidence base: Medium (control mechanisms are observable, but remote control is invisible)
Reducer: if the system has server-driven configuration, some control is unobservable

### What Are the Hidden Dependencies?

Best answered by: provenance analysis + build pipeline analysis
Confidence base: High (dependencies are concrete, observable in build config)
Reducer: if runtime dependencies are loaded dynamically or from remote sources
