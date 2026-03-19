---
name: playwright-patterns
description: "Playwright browser-testing playbook. Use for specs, page objects, auth bootstrap, fixtures, visual baselines, seeded data, and browser-level performance signals."
---
# Playwright Patterns

## When to use
- Writing or refactoring Playwright browser journeys
- Designing page objects or fixtures
- Choosing an auth bootstrap strategy
- Adding visual regression or performance signals
- Hardening flaky browser coverage

## CLI references
- `npm install`
- `npx playwright test`
- `npx playwright test tests/e2e/login.spec.ts`
- `npx playwright test --project=chromium --headed`
- `npx playwright test --update-snapshots`
- `npx playwright show-trace test-results/<test-name>/trace.zip`

## Default stance
- Own specs, page objects, fixtures or setup helpers, auth bootstrap helpers, and snapshot or baseline artifacts.
- Keep browser journeys separate from unit and integration tests.
- Prefer backend or API helper seeding before direct database manipulation.
- If Browser or DevTools MCP tools are available in the adopted workspace, use them for structured console, network, DOM, and storage inspection before increasing retries or timeouts.
- Use `playwright-ci-debug` when the main need is CI trace, report, screenshot, or video triage rather than Playwright authoring.
- Treat `waitForTimeout`-style sleeps as a defect.
- Treat retries as diagnostic, not the fix.
- Capture trace, screenshot, and video artifacts on failure.
- Treat visual regression and user-visible performance signals as first-class coverage.

## Auth setup decision points
- Use UI login when the login flow itself is part of the coverage.
- Use API-assisted setup when login UI is already covered elsewhere and speed or stability matters more.
- Use `storageState` reuse when the session shape is stable and role-specific setup should stay explicit.
- Keep one auth path per role or scenario instead of a giant shared helper that hides too much.

## Compact patterns

### Page object with stable selectors
Brief rationale: page objects should hide repeated interaction steps, not hide the test's intent.

```ts
import { expect, type Locator, type Page } from "@playwright/test";

export class BillingPage {
	constructor(private readonly page: Page) {}

	readonly heading: Locator = this.page.getByRole("heading", { name: "Billing" });
	readonly saveButton: Locator = this.page.getByRole("button", { name: "Save plan" });

	async goto(): Promise<void> {
		await this.page.goto("/settings/billing");
		await expect(this.heading).toBeVisible();
	}

	async save(): Promise<void> {
		await this.saveButton.click();
		await expect(this.page.getByText("Plan updated")).toBeVisible();
	}
}
```

### Auth bootstrap via `storageState`
Brief rationale: keep auth setup explicit, role-scoped, and reviewable.

```ts
import { test as setup, expect } from "@playwright/test";

setup("save admin storage state", async ({ page }) => {
	await page.goto("/login");
	await page.getByLabel("Email").fill("admin@example.com");
	await page.getByLabel("Password").fill("not-a-real-secret");
	await page.getByRole("button", { name: "Sign in" }).click();

	await expect(page).toHaveURL(/dashboard/);
	await page.context().storageState({ path: "playwright/.auth/admin.json" });
});
```

- Replace the UI-login bootstrap with API-assisted setup only when the adopted repo already covers login UI elsewhere.

### Seed data through backend helpers first
Brief rationale: keep browser tests focused on user flows instead of raw SQL setup.

```ts
import { test as base, request } from "@playwright/test";

type SeededFixtures = {
	accountId: string;
};

export const test = base.extend<SeededFixtures>({
	accountId: async ({}, use) => {
		const api = await request.newContext({ baseURL: process.env.E2E_API_BASE_URL });
		const response = await api.post("/test-support/accounts", {
			data: { plan: "pro", seats: 3 },
		});

		const body = await response.json();
		await use(body.id as string);
		await api.delete(`/test-support/accounts/${body.id}`);
		await api.dispose();
	},
});
```

- Coordinate with `postgres` only when constraints, seed size, or migration state make DB-level setup unavoidable.

### Visual baseline check
Brief rationale: baseline updates should be deliberate and reviewable.

```ts
import { expect, test } from "@playwright/test";

test("billing summary stays visually stable", async ({ page }) => {
	await page.goto("/settings/billing");
	await expect(page.getByTestId("billing-summary")).toHaveScreenshot("billing-summary.png");
});
```

- Review baseline churn deliberately. `--update-snapshots` is not a cleanup broom.

### Performance signal with an environment note
Brief rationale: use browser timing as a regression signal only when the environment and data are representative.

```ts
import { expect, test } from "@playwright/test";

test("dashboard render stays within the agreed signal budget", async ({ page }, testInfo) => {
	await page.goto("/dashboard");

	const navigation = await page.evaluate(() => {
		const entry = performance.getEntriesByType("navigation")[0] as PerformanceNavigationTiming | undefined;
		return entry
			? {
				domContentLoaded: entry.domContentLoadedEventEnd,
				load: entry.loadEventEnd,
			}
			: null;
	});

	testInfo.annotations.push({
		type: "environment",
		description: "Local Chromium run on a developer machine. Use as a regression signal, not a benchmark.",
	});

	if (!navigation) {
		throw new Error("Navigation timing entry missing.");
	}

	expect(navigation.domContentLoaded).toBeLessThan(1500);
});
```

### Anti-flake triage cues
- Replace sleep calls with user-visible or network-state waits.
- Attach trace, screenshot, and video artifacts before changing retries or timeouts.
- If a test only passes on retry, treat it as unstable until the root cause is identified.
