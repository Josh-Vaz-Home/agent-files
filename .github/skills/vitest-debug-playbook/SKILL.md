---
name: vitest-debug-playbook
description: "Vitest debugging playbook for Vite SPAs. Use when frontend test failures need focused reruns, verbose reporters, watch-mode triage, snapshot decisions, or coverage diagnosis beyond normal test-authoring guidance."
---
# Vitest Debug Playbook

## When to use
- Reproducing a failing frontend test locally
- Narrowing a failure to one file or spec name
- Getting more useful Vitest output from reporters or watch mode
- Deciding whether a snapshot failure is legitimate or just churn
- Investigating coverage gaps after a frontend-test run
- Falling back when GitHub Actions or workflow MCP context is unavailable or incomplete

## CLI references
- `npx vitest run src/components/Button.test.tsx`
- `npx vitest run src/components/Button.test.tsx --reporter=verbose`
- `npx vitest run -t "submits the form"`
- `npx vitest --watch`
- `npx vitest run --coverage`
- `npx vitest run -u`

## Default stance
- Reproduce the failure locally before changing assertions, snapshots, or configuration.
- Narrow the failing scope before broad reruns so the debug loop stays short.
- Use verbose output and targeted runs before adding temporary logging or changing retries.
- Treat snapshot updates as reviewable changes, not cleanup.
- If GitHub Actions or workflow MCP tools are available in the adopted workspace, use them to inspect failed run context, but keep local CLI reproduction explicit.
- Keep this skill focused on failure triage; use `frontend-test-playbook` for normal unit and integration test authoring.

## Compact patterns

### Narrow to one file or test name
Brief rationale: the fastest debug loop is usually a single file or one named spec, not the whole suite.

```text
npx vitest run src/routes/projects.test.tsx --reporter=verbose
npx vitest run -t "maps the server error back into the form"
```

- Start with one failing file if CI already identified it.
- Use `-t` when the file contains several unrelated specs and only one is flaky or broken.

### Watch-mode triage
Brief rationale: watch mode is useful when the failure is easy to reproduce and you expect several quick edits.

```text
npx vitest --watch
```

- Prefer watch mode for local iteration, not as proof that the failure is fixed.
- If the failing spec passes only intermittently in watch mode, treat that as instability, not success.

### Snapshot decision note
Brief rationale: snapshot updates should explain why the rendered output changed, not just that the tool accepted it.

```text
npx vitest run -u
```

```md
Snapshot triage note
- File: `src/features/billing/__tests__/BillingSummary.test.tsx`
- Change reason: loading state now includes the retry CTA required by the updated UX
- Validation: visual and text assertions now match the rendered component state
- Follow-up: review the snapshot diff in the PR instead of assuming the update is harmless
```

- Update snapshots only after confirming the UI change is intentional.
- Pair the snapshot update with a user-visible explanation in the PR or test note.

### Coverage triage cue
Brief rationale: coverage should guide missing behavior checks, not drive random assertion stuffing.

```text
npx vitest run --coverage
```

- Use coverage output to find missing route-state, error-path, or auth/session assertions.
- Prefer one meaningful missing behavior test over several shallow assertions that only move the percentage.
