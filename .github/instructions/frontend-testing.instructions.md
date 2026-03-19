---
description: "Use when creating or updating React and TypeScript testing agents, instructions, or skills in this repository. Covers unit vs integration boundaries, Testing Library expectations, and high coverage defaults."
applyTo: ".github/agents/frontend-test.agent.md, .github/agents/frontend-unit-test-specialist.agent.md, .github/agents/frontend-integration-test-specialist.agent.md, .github/skills/frontend-test-playbook/**, .github/skills/vitest-debug-playbook/**"
---

# Frontend Testing Guidance

- Assume a Vite SPA with React 19, the latest stable TypeScript, Node.js 22+, and Vitest.
- This lane owns Vitest-based unit and integration tests; browser journeys belong to `functional-test.agent.md`.
- Use Testing Library queries and `user-event`.
- Document async handling with `findBy*`, `waitFor`, or equivalent.
- Use `npm` examples and make Vitest the only default frontend test runner.
- If GitHub Actions or workflow MCP tools are available, use them for failed run, log, and artifact context, but keep local reproduction and CLI evidence explicit.
- Keep CI failure triage for Vitest and other frontend unit or integration runs inside this lane.
- Use MSW by default for mocked network behavior in integration tests; reserve ad hoc mocks for isolated edge cases.
- Cover React Router loader/action flows, route-owned loading/error states, and auth/session UI behavior in this lane.
- Full login journeys and browser-auth flows belong to `functional-test.agent.md`.
- Use `vitest-debug-playbook` for rerun, reporter, snapshot, and coverage triage workflows instead of bloating the main test-authoring playbook.
- Use React Hook Form + Zod interaction tests when forms involve server validation, conditional fields or steps, async side effects, or advanced inputs.
- Keep coverage expectations intentionally high unless a consuming repo explicitly decides otherwise.
