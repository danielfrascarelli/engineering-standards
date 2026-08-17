# Changelog

Versioning, tag format, release flow, and what counts as breaking: owned by
[standards/RELEASES.md](standards/RELEASES.md). This repository is pre-1.0, so a MINOR release MAY
break a consuming repo.

Newest first. Updated in the release pull request, never after the tag.

## v0.1.0 — 2026-08-17

First tagged release. The content already existed on `main`; this entry marks the point a consuming
repo can pin instead of tracking a branch tip.

### Breaking changes

None. There is no earlier version to break against.

### Capabilities

- Global standards: CHECKS, CONTRIBUTING, DELIVERY, DEPENDENCIES, DOCUMENTATION, GIT, PR, RELEASES,
  SECURITY, TESTING.
- Stack standards: NESTJS, NODE, PYTHON, PYTHON_ML, REACT.
- Agent rules in [AGENTS.md](AGENTS.md), approved tooling in [tooling/PLUGINS.md](tooling/PLUGINS.md).
- Consumption by git submodule or by [scripts/sync-standards.sh](scripts/sync-standards.sh).
- Enforcement: [scripts/validate-standards.sh](scripts/validate-standards.sh) for this repo,
  [scripts/validate-consumer-standards.sh](scripts/validate-consumer-standards.sh) for a consuming
  repo, reference `commit-msg` and `pre-push` hooks, and
  [scripts/check-pr-body.sh](scripts/check-pr-body.sh) for pull request bodies.

### Fixes

- [stacks/NESTJS.md](stacks/NESTJS.md): seven MUST rules relaxed to match the purpose behind them.
  The cross-cutting directory name moves from a central `src/common/` to a per-repo declaration in
  the consuming repo's `AGENTS.md`; the role-suffix list opens and gains `.filter.ts`, `.pipe.ts`,
  `.middleware.ts`, `.strategy.ts` and `.options.ts`; a class name must contain its file's role
  token rather than match it; the `api/v<N>/` layout applies from the second live version; the
  status map is an object literal and its duplicate-branch test is dropped, because the type already
  makes a missing and a repeated code compile errors; the rate limiter needs one test hitting 429
  rather than staying active across every suite; `/health/dependencies` may be omitted by a service
  with no outbound third-party call.

### Migration

None. A consuming repo pins the `v0.1.0` commit in its `.standards` submodule. Every rule change in
this release loosens, so a repo compliant before stays compliant.
