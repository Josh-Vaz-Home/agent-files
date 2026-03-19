---
name: postgres-playbook
description: "PostgreSQL playbook. Use for migrations, disposable databases, direct SQL review, backfills, and query-plan evidence in adopted repositories."
---
# Postgres Playbook

## When to use
- Designing or reviewing PostgreSQL migrations
- Planning safe schema changes and backfills
- Reviewing raw SQL or query-builder output
- Collecting query-plan evidence
- Setting up disposable local or test databases

## CLI references
- `docker run --name local-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16`
- `docker exec -it local-postgres psql -U postgres -d postgres`
- `docker exec local-postgres psql -U postgres -d postgres -c "\dt"`
- `docker exec local-postgres psql -U postgres -d postgres -c "\d+ public.orders"`
- `docker logs local-postgres --tail 100`
- `docker exec local-postgres createdb -U postgres app_test`
- `docker exec local-postgres dropdb -U postgres --if-exists app_test`
- `python -m alembic revision --autogenerate -m "describe change"`
- `python -m alembic upgrade head`
- `python -m alembic downgrade -1`
- `psql postgresql://postgres:postgres@localhost:5432/app -c "EXPLAIN (ANALYZE, BUFFERS) SELECT ...;"`
- `psql postgresql://postgres:postgres@localhost:5432/app -c "EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT ...;"`

## Default stance
- Stay Postgres-first and framework-light.
- Prefer Alembic-oriented examples, but do not hard-lock the lane to SQLAlchemy.
- Default to psycopg or psycopg3, Docker or containerized local Postgres, and disposable test databases.
- If the adopted workspace exposes Postgres or Docker MCP tools, use them for structured schema inspection, query results, container state, and logs, but keep SQL and evidence artifacts explicit.
- Use expand-and-contract for live schema changes.
- Review autogenerate output manually.
- Separate large backfills when possible.
- Require rollback or safe roll-forward thinking and real plan evidence.

## Compact patterns

### Expand-and-contract migration skeleton
Brief rationale: keep live code compatible while the application and data move in stages.

```python
from alembic import op
import sqlalchemy as sa


def upgrade() -> None:
	op.add_column("invoice", sa.Column("external_id", sa.Text(), nullable=True))
	op.create_index("ix_invoice_external_id", "invoice", ["external_id"], unique=True)


def downgrade() -> None:
	op.drop_index("ix_invoice_external_id", table_name="invoice")
	op.drop_column("invoice", "external_id")
```

- Backfill `external_id` separately.
- Only enforce `NOT NULL` after the application writes the new column and the backfill succeeds.
- Drop replaced columns in a later migration after all callers are switched.

### Direct SQL is acceptable when it is clearer
Brief rationale: reviewed SQL is often easier to trust than hidden ORM behavior.

```sql
ALTER TABLE account
ADD COLUMN billing_region text;

CREATE INDEX CONCURRENTLY ix_account_billing_region
ON account (billing_region);
```

- If the migration framework wraps everything in one transaction, plan around `CREATE INDEX CONCURRENTLY` explicitly instead of hoping it works.

### Query-plan evidence note
Brief rationale: performance claims need workload context, not just a new index name.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, status, created_at
FROM orders
WHERE account_id = $1
ORDER BY created_at DESC
LIMIT 50;
```

```md
Query review note
- Access pattern: account dashboard loads the newest 50 orders on every page view.
- Data scale: ~12M rows total, ~85k rows for the busiest account.
- Before: sequential scan, 420 ms mean on the staging sample.
- After: index scan on `ix_orders_account_id_created_at_desc`, 18 ms mean.
- Evidence artifact: `docs/sql/orders-dashboard-plan.md`
```

### Docker diagnostics and `psql` inspection
Brief rationale: migration or integration failures are easier to reason about when container logs and schema inspection stay explicit.

```text
docker logs local-postgres --tail 100
docker exec local-postgres psql -U postgres -d postgres -c "\dt"
docker exec local-postgres psql -U postgres -d postgres -c "\d+ public.orders"
```

- Use logs first when the container starts but migrations or tests fail unexpectedly.
- Use `\dt` and `\d+` before assuming the migration created the wrong object names or types.

### MCP-assisted schema or query review note
Brief rationale: structured tooling can speed inspection, but the review still needs SQL, plan evidence, and explicit conclusions.

```md
Schema review note
- Inspection source: Postgres or Docker MCP plus `\d+ public.orders`
- Verified objects: `orders`, `ix_orders_account_id_created_at_desc`, `fk_orders_account_id`
- Result: migration created the expected table, index, and foreign-key names
- Evidence artifact: `docs/sql/orders-schema-check.md`
```

- If MCP output and CLI output disagree, call that out plainly and treat the mismatch as a finding to resolve.

### Disposable test database pattern
- Create a fresh database for each local integration run or CI job.
- Apply migrations to the test database instead of reusing a mutable developer database.
- Drop the database after the run so stale state cannot hide migration defects.
