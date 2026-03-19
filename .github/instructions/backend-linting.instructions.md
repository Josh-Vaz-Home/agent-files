---
description: "Use when creating or updating FastAPI and Python linting or type-checking agents, instructions, or skills in this repository. Covers Ruff, MyPy strict mode, and Pylance strict editor analysis."
applyTo: ".github/agents/backend-lint.agent.md, .github/agents/backend-style-specialist.agent.md, .github/agents/backend-type-specialist.agent.md, .github/skills/backend-lint-playbook/**"
---
# Backend Linting Guidance

- Use `pip`/`python -m ...` command examples.
- Ruff is the baseline linter and formatter workflow.
- Prefer real fixes over ignore-based cleanup.
- `mypy --strict` is required in CLI guidance.
- Pylance strict mode is required in editor guidance.
- No typing carve-outs are allowed by default; do not normalize `Any` or undocumented `type: ignore` usage.
- Public APIs should usually keep concise docstrings.
- Do not merge SonarQube, Bandit, or dependency scanning into this lane.
