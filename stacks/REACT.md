# React Standards

Global rules are not repeated here. Ownership map: [../README.md](../README.md).

Shared JavaScript and TypeScript rules live in [NODE.md](NODE.md). This file covers only what is React-specific.

## Runtime and version

- Node version for build and tooling MUST be pinned. See [NODE.md](NODE.md).
- React major version MUST be declared in the README. Upgrading a React major is a MAJOR change for the app. See [../standards/RELEASES.md](../standards/RELEASES.md).

## Language and types

- New app MUST use TypeScript. Same strength as [NODE.md](NODE.md). No weaker.
- MUST NOT use `any`. Use `unknown` plus validation at the boundary.
- Component props MUST be typed. MUST NOT type props as `any` or as an index signature to dodge errors.

## Project structure

- Group by feature, not by file type. SHOULD.
- Shared primitives live in one shared location. MUST NOT copy a component between features.
- Component file name MUST match the exported component name.
- MUST NOT import across feature boundaries into another feature's internals. Go through its public entry point.

## Lint and format

- ESLint MUST include `eslint-plugin-react-hooks`. Its rules MUST be errors, not warnings.
- `eslint-plugin-jsx-a11y` SHOULD be enabled.
- Formatter and config rules follow [NODE.md](NODE.md).

Commands: [../standards/CHECKS.md](../standards/CHECKS.md).

## Components

- MUST use function components.
- Component SHOULD own one responsibility.
- SHOULD separate business logic from presentation once complexity justifies it.
- SHOULD prefer composition over a large configuration-heavy component.

## State

- MUST NOT store derived state. Compute during render.
- State MUST live as local as practical.
- Global state is only for genuinely shared application state. MUST.
- MUST NOT keep two copies of the same state in sync manually.
- Server data SHOULD be handled by a data-fetching cache, not by hand-rolled `useEffect` plus `useState`.

## Effects

- MUST NOT use `useEffect` for a value derivable during render.
- Effect is for synchronization with an external system. MUST.
- Effect MUST handle cleanup and MUST have a correct dependency array.
- MUST NOT silence the exhaustive-deps rule to make an effect run less often. Restructure instead.

## Hooks

- Reusable stateful behavior SHOULD move into a custom hook.
- Hook MUST follow the rules of hooks. No conditional calls.
- Custom hook name MUST start with `use`.

## Rendering

- List item MUST have a stable key. MUST NOT use array index when the list can reorder.
- MUST NOT memoize before measuring. Optimize after identifying a real rendering problem.

## Forms

- Validation MUST run at the boundary that persists data, not only in the browser. See [NODE.md](NODE.md).
- Browser validation MUST NOT be the only validation layer.

## Errors

- App MUST have an error boundary above each independently recoverable region.
- MUST NOT render a raw error object or stack trace to the user.
- Failed request MUST produce a user-visible state, never a silent blank region.

## Logging

- MUST NOT leave `console.log` in shipped code.
- Client error reporting SHOULD go to one reporting service.
- MUST NOT send personal data or tokens to a client-side reporting service. See [../standards/SECURITY.md](../standards/SECURITY.md).

## Security notes

Mandatory rules live in [../standards/SECURITY.md](../standards/SECURITY.md). React specifics:

- MUST NOT use `dangerouslySetInnerHTML` with unsanitized content.
- Every client-side environment variable is public. MUST NOT put a secret in one, whatever the prefix.
- Client-side route guard is a UX affordance, not authorization. Server MUST enforce it.

## Testing

- Test runner MUST be Vitest or Jest. One per repo.
- Component test MUST use Testing Library and query by accessible role or label, not by CSS class or test-id-only selectors.
- Network MUST be stubbed at the HTTP boundary, not by mocking the component's own module.
- End-to-end tests SHOULD cover critical user flows only.

Strategy and coverage stance: [../standards/TESTING.md](../standards/TESTING.md).
