# Gate Detection Patterns

## Build-Time Gates
- #ifdef / #ifndef preprocessor directives
- process.env.NODE_ENV conditionals
- Dead code elimination (tree-shaking)
- Conditional exports in package.json (exports map)
- Build config conditionals (webpack DefinePlugin)

## Runtime Gates
- Feature flag checks: if (flags.x) / flags.isEnabled('x')
- User type checks: if (user.type === 'admin')
- Environment checks: if (env === 'production')
- Version checks: if (version >= '2.0')
- Capability checks: if ('speechRecognition' in navigator)

## Permission Gates
- Role-based: if (user.role === 'admin')
- Permission-based: if (user.can('write'))
- Scope-based: if (token.scope.includes('api:write'))
- ACL-based: if (acl.check(resource, action))

## Provider Gates
- Provider config: if (config.provider === 'openai')
- API detection: if (typeof openai !== 'undefined')
- Backend routing: switch(provider) { case 'aws': ... }

## Config Gates
- Feature flags: GrowthBook, Unleash, LaunchDarkly
- Environment variables: ENABLE_X=true
- Database flags: feature_flags table
- Remote config: /api/config endpoint
