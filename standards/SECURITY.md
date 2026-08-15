# Security Standards

Owner: secrets, input handling, authorization, cryptography, log redaction.

MUST rules in this file are never overridable. No repo-level exception, no convenience exception, no style preference. See precedence in [../README.md](../README.md).

## Secrets

MUST NOT commit:

- passwords;
- API keys;
- access tokens;
- refresh tokens;
- private keys;
- certificates containing private material;
- production credentials;
- any file containing a real secret value.

Read secrets from environment variables or an approved secret manager. MUST.

Example files: `.env.example` and `.env.template` MUST be committed and MUST contain placeholder values only. A real value in an example file is a leaked secret.

Files holding real values (`.env`, `.env.local`, `.env.production`) MUST be listed in `.gitignore`.

Repos SHOULD run a secret scanner as part of the `security` check. See [CHECKS.md](CHECKS.md).

### If a secret is exposed

Order matters. Do all four steps.

1. Rotate or revoke the credential immediately. Do this first — removing the code does not un-leak the value.
2. Remove the secret from active code and configuration.
3. Purge it from repository history when the repository is shared or public.
4. Audit access and usage logs for the exposure window.

MUST NOT close the incident after step 2 alone.

## Input and output

- MUST treat all external input as untrusted.
- MUST validate input at system boundaries.
- MUST encode output for its destination context.
- MUST NOT build SQL by string concatenation. Use parameterized queries.
- MUST NOT build shell commands from raw user input.
- MUST NOT deserialize untrusted data with unsafe mechanisms.

## Authentication and authorization

Authentication proves identity. Authorization verifies permission. They are separate controls.

- MUST enforce authorization server-side.
- MUST NOT rely on a client-side role check as the only control.
- MUST apply least privilege.
- MUST deny by default when permission is ambiguous.

## Logging

MUST NOT log:

- passwords;
- full access or refresh tokens;
- private keys;
- full payment credentials;
- sensitive personal data, unless explicitly required and protected.

Redact at the logger, not at each call site. SHOULD.

Log format and correlation identifiers are a stack concern. See [../stacks/](../stacks/).

## Cryptography

- MUST NOT implement custom cryptography.
- MUST use established libraries and platform primitives.
- MUST NOT invent an encryption format, password hashing scheme, or signing scheme.
- Password storage MUST use a memory-hard algorithm such as argon2 or bcrypt. Never a plain hash.

## Dependencies

Security-relevant intake rules live with the dependency owner: [DEPENDENCIES.md](DEPENDENCIES.md).

Two rules stay here because they are mandatory and never overridable:

- Known critical vulnerability in a production dependency MUST be patched or mitigated before the next release.
- A dependency that handles authentication, cryptography, parsing, or deserialization MUST get a security review before it is added.
