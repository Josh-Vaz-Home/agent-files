---
name: performance-playbook
description: "Performance diagnosis playbook. Use for profiling, bottleneck analysis, bundle inspection, load or stress evidence, and performance-regression triage in adopted repositories."
---

# Performance Playbook

## When to use

- Profiling slow API requests, background work, or Python hot paths
- Investigating slow route loads, large bundles, or client-side render cost
- Reproducing latency, throughput, or memory regressions
- Capturing cross-layer evidence before handing the fix to `frontend`, `backend`, or `postgres`
- Preparing artifacts for CI or review notes when performance becomes the primary concern

## CLI references

- `npm install`
- `npm run build`
- `npm install -D rollup-plugin-visualizer`
- `npx playwright test tests/e2e/homepage.spec.ts --trace on`
- `python -m pip install py-spy memray`
- `py-spy record -o reports/pyspy.svg -- python -m uvicorn app.main:app`
- `python -m memray run -o reports/memray.bin -m uvicorn app.main:app`
- `python -m memray flamegraph -o reports/memray.html reports/memray.bin`
- `k6 run perf/smoke.js`
- `psql postgresql://postgres:postgres@localhost:5432/app -c "EXPLAIN (ANALYZE, BUFFERS) SELECT ...;"`

## Default stance

- Stay diagnosis-first and evidence-first.
- Use `rollup-plugin-visualizer` for bundle analysis, `py-spy` for CPU profiling, `memray` for memory profiling, `k6` for load evidence, and Postgres `EXPLAIN (ANALYZE, BUFFERS)` for query hot spots.
- Use Playwright traces or browser inspection for representative user-visible loading evidence, but keep browser-spec authoring in `functional-test`.
- Keep environment notes, workload shape, and artifact paths explicit.
- Hand off product-code remediation to `frontend`, `backend`, or `postgres` once the bottleneck is understood.
- Use `review` when the question is whether the current evidence is good enough for go-no-go or risk acceptance.

## Compact patterns

### Vite bundle analysis with `rollup-plugin-visualizer`

Brief rationale: bundle growth is only actionable when you can tie a chunk or dependency to a real route or loading symptom.

```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { visualizer } from "rollup-plugin-visualizer";

export default defineConfig({
  plugins: [
    react(),
    visualizer({
      filename: "reports/bundle-stats.html",
      gzipSize: true,
      brotliSize: true,
      open: false,
    }),
  ],
});
```

- Ask first before making the plugin a permanent repo dependency.
- Record which route, feature flag, or dependency caused the oversized chunk.
- Hand the fix to `frontend` once the expensive bundle boundary is clear.

### `py-spy` CPU capture for a hot path

Brief rationale: CPU profiles are most useful when the workload and trigger path stay explicit.

```text
py-spy record -o reports/pyspy.svg -- python -m uvicorn app.main:app
```

```md
CPU profile note

- Trigger: `GET /api/orders?account_id=123` under the staging sample dataset
- Artifact: `reports/pyspy.svg`
- Hot path: response serialization and per-item permission checks dominate CPU time
- Suggested next owner/lane: `backend`
```

- Record the request shape, dataset, and whether auth was enabled.
- Do not jump from a hot function name straight to a rewrite without checking the request path and data volume.

### `memray` memory capture when allocations are the suspicion

Brief rationale: latency and memory regressions are different problems; use the right artifact for the right failure mode.

```text
python -m memray run -o reports/memray.bin -m uvicorn app.main:app
python -m memray flamegraph -o reports/memray.html reports/memray.bin
```

- Capture the trigger workload and the output artifact path together.
- Use the flame graph or allocation table to name the allocation-heavy path before opening a backend remediation task.

### `k6` smoke or stress scenario

Brief rationale: throughput claims need concurrency, duration, and target path written down.

```javascript
import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  vus: 10,
  duration: "30s",
};

export default function () {
  const response = http.get(`${__ENV.BASE_URL}/api/health`);
  check(response, {
    "status is 200": (value) => value.status === 200,
  });
  sleep(1);
}
```

- Record concurrency, duration, environment, and key percentiles such as p50, p95, and error rate.
- Ask first before turning ad hoc thresholds into blocking CI gates.
- Hand the fix to `backend`, `frontend`, or `postgres` once the bottleneck layer is clear.

### Query-plan evidence belongs with `postgres`

Brief rationale: a slow request is not automatically an application-code problem.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, status, created_at
FROM orders
WHERE account_id = $1
ORDER BY created_at DESC
LIMIT 50;
```

- Keep SQL, plan output, representative row counts, and access-pattern notes together.
- Use `postgres` when index shape, migration safety, or query rewrites become the primary concern.

### Cross-layer diagnosis note

Brief rationale: the best handoff names which layer is slow instead of dumping mixed measurements into one blob.

```md
Performance diagnosis note

- Frontend evidence: route chunk grew from 310 kB to 870 kB and delayed first usable render
- Browser evidence: Playwright trace shows 1.2 s waiting on `/api/orders`
- Backend evidence: `py-spy` points to response serialization on large nested payloads
- Database evidence: query plan remains stable at 18 ms mean
- Primary bottleneck: backend payload shape and serialization cost
- Suggested next owner/lane: `backend`
```

- Keep the note short, layered, and explicit about what is not the bottleneck.
- Use `review` only when the question becomes release readiness or accepted performance risk.
