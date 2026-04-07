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
