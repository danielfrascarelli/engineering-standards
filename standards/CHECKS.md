# Validation Checks

Canonical check names. Every other standard references these names. Repos MUST NOT rename them.

Owner of this topic: this file. No other document defines its own check list.

## The six checks

| Check | What it does |
| --- | --- |
| `format` | Formatter in check mode. Fails on unformatted code. |
| `lint` | Linter. Fails on static rule violations. |
| `typecheck` | Type checker. Fails on type errors. |
| `test` | Test runner. Fails on regressions. |
| `build` | Build command. Fails when artifact does not compile or bundle. |
| `security` | Dependency audit plus secret scan. Fails on known critical vulnerability or leaked secret. |

## When each check runs

| Moment | Required |
| --- | --- |
| Before commit | `format`, `lint` |
| Before push | `format`, `lint`, `typecheck`, `test`, `build` |
| Before requesting review | all six |
| CI on pull request | all six |

## Per-stack commands

Repos MUST expose the six under stable script names. Reference implementations:

| Check | Node, React | Python |
| --- | --- | --- |
| `format` | `npm run format:check` | `ruff format --check .` |
| `lint` | `npm run lint` | `ruff check .` |
| `typecheck` | `npm run typecheck` | `mypy .` or `pyright` |
| `test` | `npm test` | `pytest` |
| `build` | `npm run build` | `python -m build` |
| `security` | `npm audit --audit-level=high` | `pip-audit` |

## Rules

- Repo MUST expose all six, or declare in its local `AGENTS.md` which check does not apply and why.
- Check MUST NOT be marked passed unless it ran. See [AGENTS.md](../AGENTS.md).
- Could not run a check? MUST name the check and the reason. Silence is not allowed.
- Check fails? Fix cause. MUST NOT disable test, delete assertion, weaken lint rule, or add blanket ignore to force green.
- Narrow, commented suppression MAY be used when tool is wrong. Blanket file-level or repo-level suppression MUST NOT.
- `security` failure on a critical vulnerability blocks merge. See [SECURITY.md](SECURITY.md).

## Related

- [AGENTS.md](../AGENTS.md) — agent validation duties
- [GIT.md](GIT.md) — checks before push
- [PR.md](PR.md) — checks before review
- [CONTRIBUTING.md](CONTRIBUTING.md) — workflow position
