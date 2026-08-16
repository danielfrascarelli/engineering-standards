# Delivery Standards

Owner: CI pipeline shape, container images, deploy safety, task runners.

Stack documents describe *which* commands run. This file describes *how* they are gated and shipped. Stack docs MUST NOT restate these rules.

Check names and commands: [CHECKS.md](CHECKS.md).

## Continuous integration

- Every repo MUST have a CI workflow triggered on push and on pull request. A convention that a human runs a command locally before committing is not a gate.
- The workflow MUST run the canonical checks, in this order, failing fast at each step:

```text
install          from the lockfile. Not a check; the prerequisite for all of them.
format
lint
typecheck
build
test
security
```

- Check names are owned by [CHECKS.md](CHECKS.md) and MUST NOT be renamed or replaced here. A pipeline step called "dependency audit" is not a canonical name, and naming it that hides the fact that `security` also has to run a secret scanner: the audit half passes, the scan half never runs, and the pipeline reads as complete.
- The order above MUST NOT be redefined by a stack document. Note: CHECKS.md lists which checks are required at each moment and does not order them; ordering is owned here.
- A stack-specific step MAY be inserted after the canonical check it depends on. It MUST NOT replace one.

- Running tests alone MUST NOT be treated as CI. A pipeline that runs only tests leaves lint, types, and build unguarded.
- Install MUST use the lockfile-respecting command, in every job including deploy. A resolving install in a deploy job ships dependencies nobody reviewed.
- Every test level the repo defines MUST run in CI. A suite excluded because it binds a socket or needs a database has, in practice, only ever run on one machine.
- When tests require a database or another external dependency, CI MUST provide the same dependency class and a compatible version, through a service container with a health probe or a managed test environment, not a mock. Tests that need no such dependency MUST NOT carry an unused container: a static site, a CLI, and a library without persistence have nothing to probe.
- Coverage MUST be measured by a command CI actually executes. A threshold configured in a file that no pipeline step passes `--coverage` to is not a gate.
- `concurrency` with cancel-in-progress MUST be set on pull request workflows.
- Every workflow MUST declare an explicit least-privilege permissions block.
- A rule expressed as "this command must produce no output" MUST run in CI, or be rewritten as a lint rule. An invariant nobody executes is already false.
- Security tooling declared as a dependency MUST be wired into CI. A scanner installed and never invoked is worse than none: it reads as coverage that does not exist.

## Gate integrity

- A lint or format command used as a gate MUST be check-only. A `--fix` flag hardcoded into the gate command means CI repairs violations in the runner, the repairs never reach the branch, and the job passes green over a broken tree.
- Warnings MUST fail the gate, through `--max-warnings 0` or the tool's equivalent. Otherwise any rule downgraded to a warning is decorative.
- Audit gate scope MUST be documented where it is configured: which severities, production dependencies or all. A narrow, stated scope is fine. An unstated one gets widened the first time it goes red.
- A firing audit gate MUST be resolved by fixing or replacing the dependency. MUST NOT widen the severity level and MUST NOT append a command that swallows the failure.
- Suppressing a specific advisory MUST record the advisory identifier and the reason.

## Containers

- A `Dockerfile` MUST have a runtime stage with an explicit start command. A build-only image with no entrypoint is not deployable, whatever the compose file claims to run against it.
- A container MUST declare a non-root `USER`.
- A container MUST declare a `HEALTHCHECK`, or the orchestrator MUST probe a health endpoint. Something must be able to tell whether the process is serving.
- Base images SHOULD be pinned by digest, not by a floating tag.
- An environment file MUST NOT be copied into any image layer. It stays in the layer history even if a later step deletes it.
- `.dockerignore` MUST match the actual stack and MUST exclude at least dependency directories, build output, version-control metadata, and environment files. A copy-pasted ignore file for a different language ignores none of them.
- Proxy body limits and application body limits MUST agree, and the authoritative one MUST be stated.

## Deploys

- A deploy MUST be reproducible from source control. See [RELEASES.md](RELEASES.md).
- A deploy script MUST NOT print an environment file or any secret. `cat .env` in a deploy step writes every production credential into the deployment log, where it persists and is readable by anyone with log access.
- Deploys MUST be health-gated with an automatic rollback path. An all-at-once strategy with no health check means a broken image takes the service down and stays there.
- Cloud credentials SHOULD use short-lived federated identity rather than long-lived access keys stored as secrets.
- Secrets MUST reach the runtime through the platform's secret mechanism. See [SECURITY.md](SECURITY.md).

## Dependency automation

- Automated dependency updates MUST be configured, grouped, on a fixed schedule, targeting `develop`. Branch roles: [GIT.md](GIT.md). Intake rules: [DEPENDENCIES.md](DEPENDENCIES.md).

## Task runners

- The canonical quality command MUST run every gate the repo has, including the format check. A `quality` target that skips formatting means the formatter is enforced nowhere.
- In a monorepo, per-service task-runner targets MUST stay identical. Drift means "run the quality command" resolves to a different thing depending on which directory you are in, and the weakest one sets the real standard.
- The canonical command MUST be named in the README. See [DOCUMENTATION.md](DOCUMENTATION.md).
