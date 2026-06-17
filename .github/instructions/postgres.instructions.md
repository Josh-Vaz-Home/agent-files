---
description: "Use when creating or updating PostgreSQL agents or guidance in this repository. Covers Postgres-first migrations, query evidence, disposable databases, and framework-light data-layer rules."
applyTo: ".github/agents/postgres.agent.md, .github/skills/postgres-playbook/**"
---

# PostgreSQL Lane Guidance

## Lane stance

- Keep this lane Postgres-first and framework-light.
- Prefer Alembic-oriented examples, but do not hard-lock the lane to SQLAlchemy.
- Use exact Postgres terms, SQL, and evidence instead of generic database prose.

## Commands and environment

- Keep commands near the top of both the agent and related skills.
- Assume Docker or containerized local Postgres, `psql`, and disposable test databases.
- Default client examples to psycopg or psycopg3.
- If the consuming environment exposes Postgres or Docker MCP tools, use them for structured schema inspection, query result capture, and container diagnostics, but keep SQL and evidence artifacts explicit.
- Direct SQL is acceptable when it is clearer or safer than ORM-generated SQL.

## Migration rules

- Use expand-and-contract for live schema changes.
- Ask first before destructive changes, irreversible rewrites, or risky column or table renames.
- Review Alembic autogenerate output manually before accepting it.
- Separate large backfills from schema-shape changes when possible.
- Require rollback or safe roll-forward thinking in the guidance and examples.

## Query-tuning evidence

- Require `EXPLAIN` or `EXPLAIN ANALYZE`.
- Require access-pattern justification.
- Require representative row counts or scale notes.
- Include before or after comparison when possible.
- Include SQL review notes or artifacts when a change is performance-motivated.
- Structured MCP query results do not replace the SQL, plan output, and workload notes that explain why the change is safe.

## Boundaries

- Keep backend route and service behavior in `backend`.
- Cross-layer bottleneck diagnosis can start in `performance`, but query plans, indexes, and schema changes stay in `postgres`.
- Keep manual design or migration-risk judgment in `review`.
- Keep tool-driven scanning and policy work in `scan`.
- Do not treat schema work as a side effect of application implementation.

## Monorepo adoption notes

- Expect common consuming-repo roots such as `backend/alembic/`, `apps/api/`, `db/`, and `sql/`.
- Keep database test helpers and disposable DB setup close to the backend or data layer, not in frontend folders.
