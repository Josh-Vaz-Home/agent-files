---
description: "Use when creating or updating FastAPI and Python implementation agents, instructions, or skills in this repository. Covers typed API contracts, Pydantic models, dependency injection, and validation boundaries."
applyTo: ".github/agents/backend.agent.md, .github/agents/backend-endpoint-specialist.agent.md, .github/agents/backend-auth-specialist.agent.md, .github/skills/fastapi-service-patterns/**"
---

# Backend Library Guidance

- Assume FastAPI + Python 3.12+.
- Default generic examples to an `app/api/services/schemas` layout.
- Use `pip` and `python -m ...` examples, not Poetry, uv, pnpm, or yarn.
- Public APIs must be typed and should usually have concise docstrings.
- Prefer async endpoints with sync services unless deeper async is justified by I/O.
- Pydantic models should define request and response boundaries; start with `BaseModel` and `Field` metadata, then reach for `ConfigDict` and settings or env-backed models as needed.
- Auth examples should assume OAuth2 with an Authentik proxy while backend code still validates OAuth2 or JWT claims directly.
- Prefer explicit role-based guards and auth dependencies.
- If HTTP or API MCP tools are available, use them for endpoint smoke checks or response-shape inspection, but keep typed request and response contracts explicit.
- Profiling-first latency or throughput diagnosis belongs to `performance`; keep `backend` focused on the code fix once the bottleneck is clear.
- Prefer service exceptions mapped centrally to HTTP responses.
- Auth and migration work should be called out as sensitive.
- Database-centric schema and migration ownership belongs to `postgres.agent.md`.
