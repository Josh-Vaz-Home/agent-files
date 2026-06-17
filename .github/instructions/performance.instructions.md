---
description: "Use when creating or updating performance-diagnosis guidance in this repository. Covers profiling, bottleneck analysis, representative workloads, load-testing evidence, and performance-regression boundaries."
applyTo: ".github/agents/performance.agent.md, .github/skills/performance-playbook/**"
---

# Performance Lane Guidance

## Lane stance

- Keep this lane diagnosis-first and evidence-first.
- It owns profiling, bottleneck analysis, load or stress evidence, and performance-regression triage.
- It does not own generic feature implementation, schema changes, or release judgment.
- Performance claims should explain where time, memory, or throughput is actually going instead of treating “slow” as self-explanatory.

## Default tool choices

- Use `rollup-plugin-visualizer` as the default Vite bundle-analysis example.
- Use Playwright traces and browser inspection for representative user-visible loading evidence.
- Use `py-spy` for Python CPU profiling.
- Use `memray` for Python memory analysis when memory growth or allocation churn is the real concern.
- Use `k6` for load or stress testing.
- Use `EXPLAIN (ANALYZE, BUFFERS)` with `postgres` for query-level evidence.
- Keep vendor APM or observability products out of the default path unless the user or consuming repo already standardized on them.

## Evidence standard

- Require a representative workload or test path.
- Require environment notes such as machine, OS, runner, dataset, concurrency, and whether the run was local, CI, staging, or production-like.
- Prefer before or after comparison when possible.
- Record the exact command, artifact path, and branch or commit context when they matter to the claim.
- Separate raw measurements from your interpretation.
- If evidence is noisy, partial, or not production-representative, say so plainly.

## Cross-lane boundaries

- `functional-test` owns Playwright spec authoring, browser-suite CI triage, and user-visible browser signals as a testing lane.
- `postgres` owns schema, index, query-plan changes, and migration safety.
- `frontend` and `backend` own product-code remediation after diagnosis identifies the primary fix.
- `scan` owns tool-driven quality, dependency, secrets, container, and security scans.
- `review` owns go-no-go, risk acceptance, and architecture judgment.

## CI and regression budgets

- Performance budgets and regression checks are valid outputs for this lane, but they are repo-specific, not universal defaults.
- Ask first before adding mandatory blocking thresholds to CI.
- Keep workflow names, artifact paths, and threshold intent explicit.
- Prefer evidence-producing checks before policy-heavy enforcement.

## Monorepo adoption notes

- Common performance roots include `perf/**`, `k6/**`, `tests/performance/**`, `docs/performance/**`, `apps/web/**`, and `apps/api/**`.
- Keep load scripts and performance notes close to the performance root instead of scattering them across unrelated product folders.
- Keep browser evidence, backend profiler output, and query-plan artifacts reviewable instead of burying them in ephemeral local-only paths.

## Boundaries

- Do not promise benchmark-grade precision from ad hoc local runs.
- Do not turn the performance lane into a generic “make it faster” implementation lane.
- Do not normalize broad tool lists when the lane already has a preferred default tool for the same job.
- Do not merge performance diagnosis into scan or review language just because artifacts came from CI.
