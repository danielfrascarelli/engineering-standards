# Release Standards

## Versioning

Use Semantic Versioning when the project exposes a versioned artifact or public API:

```text
MAJOR.MINOR.PATCH
```

- MAJOR: incompatible change.
- MINOR: backwards-compatible functionality.
- PATCH: backwards-compatible fix.

## Release preparation

Before release:

- required tests pass;
- build succeeds;
- migration requirements are documented;
- breaking changes are explicit;
- release notes are updated when applicable.

## Production changes

Production releases should be reproducible from source control.

Avoid undocumented manual production changes.
