# Architecture Mapping Patterns

## Common Patterns

### MVC / Layered
- Indicators: models/, views/, controllers/ directories
- Data flow: Controller -> Service -> Model -> Database
- Signal: each layer imports only from the layer below
- **Failure mode:** Controllers >200 lines = team uses controllers as service layer (actual pattern: Transaction Script). If models contain business logic (validations, calculations), the "model" layer is really "domain with data access."

### Clean Architecture / Hexagonal
- Indicators: domain/, use-cases/, adapters/, infrastructure/
- Data flow: Use case -> Port -> Adapter -> External
- Signal: domain has zero external dependencies
- **Failure mode:** Domain layer imports infrastructure = dependency inversion failed. If the "domain" folder imports ORM decorators, HTTP types, or DB drivers, it's a layered architecture with extra steps, not clean architecture. Check actual imports, not interface declarations.

### Microservices
- Indicators: services/, docker-compose.yml, multiple Dockerfiles, API gateway
- Data flow: Service -> API Gateway -> Service (via HTTP/gRPC)
- Signal: each service is independently deployable
- **Failure mode:** Shared database = distributed monolith, not microservices. If services share a database schema, a schema change requires coordinated deployments -- defeating the purpose. Also: synchronous HTTP chains between all services = distributed monolith with network overhead.

### Monorepo
- Indicators: packages/, apps/, workspaces in package.json, lerna.json
- Data flow: internal package imports
- Signal: shared config at root, per-package configs
- **Failure mode:** Cross-dependencies between packages = modular monolith, not independent packages. If packages A and B import from each other, they are one package split across two directories. True monorepo packages have one-directional dependency graphs.

### Event-Driven
- Indicators: events/, handlers/, queues/, pubsub, Kafka config
- Data flow: Producer -> Queue/Bus -> Consumer
- Signal: async message handling, eventual consistency
- **Failure mode:** Sync calls between "async" services = request-reply in disguise. If a "consumer" immediately calls back to the producer and waits, the queue is being used as a slow function call. Real event-driven systems tolerate eventual consistency and don't expect immediate responses.
