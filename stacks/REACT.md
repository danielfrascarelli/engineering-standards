# React Standards

Global rules are not repeated here. Ownership map: [../README.md](../README.md).

Shared JavaScript and TypeScript rules live in [NODE.md](NODE.md). This file covers only what is React-specific.

## Runtime and version

- Build tool MUST be Vite for a client-only application. MUST NOT introduce Next.js, CRA, or another server-rendering framework into an app with no SEO and no SSR requirement.
- Node version for build and tooling MUST be pinned. See [NODE.md](NODE.md).
- Pinning through a tool-version manager alone is not enough. `.nvmrc` and `engines.node` MUST also be present, so a contributor not using that manager still gets a signal.
- React major version MUST be stated in the README. Bumping it is a MAJOR change for the app. See [../standards/RELEASES.md](../standards/RELEASES.md).

## Language and types

- New app MUST use TypeScript. Same strength as [NODE.md](NODE.md). No weaker.
- `"strict": true` MUST be set, plus `noUncheckedIndexedAccess`, `noUnusedLocals`, `noUnusedParameters`, and `noFallthroughCasesInSwitch`.
- MUST NOT use `any` in application code. Type an untrusted boundary as `unknown` and narrow it with a schema parse.
- Component props MUST be typed. MUST NOT type props as `any` or as an index signature to dodge an error.
- `import.meta.env` MUST be typed by augmenting `ImportMetaEnv` in `src/vite-env.d.ts`. MUST NOT read an environment variable untyped.
- Every schema MUST export its inferred type beside it (`export type LoginValues = z.infer<typeof loginSchema>`). Form and API types are derived from schemas, never hand-written in parallel.

## Project structure

Group by layer at the top of `src/`, by domain one level down:

```text
src/api/          one module per resource
src/hooks/        data-fetching hooks over api/
src/stores/       global client state
src/lib/          http client, query client, schemas, utils
src/pages/        route-level components, by domain
src/components/   ui/ (vendor primitives) plus domain folders
src/test/         shared test helpers
```

- Dependency direction MUST be declared and enforced in review: `components/ui/` imports only `lib/utils`; `components/<domain>/` imports `ui/` and `lib/` but never a page and never a store; `stores/` import nothing from `components/` or `pages/`; only `pages/` read route params.
- MUST NOT import into another feature's internals. Go through its public entry point.
- Application components and pages MUST be `PascalCase.tsx` with a default export. Vendor-generated primitives keep their upstream lowercase filenames and named exports, in their own directory.
- Two files whose names differ only in casing MUST NOT sit in the same directory. TypeScript fails with TS1149 even on a case-sensitive filesystem, so `Button.tsx` cannot live beside `button.tsx`.
- MUST NOT create barrel or `index.ts` re-export files. Import each module by its direct path.
- One `@` path alias to `src/` MUST be declared and kept in sync across `tsconfig.json`, the Vite config, and the test config. Relative imports climbing more than one directory MUST NOT be used.
- Test config SHOULD live in its own `vitest.config.ts` when the Vite config carries build-only or dev-only plugins.
- A vendor- or tool-generated config file MUST say so in a header comment and MUST be excluded from the formatter's scope, so regeneration does not fight the formatter.

## Lint and format

- ESLint MUST include `eslint-plugin-react-hooks`, with its rules set to error. A formatter alone does not satisfy the lint gate: without this plugin, rules-of-hooks and exhaustive-deps are unenforced, and every effect rule below becomes unverifiable.
- `eslint-plugin-jsx-a11y` SHOULD be enabled.
- A formatter that rewrites code is a correctness tool, not a cosmetic one. Its config MUST be committed and its minimum version MUST be pinned.
- Formatter and config rules otherwise follow [NODE.md](NODE.md).

Commands: [../standards/CHECKS.md](../standards/CHECKS.md).

## Styling

- Tailwind MUST be wired through its Vite plugin. Theme is defined in the CSS entrypoint.
- MUST NOT use CSS-in-JS, or a component framework carrying its own theme system.
- One token system MUST exist: fill the design-system semantic names with brand values in `:root`, and put brand-only names in the same theme block.
- Components MUST use semantic utility classes. A hardcoded hex literal or an arbitrary `bg-[#...]` value is a review finding.
- Class names MUST be composed through a single `cn()` helper. Component variants MUST be expressed with a variance helper, not string concatenation.
- Shipping a `.dark` token block MUST come with a working theme toggle in the same change. Dark tokens nothing can reach are dead weight that reads as support.

## State

Every piece of state has exactly one home. Picking the wrong one is the main architectural mistake available in a React app.

| Kind | Home |
| --- | --- |
| Server-owned data | data-fetching cache |
| Global client state | one store, one module per concern |
| Everything else | component state |

- Server data MUST NOT be copied into the client store. That duplication is what the cache exists to avoid.
- A deliberate exception MUST be documented inline at the store, with the reason. An access token held in the store because it must be read synchronously by the HTTP client is a legitimate exception; it is not cached server state.
- MUST NOT store derived state. Compute during render.
- MUST NOT keep two copies of the same state in sync by hand.
- Modal-open, active-tab, password-visibility, and preview state MUST NOT be lifted out of the component that owns it.
- Selector-less store reads MAY be used for rarely-changing state. Fine-grained selectors SHOULD be added when a measurement shows a render problem, not before.

## Data fetching

- Every network call MUST go through a single typed client module. Components and pages MUST NOT call `fetch` or an HTTP library directly.
- All transport failures MUST be normalized into one typed error class carrying `status` and `code`. A rejected request is represented as status `0`; a missing error envelope falls back to a known code.
- API responses MUST be parsed with a schema at the boundary, not cast. A backend that drifts then fails loudly instead of leaking `undefined` into the store.
- Data access MUST be layered: client, then `api/<resource>.ts` returning typed parsed promises, then a hook. A component MUST NOT call an `api/` function directly.
- Query client defaults MUST be set in one module, with each choice justified in a comment.
- Query keys MUST be `as const` factory objects. MUST NOT be inline array literals at the call site.
- The cache's `signal` MUST be threaded into the HTTP client, so in-flight requests abort on unmount or key change.
- Error codes MUST be mapped to user-facing copy in a named function at the page boundary, not inline in JSX.

## Routing

- Route table MUST live in a single module. MUST NOT scatter route definitions across feature files.
- Access tiers MUST be expressed as guard wrapper components around route elements.
- Redirects MUST use `replace`, so guards do not pollute history.
- The router MUST stay unmounted until the boot-time session restore settles. A guard evaluating against an unrestored session logs a returning user out on reload.
- An authenticated user MUST be redirected away from public auth routes, so the back button cannot park them on a login screen.
- A `path="*"` fallback route MUST exist and MUST re-enter the guard chain.
- Route-level lazy loading plus a suspense boundary MUST be used for a public or SEO-facing app. It MAY be skipped for an internal tool, and skipping it MUST be recorded with the resulting bundle size.

## Forms

- Every form MUST use a form library with a schema resolver. Hand-rolled `onChange` validation MUST NOT be used.
- Schemas MUST live in one module, so validation wording stays consistent. Shared field rules are factored into named primitives.
- `<form>` MUST carry `noValidate`. The schema owns validation, not the browser.
- Submit-button loading state MUST be driven by the form's own submitting flag. A hand-rolled `loading` boolean MUST NOT be used.
- One `FormField` wrapper MUST spread props onto the input so registration binds with no adapter, and MUST wire `aria-invalid` and `aria-describedby` to the error element automatically.
- Controlled third-party widgets MUST be wrapped in the library's controller. MUST NOT be synced into form state with an effect.
- Server-side submit failures MUST surface through a root-level form error rendered in a `role="alert"` banner, distinct from field errors.
- Deliberately *not* tightening a validation rule MUST be recorded in a comment beside the field. A URL field left as a plain string because operators point it at LAN devices is a decision, and it needs to read as one.
- Validation MUST also run at the boundary that persists the data. Browser or client validation MUST NOT be the only layer. See [NODE.md](NODE.md).

## Effects and hooks

- MUST NOT use an effect for a value derivable during render.
- An effect is for synchronization with an external system. It MUST handle cleanup and MUST have a correct dependency array.
- MUST NOT silence the exhaustive-deps rule to make an effect run less often. Restructure instead.
- Reusable stateful behavior SHOULD move into a custom hook, named starting with `use`, following the rules of hooks.
- Server data SHOULD be handled by the data-fetching cache, not by hand-rolled effect plus state.

## Rendering

- List items MUST have a stable key: an entity id, or a member of a constant literal union. `key={index}` MUST NOT be used where the list can reorder.
- A key MUST be unique within its list. Keying navigation items by a `to` or `href` value fails silently the moment two entries share `"/"` or `"#"`.
- MUST NOT memoize before measuring. Premature `useMemo`, `useCallback`, and `React.memo` are review findings, not best practice.
- Images SHOULD carry explicit dimensions, and `loading="lazy"` below the fold.
- A bundle-size budget SHOULD be set and enforced at build time, or an exemption recorded naming the deployment context.

## Errors

- An error boundary MUST sit above each independently recoverable region, and above the router. Without one, a single render throw white-screens the whole app.
- MUST NOT render a raw error object or stack trace to the user.
- A failed request MUST produce a user-visible state, never a silent blank region.

## Logging

- MUST NOT leave `console.log` in shipped code.
- Client error reporting SHOULD go to one reporting service.
- MUST NOT send personal data or tokens to a client-side reporting service. See [../standards/SECURITY.md](../standards/SECURITY.md).

## Security notes

Mandatory rules live in [../standards/SECURITY.md](../standards/SECURITY.md). React specifics:

- The access token MUST be held in memory only. MUST NOT be written to `localStorage`, `sessionStorage`, or a cookie a script can read.
- The refresh token MUST arrive as an `httpOnly` cookie scoped to the auth path, and MUST NOT appear in a response body. The response schema MUST NOT contain a refresh-token field.
- `credentials: "include"` MUST be set once in the shared client, not per call site.
- A 401 auto-refresh path MUST exist before any page consumes a protected endpoint. A short-lived access token without one is a known-broken session that fails minutes after login.
- The `SameSite` posture MUST be documented: `lax` is sufficient only while frontend and API share a registrable domain. A cross-domain split requires `SameSite=None; Secure` plus a CSRF token on the refresh endpoint, in the same change.
- Session state MUST be cleared in the mutation's settled callback, not its success callback, so a failed logout request still logs the user out locally. The query cache is cleared alongside it.
- A token acquired without a successfully loaded profile MUST be treated as a half-open session and dropped.
- A fixture or mock login path that produces an authenticated session without a real credential MUST NOT ship. Gate it behind a build flag or delete it.
- Every client-side environment variable is public and is inlined into the bundle. MUST NOT put a secret in one, whatever the prefix. The environment template MUST say so.
- MUST NOT use `dangerouslySetInnerHTML` with unsanitized content.
- A client-side route guard is a UX affordance, not authorization. The server MUST enforce it.

## Accessibility and internationalization

- Every `<img>` MUST carry a meaningful `alt`. Decorative graphics get `aria-hidden="true"`.
- App chrome MUST use landmark elements (`<main>`, `<nav>`, `<aside>`, `<header>`), not styled `<div>`s.
- Form submission failures MUST be announced with `role="alert"`, and each field error MUST be linked to its input through `aria-describedby` and `aria-invalid`.
- `<html lang>` MUST match the language the UI actually renders. A Spanish UI served as `lang="en"` breaks screen readers and is easy to miss because nothing visibly fails.
- An app with persistent sidebar navigation SHOULD ship a skip-to-content link.
- User-facing copy SHOULD route through an internationalization layer from the first screen. Retrofitting hardcoded strings is the expensive path.
- Code, comments, and commit messages are English. User-facing copy is the product language. See [../standards/GIT.md](../standards/GIT.md).

## Environment and config

- The environment template required by [../standards/SECURITY.md](../standards/SECURITY.md) MUST list every variable the app reads, with its default and the module that consumes it. `.gitignore` MUST cover `.env*` with an exception for the template.
- Environment variables MUST be read in exactly one module, exporting the resolved value as a named constant. MUST NOT sprinkle `import.meta.env` through components.

## Testing

- Test runner MUST be Vitest, with React Testing Library and a user-event library, in a `jsdom` environment.
- Tests MUST be co-located beside their subject as `<Subject>.test.ts(x)`. MUST NOT use a `__tests__` directory.
- Queries MUST be by role or accessible name. MUST NOT query by `container.querySelector`, by class, or by a test id where an accessible query exists.
- Interactions MUST use the user-event library, not raw event dispatch.
- A shared `renderWithProviders` helper MUST build a **fresh** query client per test, with retries off, and MUST accept an initial route.
- Module-singleton stores MUST be reset in `beforeEach`. Store state survives between tests otherwise, and the failure looks like a test-ordering bug.
- Environment polyfills the component library needs — pointer capture, `scrollIntoView`, `matchMedia`, `ResizeObserver` — MUST live in the shared setup file, each with a comment saying why, and global stubs MUST be unstubbed in `afterEach`.
- The network MUST be stubbed at the HTTP boundary, not by mocking the component's own module.
- Coverage thresholds MUST be set in the test config **and** the coverage command MUST run in CI. Measuring coverage without a threshold enforces nothing.
- Tests MUST cover, at minimum: every store transition, every schema rule, each wrapper's mapping onto its primitive, and one end-to-end form path through resolver and network.
- The provider chain and every guard redirect MUST be smoke-tested at the app root. A missing provider otherwise only surfaces at runtime.
- End-to-end tests SHOULD cover critical user flows only.

Strategy and coverage stance: [../standards/TESTING.md](../standards/TESTING.md).
