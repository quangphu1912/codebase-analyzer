# Tech Stack Diagnostic Guides

Analytical guides for extracting deep understanding from package manifests. Each guide provides read order, divergence interpretation, and worked examples.

---

## package.json Diagnostic Guide

**Read order:** scripts -> overrides/resolutions -> engines -> dependencies -> devDependencies

### What to read FIRST and why

1. **scripts** -- The actual build pipeline. If `"build": "webpack"` but `vite` is in devDependencies, the migration is incomplete. Scripts tell truth; declared deps can lie.
2. **overrides/resolutions** -- Each entry is a past conflict. Count them: 0-2 is normal, 3-5 indicates growing pain, 5+ signals dependency hell.
3. **engines** -- Deployment constraints. Absent engines with cutting-edge API usage (optional chaining, top-level await) means it only runs on developer machines.
4. **dependencies** -- What ships to production. Look for misplaced items: `jest` here means tests run in production.
5. **devDependencies** -- Build and dev tooling. Look for misplaced items: `lodash` here when it's imported in `src/` means the bundle is missing a runtime dep.

### Worked Example

```json
{
  "scripts": {
    "build": "webpack --mode production",
    "dev": "vite",
    "test": "jest"
  },
  "overrides": {
    "glob": "^9.0.0",
    "inflight": "npm:@jsdevtools/inflight@^2.0.0"
  },
  "engines": { "node": ">=16" },
  "dependencies": {
    "react": "^18.2.0",
    "lodash": "^4.17.21",
    "jest": "^29.0.0"
  },
  "devDependencies": {
    "vite": "^5.0.0",
    "webpack": "^5.90.0",
    "typescript": "^5.3.0"
  }
}
```

**Interpretation:**
- **Migration fossil:** Build uses webpack (`"build": "webpack"`) but dev server uses Vite. Migration started but not completed. Production and development use different toolchains.
- **Misplaced dependency:** `jest` in `dependencies` means it ships to production. Should be in `devDependencies`. Wastes bytes and may indicate bundler misconfiguration.
- **Override story:** `glob` overridden to v9 and `inflight` replaced with a fork -- someone hit a deprecation cascade from a transitive dependency. Two overrides is manageable.
- **Loose engine constraint:** `>=16` allows Node 16 (EOL) through 22+. No upper bound means untested runtime behavior on new versions.

---

## Cargo.toml Diagnostic Guide

**Read order:** [features] -> [dependencies] -> [dev-dependencies] -> [profile]

### What to read FIRST and why

1. **[features]** -- Conditional compilation gates. Feature flags with `default = []` and many optional deps reveal a library designed for minimal footprint. Feature explosion (20+) means the crate tries to be everything to everyone.
2. **[dependencies]** -- Direct dependencies. Look for `version` vs `path` vs `git` sources. Many `path` deps = workspace monorepo. `git` deps = unpublished crates or forked patches (supply chain risk).
3. **[dev-dependencies]** -- Test and bench tooling. Heavy dev-deps that duplicate runtime deps suggest poor abstraction boundaries.
4. **[profile]** -- Optimization settings. `opt-level = 0` in release = someone debugging in production. Custom profiles reveal CI or benchmark configurations.

### Worked Example

```toml
[package]
name = "my-service"
version = "0.4.2"
edition = "2021"

[features]
default = ["server"]
server = ["tokio/rt-multi-thread", "axum"]
cli = ["clap", "serde_json"]

[dependencies]
tokio = { version = "1", features = ["macros", "signal"] }
axum = "0.7"
serde = { version = "1", features = ["derive"] }
sqlx = { version = "0.7", features = ["postgres", "runtime-tokio"] }
my-common = { path = "../common" }
tracing-opentelemetry = { git = "https://github.com/example/tracing-opentelemetry", branch = "fix/span-bag" }

[dev-dependencies]
tokio = { version = "1", features = ["test-util"] }

[profile.release]
lto = "thin"
strip = true
```

**Interpretation:**
- **Controlled feature set:** Two features (server, cli) with clean separation. This crate has a clear dual-mode design.
- **Workspace monorepo:** `my-common = { path = "../common" }` means this is part of a larger workspace. Check the workspace root for shared config.
- **Git dependency risk:** `tracing-opentelemetry` pinned to a fork branch. This is an unreleased patch, likely for a bug blocking production. Track this -- it should be replaced with a versioned release once upstream merges.
- **Mature release profile:** LTO and strip enabled = optimized for binary size and runtime performance. The team cares about deployment footprint.

---

## go.mod Diagnostic Guide

**Read order:** module path -> require -> replace -> exclude

### What to read FIRST and why

1. **module path** -- The module's identity. A path like `github.com/company/project` tells you the repo structure. If it ends in `/v2` or `/v3`, the module has broken compatibility at least once.
2. **require block** -- Direct and indirect dependencies. `// indirect` comments mark transitive deps Go pulled in. Many indirect deps with specific versions = tight coupling to transitive graph.
3. **replace** -- Local overrides or forked dependencies. Each `replace` directive is a workaround: either a local dev override or a patched fork. In production modules, replace directives signal unmerged upstream fixes.
4. **exclude** -- Blacklisted versions. Used when specific dependency versions have known bugs. Absent exclude is normal; present exclude means the team hit a specific version bug.

### Worked Example

```
module github.com/acme/order-service/v2

go 1.22

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/lib/pq v1.10.9
    go.uber.org/zap v1.27.0
    github.com/prometheus/client_golang v1.19.0
    google.golang.org/grpc v1.62.1 // indirect
)

replace (
    github.com/acme/billing-client => ../billing-client
    github.com/some-lib/broken => github.com/acme/forked-lib v1.2.4-fix
)
```

**Interpretation:**
- **Major version in path:** `/v2` means this module has at least one breaking change from v1. Consumers must use a different import path.
- **Go version:** 1.22 is modern but not bleeding edge. Team balances new features with stability.
- **Mixed architecture:** `gin` (HTTP) + `grpc` + `pq` (PostgreSQL) + `zap` (logging) + `prometheus` (metrics) = a full-featured backend service with observability built in.
- **Replace directives:** Local billing client = monorepo development. Forked lib = an upstream bug is blocking them. Both are normal for active development but the fork should be tracked for removal.

---

## pyproject.toml / requirements.txt Diagnostic Guide

**Read order:** [tool.poetry] / build-system -> dependencies -> dev-dependencies / extras -> scripts

### What to read FIRST and why

1. **[tool.poetry] or build-system** -- Project manager identity. Poetry, setuptools, flit, hatch, or pdm. The choice reveals team maturity: Poetry/pdm = modern, setuptools = legacy, no section = requirements.txt only.
2. **dependencies** -- Runtime requirements. Look for version pin style: `^1.0` (compatible) vs `>=1.0,<2.0` (explicit range) vs `==1.0.3` (exact). Exact pins in pyproject.toml = someone got burned by a minor version break.
3. **dev-dependencies / extras** -- Test and dev tooling. Extras that install heavy ML deps (`[ml]`, `[gpu]`) reveal optional runtime modes.
4. **scripts / entry points** -- CLI entry points. These define what commands the package exposes. Absent entry points with `if __name__ == "__main__"` in source = script-style project, not distributable package.

### Worked Example

```toml
[tool.poetry]
name = "data-pipeline"
version = "3.1.0"
description = "ETL pipeline for analytics"

[tool.poetry.dependencies]
python = "^3.11"
pandas = "^2.2"
sqlalchemy = "^2.0"
psycopg2-binary = "^2.9"
redis = "^5.0"
pydantic = "^2.5"

[tool.poetry.group.dev.dependencies]
pytest = "^8.0"
mypy = "^1.8"
ruff = "^0.3"

[tool.poetry.extras]
gpu = ["torch>=2.1"]
spark = ["pyspark>=3.5"]

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

**Interpretation:**
- **Modern tooling:** Poetry with ruff and mypy = team invests in code quality tooling.
- **Python floor:** `^3.11` means 3.11 minimum. They use modern features (ExceptionGroup, Tomllib) but don't need 3.12 yet.
- **Optional heavy deps:** `gpu` and `spark` extras reveal this pipeline has multiple deployment modes: lightweight local, GPU-accelerated, and distributed. The core stays lean.
- **No entry points:** No `[tool.poetry.scripts]` section. This runs as an imported library or via task scheduler, not as a CLI tool.
- **Binary package:** `psycopg2-binary` (not `psycopg2`) = development convenience, not production-safe. Production should use the compiled version or `psycopg` (v3).
