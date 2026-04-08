# Anti-Pattern Catalog

## Structural Anti-Patterns

| Anti-Pattern | Detection Heuristic | Risk |
|-------------|---------------------|------|
| God class | >500 lines, >15 exported functions, >10 imports | High coupling, change ripple |
| Long method | Functions >50 lines | Hard to understand, test, maintain |
| Deep nesting | >4 levels of indentation | Cognitive complexity, hidden bugs |
| Feature envy | Method accesses more fields of another class than its own | Poor encapsulation |
| Duplicated code | Similar blocks in 3+ files | Fix-here-not-there bugs |
| Missing error handling | IO operations without try/catch or error checks | Silent failures |
| Callback/Promise hell | >3 levels of nested callbacks or .then() chains | Unreadable flow |
| Magic numbers/strings | Unnamed constants scattered in code | Hard to understand intent |

## Churn-Complexity Correlation Methodology

Individual metrics lie. A 500-line file that never changes is irrelevant. A 50-line file that changes every sprint and has cyclomatic complexity 20 is your highest risk. The correlation between churn and complexity is the single strongest bug predictor.

### Producing the Churn-Complexity Matrix

1. **Extract churn**: Run `git log --format='%H' --name-only` over the analysis window (e.g., last 90 days). Count commits per file.
2. **Extract complexity**: For each file, count decision points (if/for/while/switch/catch) as a proxy for cyclomatic complexity.
3. **Plot the matrix**: X-axis = commit count, Y-axis = complexity. Files cluster into four quadrants:

```
High Complexity
       |  BUG FACTORY    |  DORMANT BEAST
       |  (high churn,   |  (low churn,
       |   high complex) |   high complex)
       |                  |
-------+------------------+------------------ High Churn
       |                  |
       |  CONFIG HUB      |  STABLE CORE
       |  (high churn,    |  (low churn,
       |   low complex)   |   low complex)
       +----------------------------------- Low Churn
```

### Interpreting the Quadrants

| Quadrant | Response |
|----------|----------|
| Bug Factory | Refactor first. Every commit risks regression. |
| Dormant Beast | Risk if touched. Document complexity before changes. |
| Config Hub | Acceptable. High churn is expected for config. |
| Stable Core | Low priority. Monitor for drift. |

## Quality Gradient Detection

Quality degrades from the edges of a codebase inward. Entry points (API handlers, CLI commands, controllers) tend to be well-maintained because they are visible and exercised. Internal layers (services, data access, utilities) accumulate debt because they are less visible and tested indirectly.

### How to Detect the Gradient

1. **Classify files by layer**: Map files to architectural tiers (edge, service, data, utility).
2. **Compute quality per layer**: Average complexity, error-handling ratio, test coverage per tier.
3. **Compare edge vs core**: If edge quality is significantly higher than core quality, debt is hiding in the middle.

A steep gradient (polished edges, rotten core) is more dangerous than uniform moderate quality because refactorings that reach the core encounter unmaintained, undertested code with no safety net.

## Worked Example: Identifying a Bug Factory

Given a 90-day git history, the analysis produces this churn-complexity data:

```
File                        Commits  Complexity  Quadrant
src/api/auth/handler.go        12        8        Config Hub
src/services/user/service.go   18       24        Bug Factory
src/services/order/service.go  15       31        Bug Factory
src/db/models/order.go          3       12        Stable Core
src/middleware/auth.go          9       19        Bug Factory
src/utils/validators.go         7        5        Config Hub
```

**Interpretation**: `order/service.go` and `user/service.go` are the highest-risk files. Both change frequently and have high complexity. The auth middleware also falls in the bug factory quadrant -- and since it handles authentication, this maps to the SECURITY_SIGNAL pattern (high churn in security files = unstable security posture).

**Action**: Prioritize `order/service.go` for decomposition (highest complexity in bug factory). Flag `middleware/auth.go` as a security concern. Leave `validators.go` alone (config hub, acceptable churn).
