---
description: "Use when creating or updating FastAPI and Python testing agents, instructions, or skills in this repository. Covers pytest unit vs integration boundaries, async behavior, fixtures, and high coverage defaults."
applyTo: ".github/agents/backend-test.agent.md, .github/agents/backend-unit-test-specialist.agent.md, .github/agents/backend-integration-test-specialist.agent.md, .github/skills/backend-test-playbook/**"
---
# Backend Testing Guidance

- Use pytest-based examples with `python -m pytest`.
- Keep async behavior explicit and focus assertions on public behavior and request/response contracts.
- Distinguish unit and integration tests clearly.
- Prefer small explicit function-scoped fixtures with deliberate cleanup.
- Auth coverage should emphasize role or permission behavior, `401` and `403` cases, and authenticated happy paths.
- When real database behavior matters, prefer disposable Postgres containers over SQLite stand-ins.
- If Docker MCP tools are available, use them for disposable Postgres container lifecycle and diagnostics, but keep pytest ownership and fixture intent explicit.
- Default shared coverage guidance should target 85% lines and 80% branches unless a consuming repo intentionally sets different thresholds.
- Keep browser flows out of this lane.
