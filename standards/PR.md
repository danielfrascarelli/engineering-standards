# Pull Request Standards

## Pull request size

Prefer small, reviewable pull requests.

A PR should ideally represent one logical change.

Avoid mixing:

- feature work and unrelated refactors;
- dependency upgrades and behavior changes;
- mass formatting and functional changes.

## Description

A useful PR description contains:

- problem or goal;
- solution summary;
- important tradeoffs;
- testing performed;
- migration or deployment notes when relevant.

## UI changes

Include screenshots or recordings when visual behavior changes materially.

## Reviewer expectations

Reviewers should focus on:

- correctness;
- security;
- maintainability;
- architecture consistency;
- test quality;
- backwards compatibility;
- operational impact.

## Author expectations

Before requesting review:

- self-review the diff;
- remove debug code;
- remove unrelated changes;
- run required checks;
- update documentation if behavior changed.
