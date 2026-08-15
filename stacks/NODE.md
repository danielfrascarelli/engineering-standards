# Node.js Standards

## Language and runtime

- Prefer TypeScript for production services.
- Use an explicitly supported Node.js version.
- Declare runtime expectations in project configuration.

## Architecture

Prefer clear boundaries between:

```text
transport / controllers
application / use cases
domain
persistence / repositories
external integrations
```

Do not put significant business logic in route handlers.

## Async code

- Prefer `async` / `await`.
- Handle rejected promises deliberately.
- Do not create floating promises unless explicitly intentional.

## Validation

Validate external data at boundaries:

- HTTP requests;
- queues;
- webhooks;
- environment variables;
- database payloads when assumptions are unsafe.

## Errors

- Use meaningful error types or structured error codes.
- Do not leak internal stack traces to untrusted clients.
- Preserve useful diagnostic context in server logs.

## Logging

Prefer structured logging.

Include useful correlation identifiers when distributed tracing or request tracking is required.

## Shutdown

Services should handle graceful shutdown where relevant:

- stop accepting new work;
- close database connections;
- flush critical telemetry;
- terminate within infrastructure limits.
