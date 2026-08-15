# Python Standards

## Version and environment

- Declare the supported Python version.
- Use isolated environments.
- Pin application dependencies through the project's selected dependency manager.

## Types

- Add type hints to public functions and important internal boundaries.
- Avoid `Any` when a precise type is practical.
- Use typed models for structured data.

## Formatting and linting

Recommended default:

```text
Ruff
```

Use the repository configuration as the source of truth.

## Exceptions

Avoid:

```python
except:
    pass
```

Catch specific exceptions and preserve meaningful context.

## Functions

- Prefer small functions with clear responsibilities.
- Avoid mutable default arguments.
- Avoid hidden global state.
- Make side effects explicit.

## Paths

Prefer `pathlib` over manual path-string concatenation.

## Architecture

Keep domain logic independent from frameworks and infrastructure when practical.

## Testing

Recommended default:

```text
pytest
```

Use fixtures deliberately and avoid large opaque fixture hierarchies.
