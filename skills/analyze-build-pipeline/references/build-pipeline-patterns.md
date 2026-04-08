# Build Pipeline Patterns

## Transformation Chain Detection per Tool

### webpack
**Chain**: source -> loaders (per module) -> plugins (per chunk) -> output
- **Loaders** execute right-to-left. Each loader receives the previous loader's output.
  - `babel-loader`: transpiles ES6+/TS -> target ES version. Adds polyfill imports.
  - `ts-loader`: strips types, resolves paths. No runtime transformation.
  - `css-loader` -> `style-loader`: CSS -> JS module -> injected `<style>` tags.
  - `raw-loader`/`asset/source`: imports file content as string (no transform).
- **Plugins** operate on the full compilation:
  - `DefinePlugin`: string replacement at build time (dead code elimination follows).
  - `TerserPlugin`: minification + tree-shaking. Removes unreachable branches after `DefinePlugin`.
  - `HtmlWebpackPlugin`: generates HTML entry point, injects script/link tags.
  - `MiniCssExtractPlugin`: extracts CSS into separate files (removes from JS bundle).
- **What gets removed**: unused exports (tree-shaking via Terser), dead branches after constant folding, dev-only code when `NODE_ENV=production`.
- **What gets added**: webpack runtime bootstrap, module wrapper functions, chunk loading logic, HMR client in dev.

### Vite
**Chain**: source -> esbuild (dev) or Rollup (prod) -> plugins -> output
- **Dev mode**: esbuild handles transforms (no bundling). Native ESM served directly.
- **Prod mode**: Rollup bundles. Plugins run in defined order.
- **Key transforms**:
  - `define` in config: compile-time constant replacement (like DefinePlugin).
  - `envPrefix`: controls which env vars are exposed via `import.meta.env.*`.
  - CSS Modules: scoped class names hashed at build time.
  - Asset handling: small assets inlined as base64, larger ones as file references.
- **What gets removed**: unused exports (Rollup tree-shaking), dead branches from `define`.
- **What gets added**: Vite client for HMR (dev only), preload hints, CSS injection.

### esbuild
**Chain**: source -> parse -> link -> resolve -> bundle -> minify -> output
- **Extremely fast** single-pass: parsing, linking, and minification happen in one go.
- **Key transforms**:
  - `define`: literal replacement before bundling (enables dead code elimination).
  - `external`: marks packages as external (excluded from bundle, resolved at runtime).
  - `banner`/`footer`: prepends/appends strings to output files (license headers, injections).
  - `inject`: imports a file into every output file (polyfills, globals).
- **What gets removed**: unused exports, unreachable code after `define` replacement.
- **What gets added**: minimal bundler runtime, injected files, banner/footer text.
- **Notable limitation**: no full tree-shaking for CommonJS modules (only ESM).

### Rollup
**Chain**: source -> parse -> resolve -> bundle -> generate -> output
- **Tree-shaking is core**: Rollup pioneered scope-based dead code elimination.
- **Key transforms**:
  - `output.manualChunks`: controls code splitting boundaries.
  - `output.globals`: maps module names to globals for UMD/IIFE.
  - `plugins`: `@rollup/plugin-replace` (constant replacement), `@rollup/plugin-node-resolve`, `@rollup/plugin-commonjs`.
  - `external`: excludes modules from bundle.
- **What gets removed**: unused exports (aggressive tree-shaking), unreferenced module side effects.
- **What gets added**: chunk loading runtime (for code-split bundles), import/export helpers.

## Configuration Axis Extraction Techniques

### Where Axes Hide
- **`DefinePlugin` / `define` blocks**: each key is a potential axis. Extract values and enumerate.
- **`process.env.*` references in build config**: grep for `process.env` in config files to find env-gated behavior.
- **`features` / `flags` config files**: JSON/YAML files listing feature flags with boolean/gated values.
- **Conditional entry points**: different `main` fields for different targets (e.g., `main`, `module`, `browser`, `react-native`).
- **Build profiles**: Cargo `[profile.*]`, Maven `<profiles>`, Gradle `buildTypes`, Bazel `config_settings`.
- **Plugin option gates**: plugins that accept `include`/`exclude` patterns or conditional logic.

### Extraction Method
1. **Scan config file** for `define`, `DefinePlugin`, `env`, `feature`, `flag` keywords.
2. **List each discovered constant** with its possible values (check `.env.example`, CI config, deployment scripts).
3. **Trace constant usage** into source code to find conditional branches gated by that constant.
4. **Record the axis** in the Build Dimension Catalogue format (see SKILL.md).
5. **Cross-reference** with `package.json` scripts -- each script may represent a different axis resolution.

### Common Axes
| Axis | Typical Values | Discovery Signal |
|------|---------------|-----------------|
| ENVIRONMENT | dev, staging, prod | `NODE_ENV`, `--mode` |
| TARGET | browser, node, electron | `target` in config, `browser` field in package.json |
| USER_TYPE | internal, external, admin | custom env var or feature flag |
| PROVIDER | aws, gcp, azure | `CLOUD_PROVIDER`, conditional imports |
| LOCALE | en, de, ja, ... | i18n plugin, locale directories |
| FEATURE_FLAGS | true/false per flag | feature flag service config, `FEATURE_*` env vars |

## Build-Time Code Injection Patterns

### String Replacement (Most Common)
- **webpack DefinePlugin**: `new webpack.DefinePlugin({ 'process.env.API_URL': JSON.stringify(url) })` -- replaces all occurrences of the exact string `process.env.API_URL` with the literal value. Dead code elimination then removes unreachable branches.
- **Vite/esbuild `define`**: `define: { 'import.meta.env.VERSION': '"1.2.3"' }` -- same principle, replace then eliminate.
- **Rollup plugin-replace**: `replace({ 'process.env.NODE_ENV': JSON.stringify('production') })` -- string replacement before tree-shaking.

### Code Injection
- **webpack `banner`/`footer`**: injects text at file boundaries (license headers, analytics bootstrap).
- **esbuild `inject`**: imports a shim file into every entry point. Used for polyfills (e.g., `Buffer`, `process` shim for browser).
- **webpack `ProvidePlugin`**: auto-imports a module when a free variable is encountered (e.g., `jQuery` when `$` is used).
- **HtmlWebpackPlugin**: injects `<script>` and `<link>` tags into HTML templates at build time.

### Module Transformation
- **babel-plugin-module-resolver**: rewrites import paths at build time (alias mapping).
- **webpack aliases**: `resolve.alias` maps import specifiers to different files.
- **Vite `resolve.alias`**: same pattern. Often used to replace heavy libraries with lighter stubs in tests.

### Asset Inlining
- **webpack asset/source**: inlines file content as a string.
- **Vite**: assets below a size threshold are inlined as base64 data URLs automatically.
- **SVG as React component**: build plugins transform `.svg` files into React components.

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
