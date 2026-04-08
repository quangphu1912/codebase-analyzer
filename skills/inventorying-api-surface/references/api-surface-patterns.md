# API Surface Patterns by Framework

## Express
- Routes: app.get/post/put/delete/patch(path, handler)
- Middleware: app.use(middleware)
- Router: router.METHOD(path, handler)

## Next.js
- API Routes: pages/api/* or app/api/* (route handlers)
- Server Actions: 'use server' directive

## FastAPI
- Routes: @app.get/post, @router.get/post
- Models: Pydantic BaseModel subclasses

## Spring Boot
- Controllers: @RestController, @GetMapping, @PostMapping
- Services: @Service annotated classes

## GraphQL
- Schema: type Query, type Mutation, type Subscription
- Resolvers: exported resolver functions

## Implicit API Detection

Not every entry point shows up in a route file. Implicit APIs live outside HTTP entirely.

### IPC Channels
- Electron: `ipcMain.handle('channel-name', handler)` registers a callable channel
- Node child_process: `process.send({type: '...'})` defines message protocols
- Pattern: search for `ipcMain`, `ipcRenderer`, `process.send`, `process.on('message')`

### Environment Variable Contracts
- `process.env.FEATURE_X` reads that gate behavior without being in config docs
- `os.Getenv("KEY")` in Go, `std::env::var("KEY")` in Rust
- Pattern: grep for env reads that lack fallback defaults or validation

### CLI Argument Schemas
- argparse (Python): each `add_argument` is an API contract
- click: `@click.option`, `@click.argument`
- commander/yargs (Node): `.option()`, `.command()` definitions
- Pattern: CLI arg names and types constitute an API surface users depend on

### WebSocket Message Types
- JSON discriminators: `socket.on('create-user')` where message type is the routing key
- Pattern: collect all `socket.on('X')` and `socket.emit('Y')` to map the full message contract
- Often completely undocumented despite being user-facing

### Plugin Hooks
- Event emitters: `emitter.on('hook-name')` registers consumers
- Middleware stacks: `app.use(plugin)` with expected shape
- Lifecycle callbacks: `onInit`, `onDestroy`, `beforeSave` conventions
- Pattern: search for registration functions that accept callbacks

## API Chaining Detection

Endpoints often form implicit workflows where one output feeds another input.

### Detection Method
1. Collect all endpoint response schemas
2. Collect all endpoint request body schemas
3. Match: if response A has fields that overlap request B's required fields, they form a chain
4. Validate: check if calling code actually does this (grep for sequential calls)

### Common Chain Patterns
- `POST /users` returns `{id: "...", ...}` -> `GET /users/{id}` consumes that id
- `POST /orders` returns `{orderId: "...", status: "pending"}` -> `POST /payments` expects `{orderId: "..."}`
- `GET /search` returns `{cursor: "..."}` -> `GET /search?cursor=...` continues pagination
- Auth: `POST /auth/token` returns token -> every subsequent call sends `Authorization: Bearer <token>`

### Why It Matters
- Reveals intended usage workflows that docs may not cover
- Breaking the response shape of endpoint A silently breaks endpoint B's callers
- Helps generate accurate API usage examples from the code itself

## Worked Example: Discovering Implicit API Surface

### Scenario
A Node.js project has Express routes documented in OpenAPI, but uses Electron for its desktop client.

### Step 1: Explicit Surface
Grep route definitions: `app.get`, `app.post`, `router.METHOD`. Found 12 endpoints matching the OpenAPI spec. Surface appears complete.

### Step 2: Implicit IPC Surface
Grep `ipcMain.handle` found 8 IPC channels:
- `get-user-preferences` (no REST equivalent)
- `save-window-state` (no REST equivalent)
- `invoke-native-dialog` (bypasses web auth)
- 5 more that duplicate REST endpoints but with different response shapes

The IPC surface is 66% the size of the HTTP surface, completely undocumented.

### Step 3: Environment Variable Contracts
Grep `process.env.` found 14 env var reads. Three (`ADMIN_BYPASS`, `INTERNAL_API_KEY`, `SKIP_AUTH`) control security behavior with no defaults -- they are an undocumented security API.

### Step 4: API Chaining
Compared response/request schemas:
- `POST /sessions` returns `{sessionToken, userId}` and `GET /notifications` requires header `X-Session-Token` -- a chain not documented in either endpoint's description
- `POST /files/presign` returns `{uploadUrl}` and the subsequent PUT to that URL expects specific headers -- a two-step upload workflow invisible from either endpoint alone

### Result
The documented API was 12 endpoints. The actual surface was 12 HTTP + 8 IPC + 3 security env vars + 2 chained workflows. The implicit surface was 85% larger than the documented one.
