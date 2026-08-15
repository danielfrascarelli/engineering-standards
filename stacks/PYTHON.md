# Python Standards

Global rules are not repeated here. Ownership map: [../README.md](../README.md).

## Runtime and version

- Supported Python version MUST be declared in `pyproject.toml` under `requires-python`, and pinned in `.python-version`.
- MUST run a supported CPython release. MUST NOT ship an end-of-life version.
- Work MUST happen in an isolated environment. Never the system interpreter.
- One dependency manager per repo, declared in the README. Lockfile rules: [../standards/DEPENDENCIES.md](../standards/DEPENDENCIES.md).

## Language and types

- Public function MUST have type hints on parameters and return.
- Important internal boundary SHOULD have type hints.
- MUST NOT use `Any` when a precise type is practical.
- Structured data MUST use a typed model: `dataclass`, `TypedDict`, or `pydantic`. MUST NOT pass bare dicts between layers.

### Type checking

- Repo MUST run `mypy` or `pyright` as the `typecheck` check. See [../standards/CHECKS.md](../standards/CHECKS.md).
- Config MUST live in `pyproject.toml`.
- `ignore_errors` on a whole module MUST NOT be used. Narrow, commented `# type: ignore[code]` MAY be used.

## Project structure

- Package SHOULD use `src/` layout, so tests import the installed package, not the working directory.
- Domain logic SHOULD stay independent of framework and infrastructure.
- Module name MUST be lowercase with underscores.
- MUST NOT rely on import side effects to register behavior.

## Lint and format

- Ruff MUST be the linter and the formatter.
- Config MUST live in `pyproject.toml`. It is the source of truth.
- Line length MUST be set explicitly, not left to tool default drift.
- Per-file ignore MUST name the rule code and carry a reason. Blanket `# noqa` MUST NOT be used.

Commands: [../standards/CHECKS.md](../standards/CHECKS.md).

## Errors

Never write this:

```python
except:
    pass
```

- MUST catch a specific exception type. Bare `except` and bare `except Exception: pass` are forbidden.
- Rethrowing MUST preserve the cause: `raise MyError("context") from err`.
- Project SHOULD define its own exception base class, so callers can catch its errors as a group.
- MUST NOT use an exception for normal control flow across a module boundary.

## Functions

- SHOULD keep functions small, one responsibility.
- MUST NOT use a mutable default argument.
- MUST NOT rely on hidden global state.
- Side effect MUST be visible in the function name or signature.

## Paths and resources

- MUST use `pathlib`, not manual path-string concatenation.
- File, socket, and connection MUST be handled with a context manager.

## Logging

- MUST use the `logging` module. MUST NOT use `print` for diagnostics in library or service code.
- Logger MUST be module-scoped: `logger = logging.getLogger(__name__)`.
- Log record SHOULD be structured, not an interpolated sentence.
- MUST NOT pre-format the message with an f-string when passing arguments. Use `logger.info("user %s failed", user_id)`.
- Library code MUST NOT configure handlers. The application configures logging.

What must never be logged: [../standards/SECURITY.md](../standards/SECURITY.md).

## Security notes

Mandatory rules live in [../standards/SECURITY.md](../standards/SECURITY.md). Python specifics:

- MUST NOT use `pickle`, `yaml.load`, or `eval` on untrusted data. Use `yaml.safe_load`.
- MUST NOT call `subprocess` with `shell=True` and interpolated input. Pass an argument list.
- Secret comparison MUST use `hmac.compare_digest`.
- Template rendering MUST have autoescaping enabled.

## Testing

- Test runner MUST be `pytest`.
- Test files MUST be named `test_*.py`.
- Shared fixtures MUST live in `conftest.py` at the narrowest scope that needs them.
- Fixture hierarchy SHOULD stay shallow. Deep opaque fixture chains hide what a test sets up.
- Repeated cases SHOULD use `pytest.mark.parametrize`, not copy-pasted test bodies.
- Test MUST NOT depend on network or on a developer's local files.

Strategy and coverage stance: [../standards/TESTING.md](../standards/TESTING.md).
