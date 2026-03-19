---
name: frontend-test-playbook
description: "React and TypeScript frontend testing playbook for Vite SPAs. Use for Vitest, Testing Library, user-event, React Router flows, async UI behavior, MSW-backed mocks, and coverage expectations."
---
# Frontend Test Playbook

## When to use
- Writing frontend unit tests
- Writing frontend integration tests
- Improving async UI test reliability

## CLI references
- `npm run test`
- `npm run test:watch`
- `npm run test:coverage`
- `npx vitest run src/components/Button.test.tsx`

## Guidance
- Assume a Vite SPA with React 19, Node.js 22+, Vitest, Testing Library, `user-event`, and MSW.
- Use Testing Library queries and `user-event`.
- Keep browser journeys out of this lane.
- Avoid arbitrary timer-based waits.
- If GitHub Actions or workflow MCP tools are available in the adopted workspace, use them for failed run, log, and artifact context before assuming the local reproduction is complete.
- Keep coverage targets high by default.
- Use MSW by default for mocked HTTP; reserve ad hoc mocks for isolated edge cases.
- Exercise route-owned data and mutations through React Router loaders/actions when the route owns the contract.
- Test React Hook Form + Zod flows through real user interaction and clear error assertions.
- Keep full login and browser-auth journeys in `functional-test`; keep session-aware UI in this lane.
- Use `vitest-debug-playbook` when the primary need is CLI failure triage, reporter changes, snapshot updates, or coverage diagnosis.

## Compact patterns

### Route-aware integration tests
- Render the route or layout boundary that owns the loader/action.
- Assert loading, empty, success, and error states from the user’s point of view.

```tsx
import { HttpResponse, http } from "msw";
import { createMemoryRouter, RouterProvider } from "react-router-dom";
import { render, screen } from "@testing-library/react";

it("shows the empty state for a route-owned loader", async () => {
	server.use(http.get("/api/projects", () => HttpResponse.json([])));

	const router = createMemoryRouter(
		[{ path: "/projects", loader: projectsLoader, element: <ProjectsRoute /> }],
		{ initialEntries: ["/projects"] },
	);

	render(<RouterProvider router={router} />);

	expect(await screen.findByText(/no projects yet/i)).toBeInTheDocument();
});
```

### Form interaction tests
- Drive the form with `user-event`, assert client validation, then assert server-error mapping if the backend rejects the submission.

```tsx
import { HttpResponse, http } from "msw";
import userEvent from "@testing-library/user-event";
import { render, screen } from "@testing-library/react";

it("maps a server validation error back into the form", async () => {
	server.use(
		http.post("/api/team/invitations", () =>
			HttpResponse.json(
				{ fieldErrors: { email: "That user is already a member." } },
				{ status: 400 },
			),
		),
	);

	const user = userEvent.setup();
	render(<InviteMemberForm />);

	await user.type(screen.getByLabelText(/email/i), "owner@example.com");
	await user.click(screen.getByRole("button", { name: /send invite/i }));

	expect(await screen.findByText(/already a member/i)).toBeInTheDocument();
});
```

### Auth/session checks
- Mock session endpoints with MSW and verify login, logout, role-aware rendering, or session refresh behavior when those flows matter.

```tsx
import { HttpResponse, http } from "msw";
import { render, screen } from "@testing-library/react";

it("hides admin controls for a member session", async () => {
	server.use(
		http.get("/api/session", () =>
			HttpResponse.json({ user: { id: "1" }, roles: ["member"] }),
		),
	);

	render(<AppShell />);

	expect(await screen.findByText(/projects/i)).toBeInTheDocument();
	expect(screen.queryByRole("link", { name: /admin/i })).not.toBeInTheDocument();
});
```

### Manual smoke cues
- Tab through primary actions and verify visible focus.
- Check 375px, 768px, and 1024px layouts.
- Walk loading, empty, and error states.
- Verify logout or refresh keeps session UI consistent.
