# Dependency Metrics

## Fan-In / Fan-Out
- **Fan-In**: Number of modules that depend ON this module (incoming)
- **Fan-Out**: Number of modules this module depends ON (outgoing)
- **Stable**: High fan-in, low fan-out (many depend on it, it depends on little)
- **Volatile**: Low fan-in, high fan-out (few depend on it, it depends on many)

## Instability (I)
I = Fan-Out / (Fan-In + Fan-Out)
- I close to 0: Stable (hard to change, many dependents)
- I close to 1: Volatile (easy to change, few dependents)

## God Module Detection
- Fan-In > 20 AND Fan-Out > 10
- Contains > 500 lines
- Has > 15 exported functions
- Named "utils", "helpers", "common", or "shared"

## Circular Dependency Detection
1. Build adjacency list from import graph
2. Run DFS with visited + recursion stack
3. Back edges = cycles
4. Report: cycle length, modules involved, break point suggestions

## Direction Analysis (Architecture Alignment)

Map each import as "higher->lower" or "lower->higher" relative to your declared architecture layers. Typical layer ordering: `presentation > application > domain > infrastructure`.

```
domain/user.py imports infrastructure/database.py  -> LOWER->HIGHER (violation)
domain/user.py imports domain/email.py             -> same layer (acceptable)
application/service.py imports domain/user.py      -> HIGHER->LOWER (correct)
```

**Technique**: Assign each module a layer rank. For every edge (A->B), compare ranks. Flag any edge where the lower-ranked module imports the higher-ranked one. These violations indicate Dependency Inversion Principle breaches. Introduce an interface/abstraction in the lower layer to invert the dependency.

**Worked example**: In a Python project, `core/billing.py` directly imports `stripe/api.py`. This is a domain->infrastructure violation. Fix: define `PaymentGateway` protocol in `core/`, let `stripe/api.py` implement it, inject via constructor.

## Dependency Cluster Detection (Co-occurrence)

Modules that always appear together in import chains form a hidden bounded context.

**Technique**: For each module, collect the set of modules reachable within 2 hops. Compute Jaccard similarity between all pairs. Pairs with similarity > 0.7 are cluster candidates. Group into clusters of 3+ modules.

```
Module A reaches: {B, C, D, E}
Module B reaches: {A, C, D, F}
Jaccard(A,B) = |{C,D}| / |{A,B,C,D,E,F}| = 2/6 = 0.33 (not clustered)

Module X reaches: {Y, Z, W}
Module Y reaches: {X, Z, W}
Jaccard(X,Y) = |{Z,W}| / |{X,Y,Z,W}| = 2/4 = 0.5 (borderline, check Z and W)
```

**Worked example**: `auth/token.py`, `auth/permissions.py`, and `auth/session.py` all appear together in 8 of 10 import chains that touch any of them. This cluster suggests a bounded context "authentication" that should be evaluated as a unit before changes.

## Versioning Conflict Detection

Same transitive dependency at different versions across module boundaries = potential runtime inconsistency.

**Detection commands**:
- **npm**: `npm ls <package>` shows resolution tree; `npm dedupe` fixes duplicates
- **cargo**: `cargo tree -d` lists all duplicate dependencies
- **pip/poetry**: `pip check` detects version conflicts; `poetry show --tree` shows resolution
- **go**: `go mod graph | grep <module>` to check multiple versions

**Worked example**: `npm ls lodash` reveals:
```
├── lodash@4.17.21
└─┬ some-plugin@2.0.0
  └── lodash@3.10.1
```
Two versions of lodash in the same runtime. If `some-plugin` serializes data using lodash@3 and the main app deserializes using lodash@4, behavior can diverge. Flag for resolution via `npm dedupe` or `overrides` in package.json.
