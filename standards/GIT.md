# Git Standards

## Branches

Preferred branch prefixes:

```text
feat/
fix/
refactor/
chore/
docs/
test/
hotfix/
```

Examples:

```text
feat/user-profile
fix/token-refresh
refactor/payment-service
```

Use short, descriptive, lowercase names separated by hyphens.

## Commits

Use Conventional Commits when practical:

```text
feat: add profile image upload
fix: prevent duplicate invoice creation
refactor: isolate payment validation
chore: update lint configuration
```

Rules:

- One commit should represent one logical intention.
- Keep commits buildable when practical.
- Do not mix formatting-only changes with behavior changes.
- Do not commit generated build artifacts unless the repository requires them.
- Do not commit secrets, local environment files, or editor state.

## Before push

Run relevant checks:

```text
tests
lint
format check
typecheck
build
```

## Rebasing and merging

- Rebase local feature work when it improves history clarity.
- Never rewrite shared protected branch history.
- Avoid unnecessary merge commits in short-lived feature branches.
- Resolve conflicts deliberately; never accept all incoming/current changes blindly.

## Protected branches

Typical protected branches:

```text
main
master
production
release/*
```

Direct pushes to protected branches should be disabled unless operationally required.
