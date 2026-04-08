# Data Flow Patterns Reference

Framework-specific patterns for tracing data through systems.

## Data Entry Point Patterns by Framework

### Web Frameworks

| Framework | Entry Points | Search Patterns |
|-----------|-------------|-----------------|
| Express.js | `req.params`, `req.query`, `req.body`, `req.headers`, `req.cookies` | `req\.(params\|query\|body\|headers\|cookies)` |
| Django | `request.GET`, `request.POST`, `request.FILES`, `request.META`, `request.COOKIES` | `request\.(GET\|POST\|FILES\|META\|COOKIES)` |
| Flask | `request.args`, `request.form`, `request.files`, `request.headers`, `request.json` | `request\.(args\|form\|files\|headers\|json)` |
| FastAPI | Function parameters with `Depends()`, `Query()`, `Body()`, `Header()` | `Depends\|Query\|Body\|Header\|Path\|Cookie` |
| Rails | `params`, `request.headers`, `request.env` | `params\[`, `request\.env` |
| Spring | `@RequestParam`, `@PathVariable`, `@RequestBody`, `@RequestHeader` | `@RequestParam\|@PathVariable\|@RequestBody` |
| Gin (Go) | `c.Param()`, `c.Query()`, `c.PostForm()`, `c.GetHeader()` | `c\.(Param\|Query\|PostForm\|GetHeader)` |
| Actix (Rust) | `web::Path`, `web::Query`, `web::Form`, `web::Json` | `web::(Path\|Query\|Form\|Json)` |

### Non-HTTP Entry Points

| Source | Pattern | Risk |
|--------|---------|------|
| Environment variables | `os.Getenv`, `process.env`, `os.environ` | Config injection if user-influenced |
| File system reads | `fs.readFile`, `open()`, `ReadFile` | Path traversal if user controls path |
| Database reads | Any ORM query result | Stored injection, data poisoning |
| Message queues | Consumer handlers (Kafka, RabbitMQ, SQS) | Untrusted payload from compromised producer |
| gRPC/Thrift | Service method parameters | Untrusted data from other services |
| CLI arguments | `os.Args`, `sys.argv`, `process.argv` | Command injection in CLI tools |

## Validation Gap Detection Commands

### Quick Scan for Missing Validation

```bash
# Find request handlers that never call validation
# Express: routes without middleware validation
grep -rn "app\.\(get\|post\|put\|delete\|patch\)" --include="*.js" | \
  grep -v "validate\|sanitize\|schema\|check\|verify"

# Django: views without form/validation
grep -rn "def \(get\|post\)" --include="*.py" | \
  grep -v "Form\|Serializer\|validator\|clean_"

# Find raw SQL queries (validation bypass risk)
grep -rn "raw\|execute\|cursor" --include="*.py" --include="*.js" --include="*.go" | \
  grep -v "parameterized\|placeholder\|prepared"
```

### Schema Validation Libraries

| Language | Library | Search Pattern |
|----------|---------|----------------|
| JavaScript | Zod, Joi, Yup, Ajv | `.parse(`, `.validate(`, `.validateAsync(`, `ajv.validate` |
| Python | Pydantic, marshmallow, voluptuous | `BaseModel`, `Schema(`, `validate=` |
| Go | go-playground/validator | `validate.Var`, `validate.Struct`, `binding:` |
| Rust | validator, garde | `#[validate]`, `validate::Validate` |
| Java | Hibernate Validator | `@Valid`, `@NotNull`, `@Pattern` |
| Ruby | dry-validation, ActiveModel | `validates`, `validates_presence_of` |

### Validation Gap Indicators

1. Entry point receives data but no validation call within the same function or middleware
2. Validation function exists but return value is not checked (e.g., calling `validate()` without `if !valid`)
3. Validation only checks type but not content (e.g., "is string" but not "is expected format")
4. Validation on client side only (frontend validation without server-side equivalent)
5. Validation regex that is too permissive (e.g., `.*` instead of specific pattern)

## Trust Boundary Markers

### Explicit Boundaries (Good)

These patterns indicate deliberate trust boundary management:

```
# Middleware that validates before processing
app.use(authMiddleware)
app.use(validateSchema(userSchema))
app.post('/users', handler)

# Decorator-based authorization
@require_permission('admin')
def delete_user(request):
    ...

# Guard clauses that validate input
func handler(w http.ResponseWriter, r *http.Request) {
    if !isValidInput(r.FormValue("id")) {
        http.Error(w, "invalid", 400)
        return
    }
    // proceed
}
```

### Implicit Boundaries (Risky)

These patterns often have hidden trust assumptions:

```
# Assuming internal API data is safe
response = requests.get(f"http://internal-service/api/users/{user_id}")
data = response.json()  # No validation of response shape

# Assuming database data is clean
user = db.query("SELECT * FROM users WHERE id = ?", [user_id])
render_template("profile.html", user=user)  # No output encoding check

# Trusting configuration as immutable
api_key = os.environ.get("API_KEY")  # Could be set by attacker in some environments
```

### Trust Level Definitions

| Level | Definition | Examples |
|-------|-----------|----------|
| Untrusted | Any data from external sources | HTTP params, file uploads, third-party API responses, user-generated content |
| Partially trusted | Data that passed some validation | Validated form data, authenticated user claims, sanitized input |
| Trusted | Data generated by the system itself | Constants, hardcoded config, server-generated nonces |
| Tainted | Untrusted data that has been stored | Database values that originated from user input, cached external data |

## Side-Channel Data in Logging Frameworks

### Common Logging Patterns That Leak Data

| Framework | Risky Pattern | Data Exposed |
|-----------|--------------|-------------|
| Winston (Node) | `logger.info('User login', { email, password })` | Credentials |
| Log4j (Java) | `log.info("Request: {}", request.toString())` | Full request body |
| structlog (Python) | `log.info("event", user_input=data)` | Unsanitized user data |
| slog (Go) | `slog.Info("request", "body", body)` | Request body in logs |
| tracing (Rust) | `info!(body = ?req.body())` | Full request payload |

### Search Commands for Side-Channel Leaks

```bash
# Find logging of sensitive data
grep -rn "log\.\(info\|debug\|warn\|error\)" --include="*.py" --include="*.js" | \
  grep -i "password\|token\|secret\|api_key\|ssn\|credit_card"

# Find error responses that expose internals
grep -rn "stack\|trace\|debug\|detail" --include="*.py" --include="*.js" | \
  grep -i "response\|render\|json\|return"

# Find metrics that include user identifiers
grep -rn "metrics\.\(increment\|gauge\|histogram\|timer\)" --include="*.py" --include="*.js" | \
  grep -i "user_id\|email\|session\|token"

# Find debug endpoints in production routes
grep -rn "debug\|profiler\|metrics\|health\|status" --include="*.py" --include="*.js" | \
  grep -i "route\|endpoint\|url\|path"
```

### Safe Logging Patterns

```javascript
// BAD: Logs raw user input
logger.info('Search query', { query: userInput });

// GOOD: Logs sanitized/reduced data
logger.info('Search executed', { queryLength: userInput.length, hasSpecialChars: /[^a-zA-Z0-9]/.test(userInput) });
```

```python
# BAD: Logs full exception including user data
logger.error(f"Failed to process: {user_data}")

# GOOD: Logs event without sensitive data
logger.error("Processing failed", extra={"error_type": type(e).__name__})
```

## Data Exfiltration Pattern Catalog

### Direct Exfiltration

| Pattern | How It Works | Detection |
|---------|-------------|-----------|
| API response oversharing | Response includes more fields than the consumer needs | Compare API response schema with consumer requirements |
| Verbose error messages | Stack traces, SQL errors, file paths in error responses | Check error handler middleware for production vs development mode |
| Open redirect | User-controlled URL in redirect response | `redirect(req.query.url)` or `redirect(params[:return_to])` |
| Unauthenticated endpoints | Data endpoints without auth checks | Check route middleware for auth/authorization |

### Indirect Exfiltration

| Pattern | How It Works | Detection |
|---------|-------------|-----------|
| Timing attacks | Response time varies based on secret data | Check for early returns, short-circuit evaluation on auth paths |
| Error oracle | Different error messages reveal internal state | Check for distinct error messages for "not found" vs "wrong password" |
| Cache probing | Cached responses reveal whether data exists | Check Cache-Control headers on authenticated endpoints |
| CSS injection | Styling based on data state (e.g., `:visited`) | Check for user-controlled CSS or class names |

### Side-Channel Exfiltration

| Pattern | How It Works | Detection |
|---------|-------------|-----------|
| Log injection | Newline characters in user input create fake log entries | Check for `\n`, `\r` in logged user input |
| Metric cardinality | Unique metric labels from user data exhaust metric storage | Check for user IDs, emails, or IPs as metric label values |
| DNS exfiltration | Data encoded in DNS queries to attacker-controlled domain | Check for user-controlled URLs used in HTTP client calls |
| Webhook leakage | User-controlled webhook URLs receive system data | Check for user-configurable callback URLs |

### Stored Data Exfiltration

| Pattern | How It Works | Detection |
|---------|-------------|-----------|
| Stored XSS | User input rendered as HTML without encoding | Check for `v-html`, `dangerouslySetInnerHTML`, unescaped templates |
| Mass assignment | User input overwrites sensitive model fields | Check for `Model.update(req.body)` without field allowlists |
| IDOR | Sequential or predictable resource identifiers | Check for direct use of user-supplied IDs in database queries |
| Backup exposure | Database backups or dumps accessible without auth | Check for `.sql`, `.dump`, `.bak` files in web-accessible paths |
