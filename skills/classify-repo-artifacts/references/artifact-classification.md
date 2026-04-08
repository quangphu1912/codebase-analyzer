# Artifact Classification Heuristics

## Core Indicators
- Contains domain-specific logic: code that uses business vocabulary from the project's naming (e.g., `SubscriptionPlan`, `InvoiceTotal`), not generic CS terms like "handler", "processor", "manager"
- Files that import from support/ but are not imported by infrastructure/
- Contains business rules, validation logic, data transformation that encode project-specific constraints (not generic CRUD patterns)
- Named after domain concepts and the logic inside cannot be reduced to generic patterns by removing the domain noun

## Support Indicators
- Generic utility functions (formatDate, debounce, deepClone)
- Shared types and interfaces
- Re-export files (index.ts that re-exports from sub-modules)
- Framework adapters and wrappers
- Low naming entropy: repetitive patterns like `formatX`, `parseX`, `validateX` across files

## Generated Indicators
- Provenance map marks as derived
- "DO NOT EDIT" or "@generated" in file header
- Located in dist/, build/, generated/, __generated__/
- Produced by codegen tools listed in build pipeline
- Low information density combined with low naming entropy (identical file structure, only entity names differ)

## Test Indicators
- File matches *.test.*, *.spec.*, *_test.*
- Contains describe(), it(), test(), expect() calls
- Located in test/, tests/, __tests__/, spec/
- Contains mock data and fixtures

## Infrastructure Indicators
- Dockerfile, docker-compose.yml
- .github/workflows/, Jenkinsfile, .gitlab-ci.yml
- k8s/, terraform/, cloudformation/
- Makefile, scripts/, tools/

## Entropy-Based Classification Techniques

### Information Density Measurement

Count distinct syntactic operations (function calls, assignments, control flow constructs, operators) per line of executable code. Calculate the repository median and standard deviation. Files more than 2 standard deviations from the mean are entropy outliers.

**Steps:**
1. For each file, count: function calls, assignments, control flow keywords, distinct operators
2. Divide by lines of executable code (excluding blank lines and comments)
3. Compute repository median (M) and standard deviation (sigma)
4. Flag files with density > M + 2*sigma (high) or < M - 2*sigma (low)

**Interpretation:**
- High density + business vocabulary = dense core logic (e.g., pricing engines, rule evaluators)
- High density + no business vocabulary = vendored, minified, or obfuscated (not core)
- Low density + many lines = scaffolding, config classes, or generated boilerplate
- Low density + few lines = simple utilities or re-export barrels (support)

### Naming Entropy Measurement

Extract all identifiers from a module (function names, variable names, type names, constants). Calculate the ratio: unique_identifiers / total_identifier_tokens.

**Steps:**
1. Parse all identifier tokens from the module
2. Count total tokens and unique tokens
3. Compute ratio: unique / total (0.0 = all identical, 1.0 = all unique)

**Interpretation:**
- Ratio > 0.8: High naming entropy. Module uses diverse, specific vocabulary — likely core domain logic
- Ratio 0.4 - 0.8: Moderate. Mix of domain and generic naming — examine context
- Ratio < 0.4: Low naming entropy. Repetitive naming patterns — likely boilerplate, generated CRUD, or utility support

### Domain Logic Identification Test

To distinguish genuine core logic from support code wearing domain clothing:

1. Take each identifier in the module
2. Remove the project-specific domain noun (e.g., replace "Invoice" with "Entity")
3. Examine the remaining logic structure

If the remaining structure is generic (CRUD operations, simple validation, serialization, delegation), the module is support.
If the remaining structure encodes rules, workflows, or constraints unique to the problem space, it is genuinely core.

## Worked Examples

### Example 1: Genuine Core (High Density + Domain Vocabulary)

```python
# pricing_engine.py — median density: 1.2, this file: 3.8 (>2 sigma HIGH)
# naming entropy: 0.91 (high)

def calculate_early_payment_discount(invoice, payment_date):
    if payment_date <= invoice.due_date - timedelta(days=10):
        return invoice.total * Decimal("0.02")
    elif payment_date <= invoice.due_date:
        return invoice.total * Decimal("0.005")
    return Decimal("0")
```

**Classification: Core.** High information density, high naming entropy. Removing "invoice" and "payment" leaves `calculate_early_discount(...)` — still encodes a business rule with tiered thresholds. Not reducible to a generic pattern.

### Example 2: Support Wearing Domain Clothing

```python
# invoice_handler.py — median density: 1.2, this file: 1.1 (near median)
# naming entropy: 0.35 (LOW)

class InvoiceHandler:
    def get_invoice(self, id): return self.repo.get(id)
    def create_invoice(self, data): return self.repo.create(data)
    def update_invoice(self, id, data): return self.repo.update(id, data)
    def delete_invoice(self, id): return self.repo.delete(id)
```

**Classification: Support.** Low naming entropy — every method is CRUD with "invoice" prefixed. Removing "invoice" yields `get(id)`, `create(data)`, `update(id, data)`, `delete(id)` — pure generic CRUD. No business rules.

### Example 3: Generated Code (Low Density + Low Naming Entropy)

```typescript
// generated/graphql-types.ts — median density: 1.2, this file: 0.6 (<1 sigma LOW)
// naming entropy: 0.28 (LOW)

export interface UserQuery {
  user: User | null;
}
export interface User {
  id: string;
  name: string;
  email: string;
}
export interface OrderQuery {
  order: Order | null;
}
export interface Order {
  id: string;
  total: number;
}
```

**Classification: Generated.** Low density, low naming entropy. Identical structure repeated with only entity names swapped. Provenance map should confirm as derived from schema.

### Example 4: Vendored Code (High Density + No Domain Vocabulary)

```javascript
// vendor/lodash.min.js — median density: 1.2, this file: 5.1 (>2 sigma HIGH)
// naming entropy: 0.72 (moderate — but names are not project-domain names)

function cf(n,t,r){var e=Hf(n);return null==n?e:zc(n,t,r)}
```

**Classification: Generated/Vendored.** High density, but identifiers are obfuscated (`cf`, `zc`, `Hf`) — not project business vocabulary. Provenance map should mark as vendored. Misclassifying as core would waste analysis tokens on unreadable third-party code.
