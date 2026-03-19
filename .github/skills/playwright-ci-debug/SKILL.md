---
name: playwright-ci-debug
description: "Playwright CI debug playbook. Use when browser-test failures need trace replay, report navigation, screenshot diff review, flaky-run triage, or artifact-driven diagnosis after CI failures."
---
# Playwright CI Debug

## When to use
- Investigating a failed Playwright run from CI artifacts
- Replaying a `trace.zip` locally after a browser-test failure
- Opening the Playwright HTML report from downloaded artifacts
- Reviewing screenshot or video evidence before changing retries or timeouts
- Comparing a CI-only failure against a targeted local rerun
- Falling back when Browser or DevTools or workflow MCP context is unavailable or incomplete

## CLI references
- `npx playwright show-trace artifacts/<run-id>/trace.zip`
- `npx playwright show-report artifacts/<run-id>/playwright-report`
- `npx playwright test tests/e2e/login.spec.ts --project=chromium --headed`
- `npx playwright test --grep "login" --project=chromium`
- `npx playwright test tests/e2e/login.spec.ts --reporter=line`

## Default stance
- Start from the CI artifact, not from a guessed local explanation.
- Review trace, screenshot, video, and report evidence before changing retries, selectors, or timeouts.
- Use a targeted local rerun to confirm or falsify the CI-only hypothesis.
- Keep environment notes explicit: browser, headed or headless mode, OS, base URL, seeded data, and auth state.
- Use `github-cli-playbook` when the main problem is locating or downloading the CI artifacts rather than interpreting them.
- If Browser or DevTools MCP tools are available in the adopted workspace, use them after artifact review; Playwright artifacts remain the primary evidence.
- Keep this skill focused on CI failure investigation; use `playwright-patterns` for authoring specs, page objects, fixtures, and auth bootstrap.

## Compact patterns

### Replay a CI trace and report
Brief rationale: a trace or report usually explains more than a flaky rerun with no artifacts attached.

```text
npx playwright show-trace artifacts/987654321/trace.zip
npx playwright show-report artifacts/987654321/playwright-report
```

- Record the run ID and artifact path in the triage note.
- Check console errors, network timing, final DOM state, and the failing step before changing the test.

### CI-only reproduction loop
Brief rationale: a CI-only failure needs one narrow local command that mirrors the failing path, not a full-suite rerun.

```text
npx playwright test tests/e2e/login.spec.ts --project=chromium --headed
npx playwright test --grep "login" --project=chromium
```

- Match the browser project first.
- If the failure disappears locally, keep the mismatch explicit instead of pretending it is fixed.

### Artifact-backed triage note
Brief rationale: CI debug notes should explain what the artifact proved, not just that an artifact existed.

```md
Browser-failure triage
- Run: `987654321`
- Artifact: `artifacts/987654321/trace.zip`
- Failing step: click on `Sign in`
- Observed state: auth request returned `401` because the seeded admin account was missing in CI
- Local check: `npx playwright test tests/e2e/login.spec.ts --project=chromium --headed`
- Next owner/lane: `backend` if the seed contract is wrong, `functional-test` if the fixture setup is wrong
```

- Keep the failing step and observed state explicit.
- Separate the evidence from your hypothesis about the root cause.

### Screenshot or baseline triage cue
Brief rationale: visual diffs are only useful when you explain whether the image changed because of the product or the environment.

- Compare the screenshot diff with the trace and final DOM state before updating any baseline.
- If fonts, viewport, or reduced-motion settings differ in CI, record that before changing the snapshot.
- Treat unexplained baseline churn as a bug to investigate, not cleanup.
