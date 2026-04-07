# Tech Stack Detection Signatures

## Language Detection

| File Pattern | Language |
|-------------|----------|
| *.py, requirements.txt, setup.py, pyproject.toml | Python |
| *.ts, *.tsx, tsconfig.json | TypeScript |
| *.js, *.jsx, package.json | JavaScript |
| *.go, go.mod, go.sum | Go |
| *.rs, Cargo.toml | Rust |
| *.java, pom.xml, build.gradle | Java |
| *.rb, Gemfile | Ruby |
| *.cs, *.csproj, *.sln | C# |

## Framework Detection

| Dependency / Import | Framework |
|--------------------|----------|
| express, fastify, koa, hapi | Node.js web framework |
| react, react-dom | React |
| vue, @vue/cli | Vue.js |
| next, next.config | Next.js |
| django, flask, fastapi | Python web framework |
| actix-web, axum, rocket | Rust web framework |
| gin, echo, fiber | Go web framework |
| spring-boot, spring-web | Spring Boot |

## Build Tool Detection

| Config File | Build Tool |
|------------|-----------|
| webpack.config.* | webpack |
| vite.config.* | Vite |
| rollup.config.* | Rollup |
| esbuild (in package.json scripts) | esbuild |
| Makefile, GNUmakefile | Make |
| Bazel, WORKSPACE, BUILD | Bazel |
| Cargo.toml | Cargo |
| build.gradle, settings.gradle | Gradle |
