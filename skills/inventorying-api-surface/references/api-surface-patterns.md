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
