# Architecture Mapping Patterns

## Common Patterns

### MVC / Layered
- Indicators: models/, views/, controllers/ directories
- Data flow: Controller -> Service -> Model -> Database
- Signal: each layer imports only from the layer below

### Clean Architecture / Hexagonal
- Indicators: domain/, use-cases/, adapters/, infrastructure/
- Data flow: Use case -> Port -> Adapter -> External
- Signal: domain has zero external dependencies

### Microservices
- Indicators: services/, docker-compose.yml, multiple Dockerfiles, API gateway
- Data flow: Service -> API Gateway -> Service (via HTTP/gRPC)
- Signal: each service is independently deployable

### Monorepo
- Indicators: packages/, apps/, workspaces in package.json, lerna.json
- Data flow: internal package imports
- Signal: shared config at root, per-package configs

### Event-Driven
- Indicators: events/, handlers/, queues/, pubsub, Kafka config
- Data flow: Producer -> Queue/Bus -> Consumer
- Signal: async message handling, eventual consistency
