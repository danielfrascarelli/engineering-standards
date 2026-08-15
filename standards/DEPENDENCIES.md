# Dependency Standards

## Adding dependencies

Before adding a dependency, ask:

- Can the platform or existing code solve this adequately?
- Is the package maintained?
- Is the license acceptable?
- Is the package widely trusted?
- What permissions or runtime capabilities does it introduce?
- Does it significantly increase bundle size or attack surface?

## Versioning

- Use lockfiles.
- Commit lockfile changes intentionally.
- Avoid unrelated lockfile churn.
- Prefer stable versions for production systems.
- Review breaking changes before major upgrades.

## Removal

Remove unused dependencies.

Do not retain packages "just in case".
