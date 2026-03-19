---
name: fastapi-service-patterns
description: "FastAPI and Python implementation examples. Use for routes, Pydantic models, dependency injection, typed service boundaries, auth-aware APIs, and validation patterns."
---
# FastAPI Service Patterns

## When to use
- Creating or refactoring FastAPI endpoints
- Designing request and response models
- Clarifying service-layer boundaries

## Quick setup
- `python -m venv .venv`
- `python -m pip install -r requirements.txt`
- `python -m uvicorn app.main:app --reload`
- `python -m pytest`

## Default stance
- Assume Python 3.12+ and an `app/api/services/schemas` layout.
- Keep route handlers thin.
- Keep service logic sync unless deeper async is justified by I/O.
- Use typed Pydantic v2 models for request and response contracts.
- Keep auth and validation boundaries explicit.
- If HTTP or API MCP tools are available in the adopted workspace, use them for endpoint smoke checks and response inspection, but keep typed contracts and explicit validation boundaries in the code.
- For Authentik or OAuth2 deployments, backend code still validates the claims it depends on.
- Prefer centralized exception mapping instead of scattering service-to-HTTP translation across handlers.

## Compact patterns

### Protected route with role guard
Brief rationale: keep authorization explicit at the dependency boundary and keep business logic in the service.

```python
from uuid import UUID

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, ConfigDict, EmailStr, Field

router = APIRouter(prefix="/users", tags=["users"])


class CreateUserRequest(BaseModel):
    email: EmailStr
    display_name: str = Field(min_length=1, max_length=100)


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    email: EmailStr
    display_name: str
    role: str


@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    payload: CreateUserRequest,
    subject: AuthSubject = Depends(require_role("admin")),
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    user = service.create_user(payload, actor_id=subject.user_id)
    return UserResponse.model_validate(user)
```

### Centralized service-exception mapping
Brief rationale: services raise domain errors once; FastAPI handlers translate them at the edge.

```python
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse


class UserConflictError(ServiceError):
    pass


def install_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(UserConflictError)
    async def handle_user_conflict(
        request: Request,
        exc: UserConflictError,
    ) -> JSONResponse:
        return JSONResponse(status_code=409, content={"detail": str(exc)})
```

### Settings-backed auth config
Brief rationale: keep issuer, audience, and proxy-aware auth settings typed and env-driven.

```python
from pydantic import AnyHttpUrl
from pydantic_settings import BaseSettings, SettingsConfigDict


class AuthSettings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="AUTH_")

    issuer: AnyHttpUrl
    audience: str
```
