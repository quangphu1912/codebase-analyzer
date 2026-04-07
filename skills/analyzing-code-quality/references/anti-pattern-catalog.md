# Anti-Pattern Catalog

## God Class / God Module
- **Detection**: File >500 lines, >15 exported functions, >10 imports
- **Grep**: Files with highest line count per directory
- **Risk**: High coupling, hard to test, change ripple effects

## Long Method
- **Detection**: Functions >50 lines
- **Grep**: Count lines between function/def/fn declarations
- **Risk**: Hard to understand, test, and maintain

## Deep Nesting
- **Detection**: >4 levels of indentation
- **Grep**: Count leading tabs/spaces in code blocks
- **Risk**: Cognitive complexity, hidden bugs

## Feature Envy
- **Detection**: Method accesses more fields of another class than its own
- **Grep**: Count references to external vs internal fields
- **Risk**: Poor encapsulation, scattered logic

## Duplicated Code
- **Detection**: Similar code blocks in 3+ files
- **Grep**: Find repeated patterns, similar function bodies
- **Risk**: Fix-in-one-place-but-not-another bugs

## Missing Error Handling
- **Detection**: IO operations without try/catch or error checks
- **Grep**: Find file reads, network calls, DB queries without error handling
- **Risk**: Unhandled exceptions, silent failures

## Callback/Promise Hell
- **Detection**: >3 levels of nested callbacks or .then() chains
- **Grep**: Count nesting levels in async code
- **Risk**: Unreadable flow, error handling gaps

## Magic Numbers/Strings
- **Detection**: Unnamed constants scattered in code
- **Grep**: Find numeric literals and string literals not in constants
- **Risk**: Hard to understand intent, hard to change
