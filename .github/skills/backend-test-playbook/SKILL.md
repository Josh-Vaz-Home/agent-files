---
name: backend-test-playbook
description: "FastAPI and Python testing playbook. Use for pytest, async test patterns, fixture design, request-flow integration tests, and backend coverage expectations."
---
# Backend Test Playbook

## When to use
- Writing backend unit tests
- Writing backend integration tests
- Improving fixture quality and coverage

## Quick setup
- `python -m venv .venv`
- `python -m pip install -r requirements.txt`

## CLI references
- `python -m pytest`
- `python -m pytest -m unit`
- `python -m pytest -m integration`
- `python -m pytest --cov=app --cov-branch --cov-report=term-missing`
- `docker logs <test-db-container> --tail 100`

## Default stance
- Keep async behavior explicit.
- Test public behavior and request/response contracts rather than private methods.
- Avoid live network or database calls in unit tests.
- Prefer small explicit function-scoped fixtures.
- Prefer disposable Postgres containers when integration coverage needs real database behavior.
- If Docker MCP tools are available in the adopted workspace, use them for disposable test-container lifecycle and diagnostics, but keep pytest commands and fixture behavior explicit.
- Keep browser E2E out of this lane.
- Default shared coverage targets are 85% lines and 80% branches.

## Compact patterns

### Behavior-focused unit test
Brief rationale: unit tests should stay fast, isolated, and aimed at public outcomes.

```python
import pytest


@pytest.fixture
def service(repo: FakeUserRepo) -> UserService:
    return UserService(repo=repo)


def test_create_user_rejects_duplicate_email(service: UserService) -> None:
    with pytest.raises(UserConflictError):
        service.create_user(
            CreateUserRequest(
                email="taken@example.com",
                display_name="Taken User",
            )
        )
```

### Request-flow integration with auth coverage
Brief rationale: integration tests should verify the contract, permission boundary, and auth outcome together.

```python
async def test_admin_can_create_user(async_client: AsyncClient, admin_token: str) -> None:
    response = await async_client.post(
        "/users/",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"email": "new@example.com", "display_name": "New User"},
    )

    assert response.status_code == 201


async def test_member_gets_403_for_admin_route(async_client: AsyncClient, member_token: str) -> None:
    response = await async_client.post(
        "/users/",
        headers={"Authorization": f"Bearer {member_token}"},
        json={"email": "new@example.com", "display_name": "New User"},
    )

    assert response.status_code == 403
```

### Postgres-backed integration defaults
- Add a sibling test for missing or invalid tokens returning `401`.
- Prefer a disposable Postgres container or ephemeral database fixture when transaction behavior, constraints, or extensions matter.
- Keep fixtures explicit and function-scoped unless a broader scope clearly pays for itself.
- If the container fails to start or migrations fail inside it, inspect logs and environment setup before weakening the test.
