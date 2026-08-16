# Node.js Standards

Global rules are not repeated here. Ownership map: [../README.md](../README.md).

## Runtime and version

Owner of the Node version-pinning rule: this file. A stack extending it MUST link here rather than restate it.

- Node version MUST be pinned in every place that selects it, and all of them MUST agree: `.nvmrc`, `engines.node` in `package.json`, and the CI step that installs Node. Pinning two of the three drifts the moment someone bumps one.
- A tool-version manager (asdf, mise, volta) MAY be used, but MUST NOT be the only pin. A contributor not using that manager still needs a signal.
- MUST run an active LTS major. MUST NOT ship an end-of-life major.
- Package manager MUST be declared in the `packageManager` field. One package manager per repo.
- Lockfile rules: [../standards/DEPENDENCIES.md](../standards/DEPENDENCIES.md).

## Language and types

- New service MUST use TypeScript.
- Existing JavaScript service MAY stay JavaScript. New module inside it SHOULD be TypeScript.
- `strict: true` MUST be set in `tsconfig.json`.
- MUST NOT use `any`. Use `unknown` plus narrowing.
- Exported function MUST declare its return type.

## Project structure

Layers, outer to inner:

```text
transport / controllers
application / use cases
domain
persistence / repositories
external integrations
```

- MUST NOT put business logic in a route handler.
- Domain layer MUST NOT import transport or persistence.
- Dependencies point inward. MUST.

## Lint and format

- A linter MUST be configured.
- A formatter MUST be configured.
- ESLint plus Prettier SHOULD be the default when broad ecosystem or plugin compatibility is required.
- Biome, or Oxlint plus Oxfmt, MAY be used when their rule and plugin coverage satisfies the repo's requirements.
- One authoritative lint strategy and one formatter per repo. MUST.
- Configuration MUST be committed to the repo, not held in editor settings. Root configuration SHOULD be preferred; package-level overrides MAY be used in a monorepo.
- Formatter concerns MUST NOT be enforced through lint rules when the formatter already owns them.
- Inline lint disables MUST target specific rules and MUST carry a reason.
- Blanket file-level disables MUST NOT be used. Generated and vendor files SHOULD be excluded through configuration instead.
- Unused lint-disable directives MUST be reported.

Commands and when they run: [../standards/CHECKS.md](../standards/CHECKS.md).

## Errors

- MUST use meaningful error types or structured error codes.
- MUST NOT leak internal stack traces to an untrusted client.
- MUST preserve diagnostic context in server logs.
- Rethrowing MUST chain the original with `cause`.
- MUST NOT swallow an error with an empty catch.

## Async

- Prefer `async` / `await`. SHOULD.
- MUST NOT create a floating promise. Await it, or explicitly mark it fire-and-forget with a `.catch`.
- Concurrent work SHOULD use `Promise.all` with bounded concurrency, not an unbounded fan-out.
- Long operation SHOULD accept an `AbortSignal`.
- Process MUST attach `unhandledRejection` and `uncaughtException` handlers that log and exit non-zero.

## Validation

Validate external data at the boundary. MUST.

Boundaries: HTTP requests, queue messages, webhooks, environment variables, third-party responses.

- Schema validator SHOULD be used, not hand-rolled checks.
- Environment variables MUST be validated at startup. Invalid config fails fast, before serving traffic.

## Logging

- MUST use structured logging. One JSON object per line in production.
- MUST NOT use `console.log` in a production code path.
- Request-scoped log MUST carry a correlation identifier.
- Log level MUST be configurable without a rebuild.

What must never be logged: [../standards/SECURITY.md](../standards/SECURITY.md).

## Security notes

Mandatory rules live in [../standards/SECURITY.md](../standards/SECURITY.md). Node specifics:

- MUST NOT use `eval`, `new Function`, or `child_process.exec` with interpolated input. Use `execFile` with an argument array.
- Secret comparison MUST use a timing-safe compare.
- HTTP service SHOULD set security headers and an explicit CORS allowlist. Wildcard CORS on an authenticated API MUST NOT be used.
- Request body size limit MUST be set.

## Shutdown

Service MUST handle graceful shutdown on `SIGTERM`:

1. Stop accepting new work.
2. Drain in-flight requests within a bounded timeout.
3. Close database and queue connections.
4. Flush critical telemetry.
5. Exit before the platform's kill timeout.

## Testing

- Test runner MUST be Vitest or Jest. One per repo.
- Unit test files MUST be named `*.spec.ts` or `*.test.ts`.
- End-to-end test files MUST be named `*.e2e-spec.ts` and kept separate from unit tests.
- Integration test SHOULD run against a real database in a container, not a mock.
- MUST NOT mock the module under test.

Strategy and coverage stance: [../standards/TESTING.md](../standards/TESTING.md).
