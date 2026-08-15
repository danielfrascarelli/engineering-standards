# Release Standards

Owner: versioning, tags, release notes, production change discipline.

## Versioning

Project exposing a versioned artifact or public API MUST use Semantic Versioning.

```text
MAJOR.MINOR.PATCH
```

- MAJOR: incompatible change.
- MINOR: backwards-compatible capability.
- PATCH: backwards-compatible fix.

Pre-1.0 project MAY break on MINOR. It MUST say so in the README.

## Tags

- Release MUST be tagged `vMAJOR.MINOR.PATCH`, for example `v2.4.1`.
- Tag MUST be annotated, not lightweight.
- Tag MUST point at the commit that was built and shipped.
- MUST NOT move or delete a published tag. Ship a new patch instead.

Long-lived release branches use `release/*` and are protected. See [GIT.md](GIT.md).

## Release notes

Every release MUST have notes covering:

- breaking changes, listed first and explicitly;
- new capabilities;
- fixes;
- migration steps, when action is required.

Notes SHOULD be generated from Conventional Commit types. That is why commit type accuracy matters. See [GIT.md](GIT.md).

Repo keeping a `CHANGELOG.md` MUST update it in the release PR, not after the tag.

## Before release

- All six checks pass on the release commit. MUST. See [CHECKS.md](CHECKS.md).
- No critical vulnerability open in a production dependency. MUST. See [DEPENDENCIES.md](DEPENDENCIES.md).
- Migration requirements documented. MUST. See [DOCUMENTATION.md](DOCUMENTATION.md).
- Rollback path known and written down. MUST.

## Production changes

- Production release MUST be reproducible from source control.
- MUST NOT make an undocumented manual production change.
- Emergency manual change MUST be recorded and reconciled back into source control before the next release.

## Versioning this standards repo

This repo is itself versioned. Tightening a MUST rule, or adding a new MUST, is a MAJOR change for consuming repos. Relaxing a rule, or adding a SHOULD, is MINOR.
