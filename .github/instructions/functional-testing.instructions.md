---
description: "Use when creating or updating Playwright browser-testing agents or guidance in this repository. Covers browser journeys, auth setup choices, seeded data, visual regression, performance signals, and strict anti-flake defaults."
applyTo: ".github/agents/functional-test.agent.md, .github/skills/playwright-patterns/**, .github/skills/playwright-ci-debug/**"
---

# Functional Testing Guidance

## Lane ownership

- `functional-test` is the only Playwright parent in this library.
- It explicitly owns Playwright specs, page objects, fixtures or setup helpers, auth bootstrap helpers, storage-state artifacts, snapshot baselines, and failure artifacts.
- Keep frontend and backend unit or integration tests out of this lane.

## Commands and stack

- Keep commands near the top of both the agent and related skills.
- Use `npm`-based Playwright examples.
- Assume adopted repos may place browser tests under `tests/e2e/**`, `frontend/tests/e2e/**`, or `apps/web/tests/e2e/**`.

## Auth setup decision points

- Do not hard-code one auth bootstrap pattern as the only correct answer.
- Present repo-specific decision points and tradeoffs between UI login, API-assisted setup, and `storageState` reuse.
- Make role coverage explicit when the consuming repo has multiple permission levels.
- Keep storage-state files scoped and reviewable instead of burying auth magic in opaque helpers.

## Test-data defaults

- Prefer backend or API helper seeding before direct database setup.
- Coordinate with `postgres` only when DB-level setup, constraints, or migrations are the real concern.
- Fixture factories are acceptable when they keep intent readable and avoid giant shared fixtures.

## Anti-flake defaults

- Ban `waitForTimeout`-style sleeps as a normal synchronization strategy.
- Treat retries as diagnostic rather than a fix.
- When Browser or DevTools MCP tools are available, use them to inspect console, network, DOM, or storage state before raising retries or broadening timeouts.
- Ask first before broad timeout increases or retry inflation.
- Prefer stable selectors, explicit waits on UI or network state, and artifact-backed triage.

## Artifacts, visuals, and performance

- Capture trace, screenshot, and video artifacts on failure.
- Treat screenshot baselines and visual regression checks as first-class lane ownership.
- Keep CI-debug work for traces, reports, screenshots, and videos inside the same Playwright lane instead of inventing a separate browser-debug parent.
- Keep CI failure triage for Playwright and browser-level runs inside the `functional-test` lane.
- Treat performance signals as first-class evidence when they measure representative user-visible behavior.
- Require environment notes for performance claims; do not imply benchmark-grade precision from ad hoc local runs.

## Monorepo adoption notes

- Prefer explicit frontend roots in consuming repos with `frontend/` or `apps/web/`.
- Keep shared helper code under the browser-test root instead of leaking it into product implementation folders.
