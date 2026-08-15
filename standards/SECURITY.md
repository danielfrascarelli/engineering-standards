# Security Standards

Security rules are mandatory and override convenience or local style preferences.

## Secrets

Never commit:

- passwords;
- API keys;
- access tokens;
- refresh tokens;
- private keys;
- certificates containing private material;
- production credentials;
- `.env` files containing secrets.

Use environment variables or an approved secret manager.

If a secret is exposed:

1. Remove it from active code/configuration.
2. Rotate or revoke it immediately.
3. Remove it from repository history when required.
4. Audit usage and access logs when relevant.

## Input and output

- Treat all external input as untrusted.
- Validate input at system boundaries.
- Encode output according to its destination context.
- Avoid dynamic SQL string construction.
- Avoid shell command construction from raw user input.
- Do not deserialize untrusted data using unsafe mechanisms.

## Authentication and authorization

- Authentication proves identity.
- Authorization verifies permission.
- Always enforce authorization server-side.
- Never trust client-side role checks as the only control.
- Use least privilege.
- Deny by default when permission is ambiguous.

## Dependencies

- Prefer maintained packages.
- Avoid dependencies with unclear ownership or abandoned maintenance.
- Review security impact before introducing authentication, crypto, parsing, or serialization libraries.
- Patch known critical vulnerabilities promptly.

## Logging

Never log:

- passwords;
- full access tokens;
- private keys;
- full payment credentials;
- sensitive personal data unless explicitly required and protected.

## Cryptography

- Do not implement custom cryptography.
- Use established libraries and platform primitives.
- Do not invent encryption formats, password hashing algorithms, or signing schemes.
