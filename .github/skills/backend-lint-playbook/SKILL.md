---
name: backend-lint-playbook
description: "FastAPI and Python linting and type-check playbook. Use for Ruff, MyPy strict mode, Pylance strict alignment, formatting, import hygiene, and typed public APIs."
---
# Backend Lint Playbook

## When to use
- Fixing backend style and typing issues
- Cleaning up Ruff findings
- Resolving MyPy strict or Pylance strict diagnostics

## Quick setup
- `python -m venv .venv`
- `python -m pip install -r requirements.txt`

## CLI references
- `python -m ruff check .`
- `python -m ruff check . --fix`
- `python -m ruff format . --check`
- `python -m ruff format .`
- `python -m mypy . --strict`

## Editor references
- Pylance `python.analysis.typeCheckingMode = strict`
- Pylance `python.analysis.diagnosticMode = workspace`

## Default stance
- Use Ruff as the baseline formatter/linter workflow.
- Treat Pylance strict mode as required editor analysis.
- Prefer direct fixes over ignore-based cleanup.
- Avoid undocumented `Any` and `type: ignore` in public APIs.
- Typing carve-outs are not allowed by default.
- Public APIs should usually keep concise docstrings when they clarify intent.

## Compact patterns

### Fix the type, not the warning
Brief rationale: `mypy --strict` should improve the contract, not train the codebase to accumulate suppressions.

```python
from typing import TypedDict
from uuid import UUID


class UserRow(TypedDict):
    id: UUID
    email: str


def to_summary(row: UserRow) -> UserSummary:
    return UserSummary(id=row["id"], email=row["email"])
```

### Keep editor and CLI in sync

```json
{
    "python.analysis.typeCheckingMode": "strict",
    "python.analysis.diagnosticMode": "workspace"
}
```

### Safe cleanup order
- Use Ruff autofix first for mechanical issues.
- Re-run `python -m ruff check .` and `python -m mypy . --strict` after every autofix pass.
- If the fix changes behavior, treat it as implementation work rather than “just lint.”
