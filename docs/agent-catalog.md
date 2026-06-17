# Agent Catalog

## User-facing agents

| Agent             | Purpose                                                      | Does                                                                                                                                                    | Does not do                                                                                                          |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `frontend`        | React/TypeScript implementation                              | Components, hooks, route-aware UI behavior, accessibility-aware UI                                                                                      | Backend routes, DB work, browser suites                                                                              |
| `frontend-test`   | React/TypeScript testing                                     | Unit and integration tests for frontend code, including route and mocked-API flows                                                                      | Playwright browser journeys                                                                                          |
| `frontend-lint`   | React/TypeScript linting                                     | ESLint, formatting, type-checking, import hygiene, frontend accessibility lint rules                                                                    | SonarQube, dependency audit                                                                                          |
| `backend`         | FastAPI/Python implementation                                | Routes, Pydantic models, DI, services, auth boundaries                                                                                                  | Frontend rendering, browser tests                                                                                    |
| `backend-test`    | FastAPI/Python testing                                       | Unit and integration tests for backend code                                                                                                             | Browser journeys                                                                                                     |
| `backend-lint`    | FastAPI/Python linting                                       | Ruff, MyPy, formatting, import hygiene, Pylance strict alignment                                                                                        | SonarQube, dependency audit                                                                                          |
| `functional-test` | Playwright browser testing                                   | Specs, page objects, fixtures, auth bootstrap helpers, visual baselines, browser-level performance signals, and browser CI triage                       | Frontend or backend unit/integration tests, product-code implementation                                              |
| `postgres`        | PostgreSQL work                                              | Schemas, migrations, backfills, direct SQL review, indexes, query tuning, and plan evidence                                                             | App-layer business logic, generic framework refactors with no Postgres reason                                        |
| `performance`     | Performance diagnosis                                        | Profiling, bottleneck analysis, bundle inspection, load or stress evidence, performance-regression triage, and performance-job CI triage                | Generic feature implementation, Playwright suite authoring, schema/index ownership, scan policy, or release judgment |
| `review`          | Manual review routing and workflows for adopted repositories | Implementation or objective review, architecture review, go-no-go review, and explicit manual security review                                           | Tool-driven scan execution, silent implementation work, blended generic review                                       |
| `scan`            | Tool-driven scan evidence                                    | SonarQube Server or Cloud, GitHub code scanning or SARIF, dependency audit, secrets scan, container scan, quality-gate evidence, and scan-job CI triage | Design-risk judgment, product-test CI triage, or policy changes without approval                                     |

## Strict turnkey environment

- Required extensions: Python, Pylance, ESLint, Prettier, GitHub Pull Requests and Issues, GitHub Actions, SonarLint, Container Tools, Docker, PostgreSQL, Playwright for VS Code, 42Crunch OpenAPI, and REST Client.
- Required settings: `github.copilot.chat.githubMcpServer.enabled = true`, `github.copilot.chat.githubMcpServer.toolsets = ["default"]`, `githubPullRequests.experimental.chat = true`, and strict Python analysis settings.
- Official browser choice: Playwright plus Firefox, with native Firefox DevTools for live inspection.
- Official HTTP and OpenAPI choice: 42Crunch plus REST Client.
- Official GitHub tooling choice: Pull Requests and Issues extension plus GitHub Actions plus the built-in GitHub MCP server.

## Frontend defaults used in examples

- Vite SPA with React 19, latest TypeScript, and Node.js 22+
- React Router loaders or actions for route-owned data and mutations
- React Hook Form + Zod for form examples
- Vitest, Testing Library, `user-event`, and MSW for unit or integration tests
- Tailwind CSS plus design tokens or CSS variables as the recommended greenfield styling path
- broken keyboard navigation blocks by default; other accessibility issues remain high-priority and should usually be fixed

## Hidden specialists

### Frontend

- `frontend-component-specialist`
- `frontend-a11y-specialist`
- `frontend-unit-test-specialist`
- `frontend-integration-test-specialist`
- `frontend-style-specialist`
- `frontend-type-specialist`

### Backend

- `backend-endpoint-specialist`
- `backend-auth-specialist`
- `backend-unit-test-specialist`
- `backend-integration-test-specialist`
- `backend-style-specialist`
- `backend-type-specialist`

### Review

- `review-implementation-specialist`
- `review-architecture-specialist`
- `review-go-no-go-specialist`
- `review-security-specialist`

## Output contract

Every hidden specialist should return:

1. `Summary`
2. `Key decisions or verdict`
3. `Evidence`
4. `Files`
5. `Commands`
6. `Risks`
7. `Open questions or assumptions`
8. `Recommended next action`

## Coordinator and worker model

- User-facing parent agents are coordinators; hidden specialists are workers.
- Delegate only when one worker clearly owns the next move.
- Keep delegation packets narrow. Pass only:
  - `Goal`
  - `Why this worker`
  - `Exact files or paths`
  - `Constraints`
  - `Evidence required`
  - `Expected output`
  - `Done when`
- Use stable repo-local contract files for environment facts instead of copying broad repository context into every worker prompt.
- Workers return structured results to the parent. They are not the final user-facing voice.
- The parent should summarize the worker result directly in chat with:
  - `Stage outcome`
  - `Key decisions`
  - `Important evidence`
  - `Risks or blockers`
  - `Next recommended action`
- This library does not require user-visible handoff buttons or blocking stage transitions as the normal orchestration path.

## Lane boundaries

- `frontend-test` and `backend-test` are separate parents by design.
- `frontend-lint` and `backend-lint` are separate parents by design.
- `functional-test` is the only Playwright parent and owns snapshot or baseline artifacts plus browser-level performance signals.
- `frontend-test` owns frontend unit or integration test CI failure triage.
- `functional-test` owns Playwright and browser-run CI failure triage.
- `postgres` owns migrations, schema changes, backfills, and query-plan evidence.
- `performance` owns profiling, load or stress evidence, performance-regression triage, and cross-layer bottleneck diagnosis; it hands product-code remediation back to `frontend`, `backend`, or `postgres`.
- `review` inspects diffs and supporting evidence for adopted repositories, and it routes first to implementation, architecture, go-no-go, or security review.
- `scan` is tool-first and report-only by default.
- `scan` gathers findings; `review` judges implementation quality, architecture, go-no-go readiness, and explicit security risk.
- `scan` owns CI failure triage for scan and quality jobs such as SonarQube, SARIF, dependency, secrets, and container scans.

## Optional structured context

- `backend-test` frontmatter wires `containerToolsConfig` for stable container-tool configuration context.
- `postgres` frontmatter wires `containerToolsConfig`; richer pgsql database tools stay in body guidance until this setup exposes them as valid custom-agent frontmatter identifiers.
- `review`, its hidden specialists, and `frontend-test` frontmatter wire stable GitHub PR and status tool identifiers such as `activePullRequest`, `openPullRequest`, and `pullRequestStatusChecks`; `review` also wires `changes`.
- `scan` frontmatter wires stable GitHub PR-context tool identifiers plus SonarQube tool identifiers such as `sonarqube_analyzeFile`.
- `performance` keeps Browser or DevTools, HTTP or API, and Postgres or Docker inspection in body guidance because this library does not currently have stable custom-agent tool identifiers for cross-layer performance tooling in this setup.
- `frontend`, `functional-test`, and `backend` still describe Browser or DevTools and HTTP or API or OpenAPI inspection in body guidance, and `postgres` keeps richer pgsql database tooling there as well, because this library does not currently have stable custom-agent tool identifiers for those capabilities in this setup.

## Supporting skills

- `frontend` uses `react-patterns` for route, form, hook, and UI-structure guidance.
- `frontend-test` uses `frontend-test-playbook` for test-authoring guidance and `vitest-debug-playbook` for CLI failure triage.
- `backend` uses `fastapi-service-patterns` for route, schema, dependency, and validation guidance.
- `backend-test` uses `backend-test-playbook` for pytest unit or integration patterns and disposable Postgres defaults.
- `review` uses `review-workflows` for baseline manual review guidance and `git-review-playbook` for deeper CLI-only diff and history tactics.
- `scan` uses `scan-cli-workflows` for staged evidence gathering and `github-cli-playbook` for `gh`-driven PR, checks, and code-scanning workflows.
- `postgres` uses `postgres-playbook` for Docker, `psql`, migration, and query-plan workflows.
- `performance` uses `performance-playbook` for profiling, bundle analysis, load or stress evidence, and regression-triage workflows.
- `functional-test` uses `playwright-patterns` for Playwright authoring and `playwright-ci-debug` for CI trace, report, screenshot, and flaky-run triage.

## Delegation heuristics

- Delegate only when one lane clearly owns the primary concern.
- Keep parent agents decisive: they should not bounce work through multiple specialists when one specialist can own the next move.
- Outside the frontend and backend hidden specialist sets, only `review` uses a small hidden-specialist set because its review modes are materially different.
- The `review` parent should route first using objective or completeness, boundary or design, release-readiness, or security cues; avoid blended generic review.
- Combine review specialists only when the user explicitly asks for multiple review modes or a second mode is essential to close a blocker.
- Hidden specialists should return a constrained, evidence-backed result, preserve key decisions, and then hand work back to the caller.
- Parent agents should summarize worker results directly in chat instead of exposing raw worker chatter to the human user.
- Avoid overlapping lane definitions that let multiple agents believe they own the same file or decision.
