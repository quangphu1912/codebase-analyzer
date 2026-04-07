# Build Pipeline Patterns

## JavaScript/TypeScript
- webpack: loaders (babel-loader, ts-loader), plugins (DefinePlugin, HtmlWebpackPlugin)
- Vite: define for constants, envPrefix for env vars, plugins for transforms
- esbuild: define for replacement, external for exclusions, banner/footer injection
- tsc: paths mapping, conditional compilation via tsconfig paths

## Build-Time Constants
- process.env.NODE_ENV -> development/production/test
- process.env.USER_TYPE -> external/internal
- import.meta.env.* -> Vite env variables
- DefinePlugin -> arbitrary string replacement

## Code Generation
- GraphQL codegen: graphql-codegen.yml -> generated types/hooks
- OpenAPI: openapi-generator -> API client, types
- Protobuf: protoc -> generated message types
- Prisma: prisma generate -> client and types

## Feature Flags in Build
- process.env.FEATURE_X -> conditional inclusion
- window.__FLAGS__ -> runtime feature flags
- GrowthBook/Unleash/LaunchDarkly -> external feature flag services
