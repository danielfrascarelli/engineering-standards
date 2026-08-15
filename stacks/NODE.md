# Node.js Standards

Global rules are not repeated here. Ownership map: [../README.md](../README.md).

## Runtime and version

- Node version MUST be pinned in `.nvmrc` and in `engines` in `package.json`. Same value in both.
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

- ESLint MUST be configured. Prettier SHOULD be the formatter.
- One formatter and one lint strategy per repo. MUST.
- Config MUST be committed at repo root, not held in editor settings.
- Inline rule disable MUST carry a comment naming the reason. Blanket file-level disable MUST NOT be used.

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
