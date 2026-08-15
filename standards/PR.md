# Pull Request Standards

Owner: PR size, description fields, approvals, review focus.

Every change to a protected branch arrives through a PR. MUST. See [GIT.md](GIT.md).

## Size

One PR, one logical change. MUST.

MUST NOT mix:

- feature work and unrelated refactor;
- dependency upgrade and behavior change;
- mass reformatting and functional change.

Large unavoidable change SHOULD be split into a stacked series, each reviewable alone.

## Description

These fields are canonical. Agent reports reuse them. See [../AGENTS.md](../AGENTS.md).

| Field | Required |
| --- | --- |
| Problem or goal | MUST |
| Solution summary | MUST |
| Testing performed | MUST |
| Tradeoffs, and alternatives rejected | SHOULD |
| Migration or deployment notes | MUST when deploy or data change is involved |
| Deviations: any SHOULD rule not followed, with reason | MUST when a deviation exists |

Template: [.github/pull_request_template.md](../.github/pull_request_template.md).

UI behavior changed? Attach screenshot or recording. MUST.

## Before requesting review

- Self-review the diff first. MUST.
- Remove debug code and unrelated changes. MUST.
- Run all six checks. MUST. See [CHECKS.md](CHECKS.md).
- Update docs if behavior changed. MUST. See [DOCUMENTATION.md](DOCUMENTATION.md).

## Approvals

- Minimum one approval from someone who did not write the code. MUST.
- Change to authentication, authorization, cryptography, or secret handling MUST get a second approval from a code owner. See [SECURITY.md](SECURITY.md).
- Author MUST NOT approve or merge their own PR.
- Failing required check blocks merge. MUST.
- Code owners: [.github/CODEOWNERS](../.github/CODEOWNERS).

## Reviewer focus

In priority order:

1. Correctness.
2. Security.
3. Test quality.
4. Backwards compatibility and operational impact.
5. Architecture consistency.
6. Maintainability.

Reviewers SHOULD skip pure formatting comments. Formatter owns formatting. See [CHECKS.md](CHECKS.md).

Reviewer blocking a PR MUST name the rule or the concrete failure. "I would write it differently" is not a blocker.
