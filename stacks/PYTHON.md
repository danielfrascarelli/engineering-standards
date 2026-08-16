# Python Standards

Global rules are not repeated here. Ownership map: [../README.md](../README.md).

Pipeline, container, and deploy rules: [../standards/DELIVERY.md](../standards/DELIVERY.md).

## Runtime and version

- Supported Python version MUST be declared in `pyproject.toml` under `requires-python` and pinned in `.python-version`.
- Four places MUST agree: `requires-python`, the container base image tag, the linter's `target-version`, and the type checker's `python_version`. A project pinning `~3.9.0` while both tools target `py312` is lying to at least one of them.
- MUST run a Python release still receiving security support. MUST NOT ship on an end-of-life version.
- Work MUST happen in an isolated environment. Never the system interpreter.
- One dependency manager per repo, declared in the README. Lockfile rules: [../standards/DEPENDENCIES.md](../standards/DEPENDENCIES.md).
- MUST NOT `pip install` into an image otherwise managed by a lockfile. Those packages are unpinned, unreviewed, and invisible to the audit gate.
- Dev tools MUST be pinned in the lockfile and run through the project environment. A cache directory naming a different tool version than the lockfile pins is proof the gate ran outside the project.
- Every dependency needed to run MUST be declared, debug-only ones included. Installing a debugger at container start is an undeclared dependency.

## Language and types

- Public function MUST have type hints on parameters and return. Important internal boundaries SHOULD have them.
- MUST NOT use `Any` when a precise type is practical. `Any` on a public signature MUST carry an inline comment justifying it.
- Structured data MUST use a typed model: `dataclass`, `TypedDict`, or a validation library model. MUST NOT pass bare dicts between layers.
- Input validation MUST use the model library's validators and field constraints, not hand-rolled checks in a separate module.
- MUST NOT mix a validation-library base with a `dataclass` base in one class. Generic parameters silently degrade to `Any`, and the envelope you think is validated is a raw dict.
- A `Protocol` MUST match its implementations. A synchronous `Protocol` method that every implementation defines as `async` and every caller awaits is a type that describes nothing.
- Model fields MUST be snake_case. Enable the linter's naming rules so a camelCase field is caught.
- `from __future__ import annotations` MUST be adopted repo-wide or not at all.
- Array-typed code SHOULD annotate dtype and shape rather than a bare array type.

### Type checking

- Repo MUST run `mypy` or `pyright` as the `typecheck` check. See [../standards/CHECKS.md](../standards/CHECKS.md).
- Exactly one type-checker configuration per repo, in `pyproject.toml`. A second config file that a different invocation directory would pick up MUST be deleted.
- `check_untyped_defs` MUST be enabled. With it off, the checker skips exactly the functions most likely to be wrong.
- `disable_error_code` MUST be empty, or each entry MUST carry a comment justifying it.
- `ignore_errors` on a whole module MUST NOT be used. Narrow, commented `# type: ignore[code]` MAY be used.

## Project structure

- Package layout MUST be declared explicitly in `pyproject.toml`. MUST NOT rely on `PYTHONPATH` to make imports resolve. A project setting `PYTHONPATH` to four different values across Dockerfiles, compose files, and start scripts has no import contract at all.
- `PYTHONPATH` SHOULD be set in at most one place per deployable, or not at all.
- Package SHOULD use `src/` layout, so tests import the installed package rather than the working directory.
- Every directory containing modules MUST have an `__init__.py`, or the project MUST commit to namespace packages everywhere. Mixing them means per-file ignores silently apply to nothing.
- Module name MUST be lowercase with underscores.
- MUST NOT rely on import side effects to register behavior.
- Domain logic SHOULD stay independent of framework and infrastructure.
- Superseded tool configs MUST be deleted when migrating tools. A repo has exactly one lint config and one type-check config. Leaving a legacy config that the docs call dead does not stop a tool from finding it.
- A shared or vendored internal library MUST ship a `py.typed` marker and MUST own its own lint, type, and test configuration. A library checked only when mounted into a consumer is not checked.

## Lint and format

- Ruff MUST be the linter and the formatter.
- Config MUST live in `pyproject.toml`. It is the source of truth.
- MUST NOT set `fix = true` in committed config. Ruff's config is the one place a Python repo can turn its lint gate into a mutating command without anyone noticing. Gate integrity is owned by [../standards/DELIVERY.md](../standards/DELIVERY.md).
- Line length MUST be set explicitly and enforced. MUST NOT declare a line length and then ignore the rule that enforces it.
- Baseline rule selection MUST extend `E`, `F`, `W`, `I`, `B`, `UP`, `SIM` with at least `N` (naming), `T20` (no print), `S` (security), `ASYNC`, and `RUF`.
- Enabling `UP` MUST be followed by removing legacy `typing.List`, `Dict`, `Optional`, and `Tuple`. Note: dozens of survivors are proof the linter is not actually running on that code.
- Per-file ignore MUST name the rule code and carry a reason. Blanket `# noqa` MUST NOT be used.

Commands: [../standards/CHECKS.md](../standards/CHECKS.md).

## Configuration

- Configuration MUST be read through one typed, validated settings object, not scattered `os.getenv` calls.
- Missing required configuration MUST fail fast and loudly, with a message naming the variable. Two config paths in one service — one crashing at import, the other string-interpolating a missing host into a connection URL that only fails at connect time — is worse than either alone.
- A project that reads environment variables MUST commit the template file required by [../standards/SECURITY.md](../standards/SECURITY.md), listing every required variable with a placeholder value. CI SHOULD verify it covers everything the code reads.
- A variable declared in `.env` that no code reads MUST be removed. A variable the code reads that appears in no `.env` and no pipeline MUST be added.
- Filesystem paths for runtime assets MUST be configurable. MUST NOT hardcode absolute container paths.
- A secret-scanning pre-commit hook SHOULD be installed. A single `.gitignore` line is the only thing standing between a working-tree credential and history.

## Errors

Never write this:

```python
except:
    pass
```

- MUST catch a specific exception type. Bare `except` and `except Exception: pass` are forbidden.
- Re-raising or wrapping inside an `except` MUST preserve the cause: `raise MyError("context") from err`. A codebase with zero `from` clauses loses the original traceback at every boundary.
- `except Exception` MUST log a reason and MUST either re-raise or return a typed error. MUST NOT discard the exception object, keeping only `str(e)`.
- Project MUST define one exception base class in one module, so callers can catch its errors as a group. Three unrelated exception hierarchies in three packages cannot be caught together.
- MUST use `logger.exception(...)`. MUST NOT hand-format tracebacks with `sys.exc_info()` and `traceback.format_tb`. Copy-pasting that block into four modules is how it stays wrong in all four.
- Outbound retries MUST use a retry library with explicit backoff and jitter. A hand-rolled loop with a fixed count and no delay amplifies an upstream outage.
- A generic handler MUST return a fixed message and MUST NOT echo internals.
- MUST NOT use an exception for normal control flow across a module boundary.

## Functions

- SHOULD keep functions small, one responsibility.
- MUST NOT use a mutable default argument.
- MUST NOT rely on hidden global state.
- Side effect MUST be visible in the function name or signature.
- MUST use `pathlib`, not manual path-string concatenation.
- File, socket, and connection MUST be handled with a context manager.

## Logging

- MUST use the `logging` module. MUST NOT use `print` for diagnostics in library or service code. Enable the linter's `T20` rule; a `print` in a shared error adapter is the one nobody finds by reading.
- `logging.basicConfig()` MUST be called only from an application entry point. A library module calling it at import time reconfigures the root logger behind the application's back.
- Loggers MUST be obtained through one shared helper using `__name__`. Half the modules using the helper and half calling `getLogger` directly means the helper guarantees nothing.
- Log level MUST be configurable by environment variable. A `LOG_LEVEL` that every environment file declares and no code reads is not configuration.
- Log records SHOULD be structured, not interpolated sentences.
- MUST NOT pre-format with an f-string when passing arguments. Use `logger.info("user %s failed", user_id)`.
- A request or correlation identifier MUST be bound into the log record itself. Threading it through function signatures and response bodies without binding it leaves logs uncorrelated, and an `extra` payload the format string never references is silently dropped.

What must never be logged: [../standards/SECURITY.md](../standards/SECURITY.md).

## Security notes

Mandatory rules live in [../standards/SECURITY.md](../standards/SECURITY.md). Python specifics:

- MUST NOT use `pickle`, `yaml.load`, or `eval` on untrusted data. Use `yaml.safe_load`.
- MUST NOT call `subprocess` with `shell=True` and interpolated input. Pass an argument list.
- Secret comparison MUST use `hmac.compare_digest`.
- Template rendering MUST have autoescaping enabled.
- A tenant, user, or account identifier arriving in a request header MUST NOT be trusted as authorization. It identifies a claim, not a verified principal.
- Upload size MUST be enforced before the payload is read into memory, and the limit MUST be defined in exactly one place. Reading the whole upload and then checking its size is not a limit.

## Async

- MUST NOT call blocking or CPU-bound code from `async def`. Offload with `asyncio.to_thread` or an executor, or declare the handler synchronous and let the framework use its thread pool. Inference, image decoding, and native index calls sitting directly on the event loop serialize every request in the process.
- MUST NOT mark a function `async` unless it awaits real I/O.
- Mutable process-global state MUST be protected by an explicit lock, or documented as immutable after init. The offload above turns an incidentally-safe singleton into a real race, so the lock lands in the same change.
- A long-lived HTTP client MUST be reused. Constructing one per request discards the connection pool it exists to provide.
- MUST use the framework's lifespan handler. Deprecated startup event decorators MUST NOT be used.
- An in-process cache or index is invalid under multi-process serving unless externalized. That constraint MUST be stated where the singleton is defined, next to the worker-count setting that would break it.

## Testing

- Test runner MUST be `pytest`.
- Test files MUST be named `test_*.py`.
- pytest config MUST live in `pyproject.toml` and MUST set `addopts = "--strict-markers --strict-config"`.
- Every deployable MUST have at least one test that imports its application entry point. This single rule catches a service whose imports reference modules that do not exist — which no linter, and no type checker running with `ignore_missing_imports`, will find.
- Core decision logic MUST have direct unit tests: authorization accept and reject, retry behavior, error mapping, and any threshold comparison.
- Shared fixtures MUST live in `conftest.py` at the narrowest scope that needs them. Fixture hierarchies SHOULD stay shallow.
- Repeated cases SHOULD use `pytest.mark.parametrize`, not copy-pasted test bodies.
- Test MUST NOT depend on network or on a developer's local files.
- A test script targeting a removed endpoint MUST be deleted or fixed.

Strategy and coverage stance: [../standards/TESTING.md](../standards/TESTING.md). Coverage threshold as a gate: [../standards/DELIVERY.md](../standards/DELIVERY.md).
