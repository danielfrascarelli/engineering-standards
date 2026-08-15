# React Standards

## Language

- Use TypeScript unless the project explicitly requires JavaScript.
- Avoid `any`; prefer precise types or `unknown` with validation.

## Components

- Use function components.
- Keep components focused.
- Separate business logic from presentation when complexity justifies it.
- Prefer composition over large configuration-heavy components.
- Avoid components that own unrelated responsibilities.

## State

- Do not store derived state unnecessarily.
- Keep state as local as practical.
- Use global state only for genuinely shared application state.
- Avoid synchronizing multiple copies of the same state.

## Effects

- Do not use `useEffect` for values that can be derived during render.
- Effects are for synchronization with external systems.
- Always reason about cleanup and dependency correctness.

## Hooks

- Extract reusable stateful behavior into custom hooks.
- Keep hooks deterministic.
- Follow React hook rules strictly.

## Rendering

- Use stable keys.
- Avoid premature memoization.
- Optimize only after identifying a real rendering problem.

## Forms

- Validate at appropriate boundaries.
- Do not trust browser validation as the only validation layer.

## Tests

Prefer behavior-oriented tests with Testing Library or the repository's established equivalent.
