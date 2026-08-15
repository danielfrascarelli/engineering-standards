# NestJS Standards

Extends [NODE.md](NODE.md). Everything there applies. This file covers only what is NestJS-specific.

Global rules are not repeated here. Ownership map: [../README.md](../README.md).

## Reference stack

The libraries a NestJS service in this workspace is expected to use. A repo departing from a row MUST record the reason in its own `AGENTS.md`.

| Concern | Choice |
| --- | --- |
| Runtime | Node active LTS, pinned per [NODE.md](NODE.md) |
| Framework | NestJS 11 + Express, TypeScript strict |
| API docs | `@nestjs/swagger`, UI at `/docs`, bearer auth |
| Validation | `class-validator` / `class-transformer`, global `ValidationPipe` |
| Config | `@nestjs/config` + Joi env schema, fail-fast |
| Auth | `@nestjs/jwt`, access + refresh, bcrypt |
| Rate limiting | `@nestjs/throttler`, global guard |
| Security | helmet, CORS allowlist, cookie-parser, compression |
| Health | `@nestjs/terminus` |
| Logging | `nestjs-pino`, structured JSON, request id, redaction |
| Tracing | OpenTelemetry, opt-in via `OTEL_ENABLED` |
| Error tracking | `@sentry/node`, opt-in via `SENTRY_DSN`, unexpected 500s only, secrets scrubbed |
| Resilience | `opossum` circuit breaker around outbound upstreams |
| API contract | committed `openapi.json`, exported by script, diff-checked in CI |
| Supply chain | audit gate on production dependencies + automated updates. See [../standards/DEPENDENCIES.md](../standards/DEPENDENCIES.md) |
| ORM | Prisma + `@prisma/client`, migrations + seed |
| Outbound HTTP | `@nestjs/axios` |
| Scheduling | `@nestjs/schedule` |
| WebSockets | `@nestjs/websockets` + socket.io |
| Tests | Jest — unit / integration / e2e. See [Testing](#testing) |
| Git hooks | husky + lint-staged + commitlint |
| Production process | PM2, fork mode, graceful shutdown |

Note: which database engine, which upstream services, which socket namespaces, and which schedules a service runs are project facts, not stack rules. They belong in the consuming repo's `AGENTS.md`. See [../README.md](../README.md), "Consuming repo".

## Runtime and version

- Node and package-manager pinning: [NODE.md](NODE.md), which owns that rule. NestJS adds nothing to it.
- NestJS major version MUST be stated in the README, and corrected in the same PR that bumps it.

## Language and types

- `"strict": true` MUST be set in `tsconfig.json`. A service running with `strictNullChecks: false` and `noImplicitAny: false` has no type safety worth the compile time.
- `noUncheckedIndexedAccess`, `noImplicitOverride`, and `forceConsistentCasingInFileNames` MUST be enabled.
- `@typescript-eslint/no-explicit-any` MUST stay enabled. Each `any` needs an inline disable naming the reason.
- `@typescript-eslint/no-floating-promises` and `no-unsafe-argument` MUST be errors. Downgrading either to a warning needs a comment stating why, and a warning cannot fail a build unless `--max-warnings 0` is set.
- `isolatedModules: true` SHOULD be set. It forces `import type` in decorated parameter positions, which is correct anyway.

## Project structure

Four top-level directories under `src/`:

```text
src/modules/<feature>/    HTTP surface and domain logic
src/data/                 persistence: ORM client, accessors, migrations
src/common/               cross-cutting: guards, interceptors, decorators, config, errors
src/observability/        tracing and error reporting, loaded before DI exists
```

- Dependency direction MUST be `modules` to `data` to ORM. `common/` is importable from anywhere.
- Feature module MUST NOT inject the ORM client directly. It goes through an accessor in `src/data/`. Health checks are the usual carve-out, and the carve-out MUST be written down where the rule is stated.
- A rule expressed as "this grep must return nothing" MUST actually run in CI, or be rewritten as a lint boundary rule. An invariant nobody executes is already false.
- File name MUST be `<subject>.<role>.ts`, kebab-case. Roles: `.module.ts`, `.controller.ts`, `.service.ts`, `.dto.ts`, `.guard.ts`, `.interceptor.ts`, `.decorator.ts`, `.gateway.ts`, `.mapper.ts`, `.accessor.ts`, `.health-indicator.ts`.
- One casing convention repo-wide. `LoginRequest.dto.ts` sitting beside `register.ts` MUST NOT happen.
- Class suffix MUST match the file suffix.
- DTOs MUST live in a `dto/` subfolder of their feature. One class per file.
- MUST NOT create barrel `index.ts` files.
- `paths` aliases MUST be declared in `tsconfig.json` and mirrored in the Jest `moduleNameMapper`. Relative imports climbing more than one directory MUST NOT be used.
- Versioned HTTP surface MUST live at `src/modules/api/v<N>/<feature>/`, so URL version and directory version always agree.
- A bidirectional module or provider dependency MUST be removed by extracting the shared provider or module. `@Global()` and `forwardRef()` MUST NOT be used to mask a cycle. `@Global()` only changes where exports are visible, and `forwardRef()` only defers resolution; neither removes the coupling that made the cycle, and both hide it from the next reader.
- `forRootAsync` options factories MUST live in their own `*.options.ts` file. `AppModule` MUST NOT hold inline configuration objects.
- One exported `configureApp(app)` MUST be shared by `main.ts`, the OpenAPI export script, and the e2e bootstrap. Global prefix and versioning duplicated across three files will drift, and the drift surfaces as tests asserting a response shape production never emits.

## Lint and format

- `lint` MUST be check-only, with `--max-warnings 0`. A `lint` script carrying `--fix` cannot fail CI on anything auto-fixable, and in CI it silently repairs files whose fixes never reach the branch. Provide `lint:fix` separately.
- Type-aware linting MUST be enabled: `projectService: true` with `tsconfigRootDir`.
- Formatting SHOULD be enforced through the linter, so one command gates style and correctness together.
- Husky MUST be installed via `prepare`. `pre-commit` runs lint-staged, `commit-msg` runs commitlint.

Commands: [../standards/CHECKS.md](../standards/CHECKS.md).

## Configuration

- `ConfigModule.forRoot({ isGlobal: true, validationSchema })` MUST be used. Without a schema, a missing `DATABASE_URL` or a malformed signing key fails at first use instead of at boot.
- `ConfigModule.forRoot()` MUST be imported exactly once, in the root module. MUST NOT be re-imported in a feature module, and `ConfigService` MUST NOT be listed as a feature provider. Either creates a second, non-root instance.
- Every variable name MUST be declared once in a single `EnvNames` const and referenced as a computed key in the schema. A typo then cannot create an unvalidated variable.
- Config MUST be read only through `ConfigService.get(EnvNames.X)`. The only permitted `process.env` reads are `main.ts` and pre-DI bootstrap files, each with an inline comment stating why.
- A new variable MUST land in `EnvNames`, the validation schema, and `.env.example` in the same commit.
- Secrets MUST be required in production. They MAY be optional in development, through one named schema helper.
- MUST NOT ship a placeholder default for a signing key that is valid outside production. A `NODE_ENV=development` deploy then boots with a publicly known key.
- Optional integration MUST no-op cleanly when its variable is unset. Local development, tests, and CI MUST NOT require an external service.
- Any package imported directly MUST be a declared dependency. Relying on a transitive copy of `dotenv` breaks on any upstream change.

## Validation

A global `ValidationPipe` MUST be registered, and it MUST set:

| Option | Value | Why it is not optional |
| --- | --- | --- |
| `whitelist` | `true` | strips properties no DTO declares |
| `forbidNonWhitelisted` | `true` | rejects them instead of stripping silently |
| `transform` | `true` | applies `@Type` coercion before validators run |
| `exceptionFactory` | the service's own | maps validation failures onto the documented error body |

The `exceptionFactory` MUST take the framework's `ValidationError[]` and return an exception whose response body is the uniform `{ statusCode, code, message }` defined under [Errors](#errors), with `code` set to the service's validation error code. Without it, validation failures are the one error shape that escapes the contract every other failure path follows.

```ts
// Shape, not a drop-in: the error code enum and the body live in the service.
new ValidationPipe({
  whitelist: true,
  forbidNonWhitelisted: true,
  transform: true,
  exceptionFactory: (errors: ValidationError[]) =>
    new BadRequestException({
      statusCode: 400,
      code: ErrorCode.ValidationFailed,
      message: formatValidationErrors(errors),
    }),
})
```

Leaving `forbidNonWhitelisted` unset silently strips unknown properties instead of rejecting them, so a client sending the wrong field name sees a server-side failure with no explanation.

- Request body, query, and param objects MUST be classes carrying `class-validator` decorators. An `interface` is erased at runtime and cannot be validated.
- Update DTOs MUST be derived with `PartialType`, `OmitType`, or `PickType` imported from `@nestjs/swagger`, never from `@nestjs/mapped-types`. The wrong import silently drops OpenAPI metadata.
- Required properties MUST use definite assignment (`name!: string`). Optional ones use `?` with a literal default.
- Nested DTO arrays MUST carry both `@ValidateNested({ each: true })` and `@Type(() => X)`. Either one alone skips validation entirely.
- Query-string numerics MUST carry `@Type(() => Number)` before `@IsInt()`.
- Uploads MUST be validated with `ParseFilePipeBuilder` and an explicit max-size validator. An unbounded upload MUST NOT be accepted.
- MUST NOT hand-roll field validation inside a controller. A payload arriving as a JSON string or a header is parsed into a decorated DTO and validated.
- WebSocket gateways MUST validate explicitly. Global pipes and global guards do not reach `@SubscribeMessage` handlers or `handleConnection`.
- MUST NOT combine global `transform: true` with `ParseIntPipe` on the same parameter. The global pipe coerces first, so `1e3` arrives as 1000 and `0x10` as 16.

## Errors

- Every failure path MUST produce one uniform body: `{ statusCode, code, message }`. Validation errors, guard rejections, and unexpected errors included.
- Pick one strategy per service and state it: typed result objects unwrapped by a global interceptor, or exceptions caught by a global filter. Both work. Mixing them MUST NOT happen.
- Choosing the interceptor strategy MUST still register a global exception filter. Guards and pipes run before interceptors, so without a filter a guard rejection escapes with the framework's default shape and the API ships two incompatible error bodies on the same route.
- Domain error codes MUST live in one enum with a companion `Record<ErrorCode, number>` status map. Status numbers MUST NOT be written at throw sites.
- The status map MUST be covered by a test asserting no duplicate branch. A duplicated `case` silently makes one mapping dead code.
- An unmapped error MUST be replaced with a fixed generic 500 body, with the original logged server-side.
- MUST NOT return stack traces, SQL, or upstream response bodies to a client.
- The error tracker MUST be called from exactly one path, the unexpected-500 branch. Routine 4xx MUST NOT reach it.
- Upstream error codes MUST be translated through a total `Record` with an explicit fallback. Circuit-open and timeout MUST map to distinct domain codes.

## Logging

- Structured JSON logging MUST be used. `nestjs-pino` is the default choice.
- The logger MUST be wired with `bufferLogs: true` plus `app.useLogger(app.get(Logger))`, so nothing is lost before the container is ready.
- `console.*` MUST NOT appear in `src/`. Enforce with `no-console: error`.
- Every request MUST carry a correlation identifier, generated in `genReqId` and present on every log line. Threading a request id through function signatures without ever binding it to the logger leaves logs uncorrelated.
- Pretty-printed output MUST be development only. Production logs are raw JSON on stdout.
- One canonical list of sensitive field names MUST exist, applied to every egress channel: logger redaction and error-tracker `beforeSend` and `beforeBreadcrumb`. A new sensitive field lands in all of them in the same commit.
- One logger injection style per repo. Pick injected `PinoLogger` with `setContext`, or `new Logger(ClassName.name)`, and state which.
- Telemetry and metering code MUST swallow its own failures. A metrics write MUST NOT break a request.
- The tracing bootstrap MUST be the first import of `main.ts`, before anything else loads, or auto-instrumentation cannot patch modules.

What must never be logged: [../standards/SECURITY.md](../standards/SECURITY.md).

## Security notes

Mandatory rules live in [../standards/SECURITY.md](../standards/SECURITY.md). NestJS specifics:

- The authentication guard MUST be registered as `APP_GUARD`. Routes are protected by default and opened with an explicit `@Public()`. Per-handler `@UseGuards` as the only protection MUST NOT be the model: the endpoint someone forgets to decorate is the one that leaks.
- A guard referenced by no `@UseGuards` and no `APP_GUARD` MUST be deleted. A dead auth guard makes `@Public()` decorative and turns the whole access model into documentation.
- Metadata MUST be read with `reflector.getAllAndOverride(KEY, [handler, class])`. `reflector.get(KEY, handler)` silently ignores class-level decorators.
- Access and refresh tokens MUST use distinct secrets plus a `type` discriminator, checked in both directions.
- The refresh token MUST be delivered only as an `httpOnly`, path-scoped cookie, `secure` in production. It MUST NOT appear in a response body, and a request-body fallback MUST NOT be accepted. A second accepted path to the same credential is a second thing to get wrong.
- The refresh cookie `maxAge` MUST be derived from the token's own `exp`, so the two cannot drift.
- Session cookie flags MUST NOT be derived from a comparison that only distinguishes production. `secure: isProduction` leaves staging serving real sessions over plaintext.
- Authorization MUST be enforced, not just authentication. Every non-public route declares a required role or an ownership check. A `role` claim that nothing reads is not authorization.
- Ownership MUST be checked on every handler taking a resource id, writes included. Checking it on the read endpoint and not on the write endpoint is the common miss.
- Refresh tokens SHOULD be revocable: a `jti`, a denylist, or reuse detection. Stateless re-signing means a stolen cookie stays valid for its full lifetime.
- Relaxing `sameSite` from `lax` or `strict` MUST come with a CSRF token on state-changing cookie-authenticated routes, in the same PR. A documented follow-up is not a control.
- `helmet()` and an explicit `trust proxy` MUST be set in bootstrap.
- CORS MUST come from an env-driven allowlist, with the same list passed to the WebSocket adapter. `origin: true` or `*` combined with `credentials: true` MUST NOT be used.
- The rate-limit guard MUST be global, backed by a shared store when more than one instance runs. It MUST stay active in the test environment, or no test ever covers it.
- Swagger UI MUST NOT be served unauthenticated in production.
- Deploy scripts MUST NOT print an environment file. `cat .env` puts every production secret into the deployment log.

## Persistence

- The ORM client MUST be wrapped in an injectable service implementing `OnModuleInit` and `OnModuleDestroy`, exported from one `@Global()` data module.
- `synchronize: true` MUST NOT be used in any environment.
- Accessors MUST stay thin: ORM types in, ORM types out. No result wrappers, no DTOs, no clamping, no business rules.
- Business rules MUST live in the service, so the client receives a mapped domain error instead of a leaked driver code. Returning a raw foreign-key violation to an API consumer is a defect.
- Columns MUST be mapped explicitly to snake_case and tables to plural names. Every table gets `createdAt` and `updatedAt`, and an index per documented query filter.
- A schema change MUST ship with its migration in the same commit.
- A migration already applied anywhere MUST NOT be edited. Add a new one.
- The test database MUST be migrated by an explicit documented step, never implicitly by the application.
- A project without ORM migration tooling MUST have a checked-in ordered SQL directory, an applied-migrations ledger, and a PR checklist item tying entity changes to DDL. Hand-applied SQL with no record of what ran is not a migration strategy.
- An operation writing more than one dependent row MUST run in a transaction. A `// TODO: start transaction` comment around a multi-write flow is a blocking review finding.
- Vendor-specific SQL MUST be isolated behind a named accessor method, with the dialect coupling documented.
- Entity and authoritative DDL drift MUST be caught by a CI check.

## API documentation

- Global prefix and URI versioning MUST be set with an explicit `defaultVersion`. Health controllers are `VERSION_NEUTRAL`.
- Every controller MUST carry `@ApiTags`. Every protected controller MUST carry `@ApiBearerAuth()`.
- Every route MUST document each non-2xx status it can return, with `@ApiResponse` referencing a shared error DTO. A route whose 401, 404, and 409 are undocumented is an incomplete route, and a published spec with zero error schemas is not a contract.
- The security scheme MUST be declared in `DocumentBuilder`.
- Reusable `@ApiBody` schemas MUST be defined once and imported.
- `openapi.json` SHOULD be committed as a versioned artifact and regenerated in the same commit as any DTO, route, `@Api*`, or versioning change.
- The export script MUST build the DI container without `app.init()` or `listen()`, so export needs no database and no network.
- CI SHOULD regenerate the contract and fail on a diff. That check is what makes the rule real rather than aspirational.
- The docs route SHOULD be pinned by an integration test asserting it stays reachable and outside the global prefix.

## Health and shutdown

Three endpoints MUST exist, version-neutral, with the exposure each one is allowed:

| Route | Checks | Answers | Exposure |
| --- | --- | --- | --- |
| `/health/live` | nothing | is the process up | MAY be public |
| `/health/ready` | datastore only | can it serve traffic | private |
| `/health/dependencies` | external upstreams | is anything degraded | private |

- `/health/live` MAY be public when the platform requires an unauthenticated probe, and MUST then return a status only — no dependency names, no versions, no error text.
- `/health/ready` and `/health/dependencies` MUST be reachable only by orchestration, through network policy or authentication. Naming your upstreams and their current state to an unauthenticated caller hands over a map of what to attack and when it is already weak. See [../standards/SECURITY.md](../standards/SECURITY.md).
- A degraded third party MUST NOT make the app report not-ready. Otherwise someone else's outage pulls the whole fleet out of the load balancer.
- `app.enableShutdownHooks()` MUST be called.
- Teardown MUST run through `onModuleDestroy` lifecycle hooks, not custom `process.on('SIGTERM')` handlers in application code. A handler that calls `process.exit()` can kill the process before Nest has drained.
- Shutdown order: stop accepting new work, disconnect WebSocket clients, let in-flight work finish, close the datastore last.
- Every outbound third-party call MUST have a timeout and SHOULD have a circuit breaker, through exactly one code path.

## Testing

Three levels, distinct non-overlapping suffixes:

| Level | Suffix | Boots | Location |
| --- | --- | --- | --- |
| Unit | `*.spec.ts` | nothing, no I/O | beside the subject |
| Integration | `*.int-spec.ts` | real test database, `app.init()` only | beside the subject |
| End-to-end | `*.e2e-spec.ts` | full app bound to a port | `test/` |

- Suffixes MUST be chosen so the unit `testRegex` cannot match the other two.
- `test:all` MUST run all three in sequence. "Tests pass" means `test:all`, not unit only.
- Every level MUST run in CI. A suite excluded from CI because it binds a socket only ever ran on one laptop.
- Database-touching suites MUST be guarded twice: a setup file that throws unless the test database URL is set and identifiable, and a per-spec explicit datasource URL. Ambient `.env` MUST NOT be trusted. A mistake here truncates the development database.
- Test data MUST be cleared in explicit foreign-key-safe order by a shared helper. MUST NOT rely on cascade or on test ordering.
- Integration and e2e suites MUST use one shared harness that replays the production bootstrap in the same order.
- Every external boundary MUST be stubbed by default in the harness. No test performs network I/O.
- E2E auth tokens MUST be obtained by calling the real login route, not by forging a JWT.
- Guards MUST be replaced with `.overrideGuard(X).useValue(...)`, never by re-registering them in `providers`.
- Unit tests SHOULD construct the class directly with `jest.fn()` collaborators. Reserve `Test.createTestingModule` for tests that genuinely need the container.
- A controller unit test SHOULD assert delegation only. Business assertions belong in the service spec.
- A test app that cannot start MUST throw, never skip. A silently skipped suite is a false green.
- Coverage threshold MUST be set in the Jest config **and** a coverage-enabled command MUST run in CI. A threshold CI never executes is not a gate.
- `collectCoverageFrom` SHOULD exclude `*.module.ts`, `*.dto.ts`, `main.ts`, and test files.
- An out-of-scope bug found mid-task SHOULD be recorded in a findings document and pinned with a test asserting the current behavior, so the eventual fix fails loudly. See [../standards/DOCUMENTATION.md](../standards/DOCUMENTATION.md).

Strategy and coverage stance: [../standards/TESTING.md](../standards/TESTING.md).

## CI

- The PR workflow MUST run, in order: install, dependency audit, lint, build, contract drift, migrate, seed, `test:all`. Running tests alone is not a gate.
- CI MUST use the lockfile install (`npm ci`), never `npm install`, in every job including deploy.
- CI MUST run against a real database service container with a health probe.
- `concurrency` with `cancel-in-progress: true` MUST be set on PR workflows.
- The audit gate's scope MUST be documented. If it fires, fix the dependency. MUST NOT widen the level and MUST NOT append `|| true`.
- Dependabot or Renovate MUST be configured, grouped, weekly, targeting the integration branch. See [../standards/DEPENDENCIES.md](../standards/DEPENDENCIES.md).
- A `Dockerfile` MUST have a runtime stage with an explicit `CMD`, a non-root `USER`, and no environment file copied into any layer. A build-only Dockerfile with no `CMD` is not a deployable image.
- `.dockerignore` MUST match the actual stack and MUST exclude at least `node_modules`, `dist`, `.git`, and env files.
- Proxy body limit and application body limit MUST agree, and the authoritative one MUST be stated.
