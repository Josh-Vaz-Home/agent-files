---
name: frontend-lint-playbook
description: "React and TypeScript linting and type-check playbook for Vite SPAs. Use for ESLint, Prettier, import hygiene, strict compiler cleanup, and zero-warning frontend lint standards."
---
# Frontend Lint Playbook

## When to use
- Fixing frontend lint warnings
- Running formatting or import-order cleanup
- Cleaning up strict TypeScript errors

## CLI references
- `npx eslint . --max-warnings 0`
- `npx eslint . --fix`
- `npx prettier --check .`
- `npx prettier --write .`
- `npx tsc --noEmit`

## Guidance
- Assume a Vite SPA with React 19, Node.js 22+, ESLint, Prettier, and `tsc --noEmit`.
- Zero lint warnings by default.
- Avoid `any`, `ts-ignore`, and non-null assertions except at justified boundaries.
- Re-run verification after autofix work.
- Preserve application behavior, route contracts, and auth/session safety while fixing static issues.
- Remove unused code and imports instead of suppressing them.

## Compact pattern

### Narrow types instead of asserting them away

```tsx
type BillingState =
	| { status: "idle" }
	| { status: "loading" }
	| { status: "ready"; seatsUsed: number }
	| { status: "error"; message: string };

function BillingSummary({ state }: { state: BillingState }): JSX.Element {
	if (state.status === "loading") {
		return <p role="status">Loading billing summary…</p>;
	}

	if (state.status === "error") {
		return <p role="alert">{state.message}</p>;
	}

	if (state.status === "ready") {
		return <p>{state.seatsUsed} seats in use</p>;
	}

	return <p>No billing data loaded yet.</p>;
}
```

### Guard nullable data before render

```tsx
function PlanBadge({ plan }: { plan?: { name: string } }): JSX.Element | null {
	if (!plan) return null;
	return <span>{plan.name}</span>;
}
```
