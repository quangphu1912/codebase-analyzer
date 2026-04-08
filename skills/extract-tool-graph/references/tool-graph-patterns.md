# Tool Graph Patterns Reference

## Tool Registration Patterns by Framework

### Express.js / Fastify
```javascript
// Static route registration
app.get('/api/search', searchHandler);
app.post('/api/admin/users', adminHandler);

// Conditional registration
if (config.enableBeta) {
  app.post('/api/beta/feature', betaHandler);
}

// Dynamic route loading
routes.forEach(route => app[route.method](route.path, route.handler));
```

### Python FastAPI / Flask
```python
# Decorator-based registration
@app.get("/api/search")
async def search(query: str): ...

# Blueprint registration (conditional)
if settings.ENABLE_ADMIN:
    app.include_blueprint(admin_blueprint)

# Dynamic router inclusion
for plugin in discover_plugins():
    app.include_router(plugin.router)
```

### Go net/http / Chi / Gin
```go
// Static handler registration
r.Get("/api/search", searchHandler)
r.Post("/api/admin/users", adminHandler)

// Build-time gating via build tags
// +build admin
func registerAdmin(r chi.Router) { ... }

// Feature-flagged registration
if config.Features.Admin {
    r.Post("/api/admin/users", adminHandler)
}
```

### Rust Axum / Actix
```rust
// Static route registration
let app = Router::new()
    .route("/api/search", get(search_handler))
    .route("/api/admin/users", post(admin_handler));

// Conditional compilation
#[cfg(feature = "admin")]
fn register_admin_routes(router: Router) -> Router { ... }

// Runtime conditional
let mut app = Router::new().route("/api/search", get(search_handler));
if config.admin_enabled {
    app = app.route("/api/admin/users", post(admin_handler));
}
```

## Conditional Registration Detection

### Pattern: Feature Flag Guard
```
if (config.featureEnabled('X'))     // JS/TS
if settings.FEATURE_X:              // Python
if config.Features.X {              // Go
#[cfg(feature = "x")]               // Rust
```

### Pattern: Environment Guard
```
if (process.env.NODE_ENV === 'production')  // JS/TS
if os.Getenv("APP_ENV") == "production"     // Go
if settings.ENV == "production":            // Python
#[cfg(not(debug_assertions))]               // Rust
```

### Pattern: Role/Permission Guard
```
if (user.role === 'admin')          // JS/TS
if user.has_permission("admin")     # Python
if user.Role == RoleAdmin {         // Go
```

### Pattern: Provider/Backend Guard
```
if (provider === 'openai')          // JS/TS
if provider == "openai":            # Python
if config.Provider == "openai" {    // Go
```

### Pattern: Capability/Config Guard
```
if (config.maxTokens > 4000)        // JS/TS
if config.MAX_TOKENS > 4000:        # Python
if cfg.MaxTokens > 4000 {           // Go
```

## Dynamic Loading Patterns

### Plugin Discovery via Directory Scanning
```
fs.readdirSync(pluginsDir)
  .filter(f => f.endsWith('.js'))
  .forEach(f => registerPlugin(require(`./plugins/${f}`)));
```

### Factory Pattern
```
function createTool(name, config) {
  const tool = toolFactory.create(name);
  if (config.enabled) registry.register(tool);
  return tool;
}
```

### Service Locator
```
const tool = serviceLocator.get('ToolName');
if (tool) tool.execute(params);
```

### Database-Driven Registration
```
const features = await db.query('SELECT * FROM features WHERE enabled = true');
features.forEach(f => registerFeature(f.name, f.config));
```

### Remote Configuration
```
const remoteConfig = await fetch('https://config.service/features');
remoteConfig.features.forEach(f => registerTool(f));
```

## Plugin Hook Discovery

### Event Subscriber Pattern
```
// Registration
eventBus.subscribe('tool:register', handler);

// Discovery
eventBus.emit('tool:register', { name, handler, metadata });
```

### Lifecycle Hook Pattern
```
// Framework hooks
app.on('startup', () => registerTools());
app.on('shutdown', () => unregisterTools());
```

### Extension Point Pattern
```
// Define extension point
interface ToolExtension {
  name: string;
  handler: Function;
  priority?: number;
}

// Register extensions
extensions.register<ToolExtension>('tools', myTool);
```

## Identifying Hidden Capability Surface

The goal is to find tools that EXIST but are NOT currently active:

1. **Defined but unregistered** — tool handler code exists but no registration call
2. **Registered conditionally** — registration gated by a currently-false condition
3. **Compiled out** — build-time flags exclude the tool from the binary
4. **Loaded but disabled** — tool is in the registry but marked inactive
5. **Accessible but undocumented** — tool is registered but not in user-facing docs

Search strategy:
- Grep for handler implementations, then cross-reference with registration sites
- Grep for registration calls, then find what they reference
- The gap between these two sets is the hidden capability surface
