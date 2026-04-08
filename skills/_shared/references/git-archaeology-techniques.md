# Git Archaeology Techniques

Practical guide for extracting behavioral evidence from version control history. Each technique reveals something imports and type systems cannot: the human decisions, abandoned attempts, and evolutionary pressure that shaped the codebase.

## 1. Commit Archaeology

**Command:** `git log --all --diff-filter=D -- '<pattern>'`

**What it reveals:** Deleted files, abandoned branches, and renamed abstractions -- the fossil record of decisions that didn't survive. Dead files tell you what the team tried and rejected. Abandoned branches reveal features that were started but never shipped. Renamed files expose how mental models evolved.

**Worked example:**

```bash
git log --all --diff-filter=D -- 'src/services/*.ts'
# abc1234 2024-08-15 Remove payment-provider service
# def5678 2024-06-22 Delete legacy auth adapter
```

**Interpretation:** Two deleted services in `src/services/`. The payment provider removal in August suggests a provider switch -- look for a replacement file committed around the same date. The "legacy auth adapter" deletion in June likely corresponds to a migration: find the commit that added its replacement to understand the auth architecture transition. Use `git log --follow -- <current-file>` to trace renames and see the full evolution of an abstraction, including when `UserManager` became `AccountService` (a naming evolution that reveals shifting domain understanding).

**Additional patterns:**
- `git branch -a --no-merged origin/main` -- branches never merged are abandoned features worth understanding
- `git log --all --diff-filter=R --summary` -- renamed files reveal evolving abstractions
- `git log --follow --all -- <file>` -- full history including renames, shows how a concept evolved

## 2. Churn Correlation

**Command:** `git log --format='%H' --name-only | awk '{files[$0]++} END {for(f in files) print files[f], f}' | sort -rn | head -20`

**What it reveals:** Files that change together define hidden module boundaries. When two files have no import relationship but always appear in the same commits, you've found a coupling that the code structure hides. High-churn files are either central to the system (healthy) or poorly factored (unhealthy) -- the difference matters.

**Worked example:**

```
47 src/api/routes/users.ts
47 src/api/routes/admin.ts
45 src/middleware/auth.ts
31 src/config/database.ts
28 src/utils/logger.ts
```

**Interpretation:** `users.ts` and `admin.ts` change together in every commit (identical count of 47). This is expected if they share a domain, but verify: if `admin.ts` only calls user endpoints through `users.ts`, they're coupled by design. The real signal is `auth.ts` at 45 -- it changes in 96% of the same commits. This means authentication logic is entangled with route changes, suggesting auth checks are inline rather than declarative. `database.ts` at 31 changing less frequently suggests schema changes are decoupled from API changes (healthy). `logger.ts` at 28 with no domain pattern suggests logging is touched opportunistically during other work.

**Diagnostic follow-up:** `git log --format='%H %s' -- <file1> <file2> | grep -c <file1>` vs actual commit count reveals if files truly co-change or just both have high churn independently.

## 3. Ownership Archaeology

**Command:** `git shortlog -sn -- <path>`

**What it reveals:** How many people have touched a file and how much each contributed. A file with 8 authors in 8 different styles has ownership ambiguity -- no single person feels responsible for it, so it accumulates inconsistencies. A file with 1 author who left the company is a knowledge silo.

**Worked example:**

```
git shortlog -sn -- src/core/engine.ts
  142  Alice Chen
   89  Bob Martinez
   34  Carol Singh
   28  David Kim
   15  Eve Johnson
   12  Frank Wu
    8  Grace Lee
    3  Hassan Ali
```

**Interpretation:** Eight authors on one file. Alice owns 42% and Bob owns 26% -- the top two authors cover 68%. This is a "shared ownership with primary maintainers" pattern. The risk: the bottom 6 authors (33% of changes) likely didn't understand the full context before modifying. Check commit messages from those authors -- if they're all "fix typo" or "small tweak", the ownership is healthy. If they include "refactor engine flow" or "fix race condition in core loop", those authors made significant changes without full context, which explains inconsistency.

**Key patterns to watch:**
- 1 author, 100% -- knowledge silo, bus factor of 1
- 2-3 authors, balanced -- healthy shared ownership
- 8+ authors with declining commits -- orphaned file with no clear owner
- Recent author rotation (check last 6 months) -- ownership transfer in progress

## 4. Message Archaeology

**Command:** `git log --oneline --grep='<pattern>'`

**What it reveals:** Repeated fix patterns in commit messages expose systemic problems. A single "fix auth bug" is an incident. Five "fix auth" commits across three months is a systemic design flaw that patches cannot solve.

**Worked example:**

```
git log --oneline --grep='fix(auth)'
# e4a2b3c fix(auth): handle expired token edge case
# 7c1d9f0 fix(auth): prevent session override on concurrent login
# a3b8e12 fix(auth): redirect after token refresh
# 9f0c345 fix(auth): scope JWT claims to current org
# 2d7ef89 fix(auth): clear stale session on role change
```

**Interpretation:** Five auth fixes in recent history. Each addresses a different symptom -- expired tokens, concurrent sessions, refresh redirects, claim scoping, role changes. The common thread: the auth system treats session state as atomic when it's actually eventful. Each fix patches one state transition that the original design didn't anticipate. The systemic solution is an auth state machine, not another edge-case patch.

**Search patterns worth running:**
- `git log --oneline --grep='fix\|bug\|hotfix' | wc -l` vs total commits -- fix ratio (healthy: <20%, concerning: >35%)
- `git log --oneline --grep='hack\|workaround\|temp\|FIXME'` -- acknowledged technical debt
- `git log --oneline --grep='revert'` -- reverted changes reveal integration instability

## 5. Temporal Correlation

**Command:** `git log --format='%H %ai --name-only' | <group-by-timestamp>`

**What it reveals:** Files committed with identical timestamps were staged together, which means the developer treated them as one logical change. When files change together in time but not in import graph, you've found hidden coupling: shared configuration, implicit contracts, or build-time dependencies that the module system doesn't enforce.

**Worked example:**

```
2024-09-15 14:23:01  src/models/user.ts
2024-09-15 14:23:01  src/models/session.ts
2024-09-15 14:23:01  migrations/0042_add_user_preferences.sql
2024-09-15 14:23:01  src/api/routes/profile.ts
```

**Interpretation:** Four files in one commit. `user.ts` and `session.ts` are related by domain (expected). But `migrations/0042_add_user_preferences.sql` and `src/api/routes/profile.ts` are in the same commit -- the profile route depends on a database column that the migration adds. This coupling is invisible in the code: the route file never imports the migration. If someone adds the profile route to a branch without the migration, it fails at runtime (not compile time). This is a schema-code coupling that should be documented or enforced.

**Practical extraction:**

```bash
# Find files that always appear together
git log --name-only --pretty=format: | awk '
  NF==0 {commit++; next}
  {files[commit][$0]=1}
  END {
    for(c in files) for(f in files[c]) count[f]++
    for(f in count) print count[f], f
  }
' | sort -rn | head -20
```

## 6. Dead Code Stories

**Command:** `git log -p -- <file>`

**What it reveals:** The WHY behind dead code -- not just that code is unused, but the story of how it died. This determines removal safety: behind a feature flag (might reactivate), recently deleted (changed requirement), commented out (broken migration, might need reference).

**Worked example:**

```
git log -p -- src/features/billing/tiered-pricing.ts
# 2024-09-01 Remove tiered pricing (replaced by flat-rate model)
#   - Deleted entire file
#
# 2024-08-15 Comment out volume discount calculation
#   - // TODO: re-enable after enterprise pricing review
#
# 2024-07-20 Add tiered pricing behind BILLING_V2 flag
#   - if (features.BILLING_V2) { ... }
```

**Interpretation:** The file tells a story in reverse chronological order: (1) July: tiered pricing was added behind a feature flag -- the team was experimenting. (2) August: the volume discount was commented out with a TODO referencing an enterprise review -- the experiment hit a business constraint. (3) September: the whole file was deleted, replaced by a flat-rate model. The dead code is safe to keep removed. But the TODO about "enterprise pricing review" signals a future requirement -- check if the flat-rate model accounts for enterprise tiers.

**Dead code classification from history:**

| History Pattern | What It Means | Removal Safety |
|----------------|---------------|----------------|
| Behind feature flag, flag still in config | May reactivate | LOW -- verify flag status |
| Deleted in recent commit (<30 days) | Changed requirement | MEDIUM -- check if requirement is stable |
| Commented out with TODO/FIXME | Intentionally preserved | LOW -- check if TODO is still relevant |
| Unreachable for >6 months, no related flags | Truly dead | HIGH -- safe to remove |
| Large block deleted by non-owner | Possible mistake | MEDIUM -- verify with original author |
