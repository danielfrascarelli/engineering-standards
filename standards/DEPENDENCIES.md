# Dependency Standards

Owner: dependency intake, licenses, version pinning, lockfiles, removal, vulnerability patching cadence.

Security constraints that cannot be overridden live in [SECURITY.md](SECURITY.md).

## Intake

Before adding a dependency, answer all of these. Answer goes in the PR description.

- Can the platform or existing code solve this well enough?
- Is the package maintained? Check last release and open issue response.
- Is the license acceptable for this project?
- Is it widely trusted, or a thin wrapper you could inline?
- What permissions or runtime capabilities does it gain? Network, filesystem, child process, install scripts.
- What does it cost in bundle size and attack surface?

Rules:

- MUST NOT add a dependency with an unacceptable or missing license.
- MUST NOT add a dependency with unclear ownership or abandoned maintenance to a production path.
- Dependency touching authentication, cryptography, parsing, or deserialization MUST get a security review. See [SECURITY.md](SECURITY.md).
- A dependency that only saves a few lines SHOULD be inlined instead.

## Versioning and pinning

- Lockfile MUST be committed.
- Lockfile change MUST be intentional. MUST NOT ship unrelated lockfile churn in a feature PR.
- Deployed application SHOULD pin exact versions for runtime dependencies.
- Published library SHOULD use a compatible range, so consumers can dedupe.
- Production systems SHOULD use stable releases. Prereleases need a stated reason.
- MUST review breaking changes before a major upgrade.

One pinning rule, one place. Stack docs MUST NOT restate it.

## Upgrades

- Dependency upgrade SHOULD be its own PR. See [PR.md](PR.md).
- MUST NOT mix a dependency upgrade with behavior change in the same PR.
- Security patch upgrade MAY skip the separate-PR rule when an incident is open.

## Removal

- Dependency left unused **by your change** MUST be removed in the same PR.
- Dependency already unused **before** your change SHOULD be removed in a separate `chore/` PR. Report it, do not silently expand scope. See [AGENTS.md](../AGENTS.md).
- MUST NOT keep a package "just in case".

## Vulnerabilities

- The `security` check reports known vulnerabilities. See [CHECKS.md](CHECKS.md).
- Critical or high severity in a production path MUST be patched or mitigated before next release.
- Low severity, or vulnerability in a dev-only dependency, SHOULD be tracked and batched.
- Suppressing an advisory MUST record the advisory identifier and the reason. Blanket suppression MUST NOT be used.
