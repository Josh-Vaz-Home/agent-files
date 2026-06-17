# Agent Files

A VS Code Copilot customization library for strict, lane-based workflows in adopted React/TypeScript, FastAPI/Python, and PostgreSQL repositories.

## What this repository provides

This repository contains:

- user-facing parent lanes for implementation, testing, linting, browser testing, Postgres work, performance diagnosis, review, and scan
- hidden specialists for narrow work; outside the frontend and backend test or lint sets, only `review` uses a small hidden-specialist set
- file-scoped instructions for maintaining the library
- reusable skills with commands near the top and concrete examples
- workspace settings that keep Python editor analysis in Pylance strict mode

## Repository structure

- `.github/agents/` — user-facing parent lanes and hidden specialists
- `.github/instructions/` — file-scoped authoring rules for this library
- `.github/skills/` — reusable playbooks and concrete pattern examples
- `docs/agent-catalog.md` — lane overview and specialist inventory
- `docs/adoption-guide.md` — setup and rollout guidance for consuming repositories
- `docs/use-this-library-in-another-repo.md` — fastest path for copying this library into an adopted repository and using the parent lanes
- `templates/turnkey/` — copy-ready consuming-repo contract files and the verification script
- `.vscode/` — editor recommendations and strict-analysis settings

## Strict turnkey support profile

This library now has a strict supported editor profile for consuming repositories.

### Required VS Code extensions

- `ms-python.python`
- `ms-python.vscode-pylance`
- `dbaeumer.vscode-eslint`
- `esbenp.prettier-vscode`
- `github.vscode-pull-request-github`
- `github.vscode-github-actions`
- `sonarsource.sonarlint-vscode`
- `ms-azuretools.vscode-containers`
- `ms-azuretools.vscode-docker`
- `ms-ossdata.vscode-pgsql`
- `ms-playwright.playwright`
- `42Crunch.vscode-openapi`
- `humao.rest-client`

### Required global or workspace settings

- `github.copilot.chat.githubMcpServer.enabled = true`
- `github.copilot.chat.githubMcpServer.toolsets = ["default"]`
- `githubPullRequests.experimental.chat = true`
- `python.analysis.typeCheckingMode = strict`
- `python.analysis.diagnosticMode = workspace`

### Official provider choices

- Browser automation and browser CI debug: Playwright for VS Code plus Firefox, with native Firefox DevTools used for live inspection when needed.
- HTTP and OpenAPI work: 42Crunch for contract quality plus REST Client for repo-native request execution.
- GitHub context: Pull Requests and Issues extension plus GitHub Actions extension plus the built-in GitHub MCP server.
- Scan and SonarQube work: SonarLint stays in the `scan` lane, not the lint lanes.
- Postgres and container workflows: PostgreSQL extension plus Container Tools plus Docker.

### CI-debug ownership

- `frontend-test` owns CI failure triage for Vitest and other frontend unit or integration test runs.
- `functional-test` owns CI failure triage for Playwright and browser-level runs, including traces, reports, screenshots, and videos.
- `scan` owns CI failure triage for SonarQube, SARIF, dependency, secrets, and container-scan jobs.
- `performance` owns CI failure triage for load-test, profiler, and performance-budget jobs.

This profile is strict about the editor and extension stack, but it does not pretend every capability is frontmatter-wired today. Browser live-inspection, richer pgsql tooling, and HTTP or OpenAPI interaction still depend on extension UX, explicit files, or CLI workflows in some environments.

## Adoption targets

This library is written to adapt cleanly to:

- Windows local development first
- GitHub Actions CI
- Codespaces and dev containers
- self-hosted runners
- monorepos with `frontend/` and `backend/` or `apps/web/` and `apps/api/`

## Default assumptions

This library assumes:

- **Frontend runtime:** Vite SPA with React 19 + TypeScript
- **Frontend routing/data:** React Router with loaders/actions for route-owned data and mutations
- **Frontend forms:** React Hook Form + Zod in the default examples
- **Frontend browser support:** modern evergreen browsers
- **Frontend Node baseline:** Node.js 22+
- **Backend:** FastAPI + Python 3.12+
- **Database:** PostgreSQL
- **Frontend unit/integration testing:** Vitest
- **Browser testing:** Playwright
- **Frontend package manager:** `npm`
- **Python package manager:** `pip`
- **Typical Python local workflow:** `python -m venv + pip`
- **Python editor analysis:** Pylance in `strict` mode

## Frontend defaults in this library

The frontend lane is intentionally opinionated for greenfield personal and small-business SaaS work. Generic examples assume:

- a Vite SPA with React 19 and the latest stable TypeScript
- route-owned data and mutations handled through React Router loaders/actions
- component-level hooks used for local or isolated state or data needs
- React Hook Form + Zod for forms and validation examples
- backend or BFF-managed session cookies for Authentik or OAuth2 flows, with thin frontend auth hooks or context
- no bearer token persistence in `localStorage` or `sessionStorage`
- headless, accessible primitives preferred when abstraction is needed
- Tailwind CSS plus design tokens or CSS variables as the recommended greenfield styling path
- a single-theme default, with dark-mode readiness added later if the consuming app needs it
- Browser or DevTools MCP tools can support DOM, console, network, storage, and browser-state inspection when the consuming workspace exposes them.
- HTTP or OpenAPI MCP tools can support contract inspection and response-shape debugging without moving backend ownership into the frontend lane.
- manual smoke checks for keyboard navigation, responsive layout, loading, error, empty states, and auth or session flows

## Backend defaults in this library

The backend lane is intentionally opinionated. Generic examples assume:

- an `app/api/services/schemas` layout
- typed Pydantic v2 request and response contracts
- thin route handlers with service logic kept out of the HTTP layer
- async endpoints with sync services unless deeper async is justified by I/O
- centralized mapping from service exceptions to HTTP responses
- OAuth2 used with an Authentik proxy, while backend code still validates the claims it depends on
- explicit role-based authorization and reviewable auth dependencies
- HTTP or API MCP tools can support endpoint smoke checks and response inspection when the consuming workspace exposes them, but typed request and response contracts still own the truth.
- backend tests split cleanly into unit and integration lanes
- disposable Postgres-backed integration examples when real database behavior matters

## Testing-lane defaults

### Frontend test

- `frontend-test` owns Vitest-based unit and integration coverage.
- If GitHub Actions or workflow MCP tools are available in the consuming workspace, use them for failed run, log, and artifact context before assuming local reproduction is sufficient.
- Use `vitest-debug-playbook` when the main need is CLI failure triage rather than test authoring guidance.

### Backend test

- `backend-test` owns pytest-based unit and integration coverage.
- If Docker MCP tools are available in the consuming workspace, use them for disposable Postgres container lifecycle, logs, and state during integration-test debugging.
- Keep pytest commands, fixture scope, and database-setup intent explicit even when structured container tooling helps gather context.

## Adjacent lane defaults

### Functional test

- `functional-test` is the only browser-testing parent.
- It owns Playwright specs, page objects, fixtures or setup helpers, auth bootstrap helpers, storage-state artifacts, snapshot baselines, and failure artifacts.
- Auth guidance is repo-specific: UI login, API-assisted setup, and `storageState` are all valid when justified.
- Seed test data through backend or API helpers first; coordinate with `postgres` only when DB-level setup is the real concern.
- When Browser or DevTools MCP tools are available in the consuming workspace, use them to inspect console, network, DOM, storage, and browser state before increasing retries or timeouts.
- Use `playwright-ci-debug` when the main task is CI trace, report, screenshot, or video triage after artifacts are available.
- Ban `waitForTimeout`-style sleeps, treat retries as diagnostic, and capture traces, screenshots, and videos on failure.
- Treat visual regression and user-visible performance signals as first-class coverage.

### Postgres

- `postgres` is Postgres-first and framework-light.
- Examples are Alembic-oriented, but the lane is not SQLAlchemy-only.
- Default local and test workflow: psycopg or psycopg3 with Docker or containerized Postgres and disposable databases.
- When Postgres or Docker MCP tools are available in the consuming workspace, use them to inspect schema state, query results, plans, logs, and container state, but keep SQL and evidence artifacts explicit.
- Use expand-and-contract for live schema changes.
- Review autogenerate output manually and separate backfills when possible.
- Query tuning requires `EXPLAIN` evidence, access-pattern notes, and scale context.

### Performance

- `performance` owns profiling, bottleneck diagnosis, performance baselines, regression triage, and load or stress evidence.
- Default tools: `rollup-plugin-visualizer`, Playwright traces and browser inspection, `py-spy`, `memray`, `k6`, and Postgres `EXPLAIN` evidence through `postgres`.
- When Browser or DevTools or HTTP or API or Postgres or Docker MCP tools are available in the consuming workspace, use them to inspect traces, timings, plans, or container state, but keep commands, artifact paths, and environment notes explicit.
- Keep performance claims tied to representative workloads, environment notes, and before or after comparison when possible.
- Product-code remediation still belongs to `frontend`, `backend`, or `postgres` once the bottleneck is understood.
- CI failure triage for load-test, profiler, and performance-budget jobs belongs to this lane.

### Review

- `review` is designed for adopted repositories, not for reviewing this customization repository itself.
- It reviews diffs and supporting evidence rather than becoming a scan runner.
- It uses one parent plus four hidden specialists for implementation, architecture, go-no-go, and explicit security review.
- The parent routes to one primary review mode first instead of delivering blended generic review commentary.
- When Git or GitHub or pull-request MCP tools are available in the consuming workspace, use them for structured diff, history, rename, PR, and check context, but keep final findings grounded in exact citations.
- Use `git-review-playbook` when you need deeper CLI-only Git tactics or MCP coverage is incomplete.
- Severity scale: `Blocker`, `High`, `Medium`, `Low`.
- Findings require exact file and line citations plus `Expected`, `Actual`, risk rationale, commands when the finding depends on them, and a suggested next owner or lane.
- Implementation, architecture, and security review use `pass` or `fail`.
- Go-no-go review uses only `go`, `go with conditions`, or `no-go`.
- The reviewer must say so plainly when no real issue is found.

### Scan

- `scan` stays tool-first and report-only by default.
- The required workflow is collect evidence, audit or triage, validate, then report.
- Support self-hosted SonarQube Server, SonarCloud, and GitHub code scanning or SARIF.
- When GitHub or code-scanning MCP tools are available in the consuming workspace, use them to inspect alert state, PR linkage, workflow context, and artifact metadata, but keep commands and artifact paths explicit.
- Use `github-cli-playbook` when `gh`-driven PR, checks, or code-scanning workflows are the clearest fallback.
- Use `gitleaks` as the primary secrets example and `trivy` as the primary container or image example.
- Dismissal, suppression, and baseline workflows require evidence before use.

## Supporting CLI playbooks

- `git-review-playbook` — deeper Git diff, rename, blame, and history tactics for the `review` lane.
- `github-cli-playbook` — `gh`-driven PR, checks, code-scanning, and workflow-log tactics for `scan` first and `review` second.
- `postgres-playbook` — Docker, `psql`, migration, and plan-evidence workflows for the `postgres` lane.
- `performance-playbook` — profiling, bundle-analysis, load-test, and regression-triage workflows for the `performance` lane.
- `playwright-patterns` — Playwright authoring and browser-debugging tactics for the `functional-test` lane.
- `playwright-ci-debug` — CI trace, report, screenshot, and flaky-run triage workflows for the `functional-test` lane.
- `vitest-debug-playbook` — focused rerun, reporter, snapshot, and coverage triage workflows for the `frontend-test` lane.

## Stable frontmatter tool wiring

- `backend-test` and `backend-integration-test-specialist` wire `containerToolsConfig` for stable container-tool configuration context.
- `postgres` wires `containerToolsConfig`; richer pgsql database tools stay in body guidance until this setup exposes them as valid custom-agent frontmatter identifiers.
- `review` and its four hidden review specialists wire `changes`, `activePullRequest`, `openPullRequest`, `pullRequestStatusChecks`, and `issue_fetch`; the parent also wires `doSearch`.
- `frontend-test` wires `activePullRequest`, `openPullRequest`, and `pullRequestStatusChecks` for stable PR and CI-status context.
- `scan` wires `activePullRequest`, `openPullRequest`, `pullRequestStatusChecks`, `issue_fetch`, `doSearch`, `sonarqube_analyzeFile`, `sonarqube_getPotentialSecurityIssues`, and `sonarqube_setUpConnectedMode`.
- `performance` keeps Browser or DevTools, HTTP or API, and Postgres or Docker inspection in body guidance until the editor exposes stable custom-agent tool identifiers for cross-layer performance tooling.
- Browser or DevTools inspection, richer pgsql database tooling, generic HTTP or API or OpenAPI inspection, generic Git-history tooling, and repo-specific workflow or artifact tooling stay in body guidance until the editor exposes stable custom-agent tool identifiers for them.

## Repo-local turnkey contract

For a consuming repository, keep repo-specific setup explicit in files instead of in tribal knowledge:

- Copy-ready versions of these files live under `templates/turnkey/` in this library.
- Start with `templates/turnkey/README.md` when copying the contract into an adopted repo.

- `docs/copilot-turnkey.md` — one concise contract for repo roots, scripts, auth model, workflow names, Sonar binding, Playwright auth bootstrap, performance entrypoints and artifact paths, and review base refs.
- `.env.example` — placeholder variable names only, never secrets.
- `openapi/openapi.yaml` or `docs/openapi.yaml` — stable OpenAPI entrypoint.
- `requests.http` or `api/*.http` — reviewable REST Client request flows.
- `playwright.config.*` and auth setup files — browser base URL, projects, and auth bootstrap truth.
- `scripts/verify-copilot-turnkey.ps1` — one verification entrypoint to check extensions, settings, Docker, browser launch, Sonar binding inputs, and required repo files.

## Coordinator and worker orchestration

- User-facing parent lanes are coordinators. Hidden specialists are workers.
- Internal delegation should stay narrow. Coordinators should pass only:
  - `Goal`
  - `Why this worker`
  - `Exact files or paths`
  - `Constraints`
  - `Evidence required`
  - `Expected output`
  - `Done when`
- Stable repo-local facts belong in `docs/copilot-turnkey.md`, `.env.example`, OpenAPI files, request files, and other contract documents so workers do not need inflated prompts.
- Worker output is not the final user-facing answer. After any worker returns, the parent should summarize directly in chat with:
  - `Stage outcome`
  - `Key decisions`
  - `Important evidence`
  - `Risks or blockers`
  - `Next recommended action`
- This library does not require user-visible handoff buttons or blocking stage transitions as the normal orchestration path.

## Parent agent taxonomy

### Core implementation lanes

- `frontend.agent.md`
- `backend.agent.md`

### Language-specific testing lanes

- `frontend-test.agent.md`
- `backend-test.agent.md`

### Language-specific linting lanes

- `frontend-lint.agent.md`
- `backend-lint.agent.md`

### Adjacent specialist lanes

- `functional-test.agent.md`
- `postgres.agent.md`
- `performance.agent.md`
- `review.agent.md`
- `scan.agent.md`

### Hidden review specialists

- `review-implementation-specialist.agent.md`
- `review-architecture-specialist.agent.md`
- `review-go-no-go-specialist.agent.md`
- `review-security-specialist.agent.md`

## Design rules

- commands go near the top of every agent and skill file
- testing and linting are split by language; there are no shared test or lint parents
- browser journeys, page objects, fixtures, auth setup helpers, and snapshot or baseline artifacts stay in `functional-test.agent.md`
- Postgres schema work, migrations, query review, and backfills stay in `postgres.agent.md`
- deep performance diagnosis, profiling, load-test evidence, and performance-regression triage stay in `performance.agent.md`
- review inspects diffs and evidence; scan is tool-first and report-only
- the review parent routes first; it should not linger in blended “correct, safe, ready” commentary when one mode clearly owns the question
- parent agents should do most work; outside the frontend and backend specialist sets, only `review` carries a small hidden-specialist set
- prefer strong defaults over laundry lists of equal-but-different options
- prefer exact examples and concrete file paths over abstract style prose
- evidence standards matter: exact file and line references, reproduction or validation commands, severity tags, remediation guidance, and risk rationale
- all hidden specialists return the same output contract:
  - `Summary`
  - `Key decisions or verdict`
  - `Evidence`
  - `Files`
  - `Commands`
  - `Risks`
  - `Open questions or assumptions`
  - `Recommended next action`
- parent agents summarize worker results directly in chat instead of exposing raw worker chatter to the user

## Authoring workflow for this library

- Start with one narrow job or lane; do not create general helpers.
- Encode the repo’s preferred default directly instead of hedging across multiple stacks unless the library intentionally supports all of them.
- Keep changes lane-local unless a shared default is changing.
- When a default changes, update the affected agent, instruction, skill, `README.md`, `docs/agent-catalog.md`, and `docs/adoption-guide.md` together.
- Validate frontmatter, section ordering, and stale wording after edits.

## Authoring resources

When improving this library, consult these files first:

- `README.md` for repo-wide defaults and CLI expectations
- `docs/agent-catalog.md` for lane boundaries and specialist inventory
- `docs/adoption-guide.md` for consuming-repo setup guidance
- `.github/copilot-instructions.md` for always-on library authoring rules
- `.github/instructions/**` for file-scoped constraints
- `.github/skills/**` for concrete patterns and examples

## Strict standards

### React and TypeScript

- Node 22+ with Vite SPA examples is the default frontend baseline
- TypeScript strict mode is expected
- zero lint warnings by default
- route-owned data and mutations should prefer React Router loaders/actions when practical
- React Hook Form + Zod are the default form examples
- avoid `any`, `ts-ignore`, and non-null assertions except at justified boundaries
- broken keyboard navigation should block by default
- other accessibility issues are high-priority defects and should usually be fixed
- tests should prefer user-visible behavior over implementation details

### FastAPI and Python

- typed public APIs are required
- concise public API docstrings are preferred when they clarify intent
- Pylance strict mode is enabled in workspace settings
- `mypy --strict` is the command-line type gate
- Ruff is the baseline formatter or linter workflow
- Pydantic v2 models define request and response boundaries
- prefer real fixes over ignore-based cleanup
- no default carve-outs for `Any` or `type: ignore`
- backend auth examples assume direct claim validation, even behind an Authentik proxy
- role or permission boundaries should stay explicit and reviewable
- backend tests should focus on public behavior and request or response contracts
- backend coverage defaults target 85% lines and 80% branches
- undocumented `Any` and `type: ignore` should be treated as defects
- auth and migration changes should be reviewed explicitly

### Functional, Postgres, performance, review, and scan lanes

- Playwright guidance bans sleep-based synchronization and broad timeout increases require approval.
- Postgres guidance requires rollback or safe roll-forward thinking and real plan evidence.
- Performance guidance requires representative workloads, environment notes, and artifact-backed claims.
- Review guidance uses `Blocker`, `High`, `Medium`, and `Low` with exact citations.
- Scan guidance requires evidence before dismissal and does not change CI or policy without approval.

## Key CLI tools by lane

### Frontend implementation

- `npm run dev`
- `npm run build`
- `npm run typecheck`
- `npm run lint`
- `npm run test`

### Frontend testing

- `npm run test`
- `npm run test:watch`
- `npm run test:coverage`
- `npx vitest run src/components/Button.test.tsx`

### Frontend linting

- `npm run lint`
- `npm run lint:fix`
- `npm run format`
- `npm run format:check`
- `npx tsc --noEmit`

### Backend implementation

- `python -m venv .venv`
- `python -m pip install -r requirements.txt`
- `python -m uvicorn app.main:app --reload`
- `python -m pytest`
- `python -m ruff check .`
- `python -m mypy . --strict`

### Backend testing

- `python -m venv .venv`
- `python -m pytest`
- `python -m pytest -m unit`
- `python -m pytest -m integration`
- `python -m pytest --cov=app --cov-branch --cov-report=term-missing`
- `docker logs <test-db-container> --tail 100`

### Backend linting

- `python -m venv .venv`
- `python -m ruff check .`
- `python -m ruff check . --fix`
- `python -m ruff format . --check`
- `python -m ruff format .`
- `python -m mypy . --strict`

### Functional test

- `npm install`
- `npx playwright test`
- `npx playwright test --update-snapshots`
- `npx playwright show-trace test-results/<test-name>/trace.zip`
- `npx playwright show-report playwright-report`

### Postgres

- `docker run --name local-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16`
- `docker logs local-postgres --tail 100`
- `python -m alembic revision --autogenerate -m "describe change"`
- `python -m alembic upgrade head`
- `python -m alembic downgrade -1`
- `psql postgresql://postgres:postgres@localhost:5432/app -c "EXPLAIN (ANALYZE, BUFFERS) SELECT ...;"`

### Performance

- `npm run build`
- `npm install -D rollup-plugin-visualizer`
- `npx playwright test tests/e2e/homepage.spec.ts --trace on`
- `python -m pip install py-spy memray`
- `py-spy record -o reports/pyspy.svg -- python -m uvicorn app.main:app`
- `python -m memray run -o reports/memray.bin -m uvicorn app.main:app`
- `k6 run perf/smoke.js`
- `psql postgresql://postgres:postgres@localhost:5432/app -c "EXPLAIN (ANALYZE, BUFFERS) SELECT ...;"`

### Review

- `git diff --name-only origin/HEAD...HEAD`
- `git diff --stat origin/HEAD...HEAD`
- `git diff --find-renames --stat origin/HEAD...HEAD`
- `git diff --unified=3 origin/HEAD...HEAD -- path/to/file`

### Scan

- `gitleaks dir . --no-banner --redact`
- `trivy fs .`
- `trivy image ghcr.io/org/app:sha`
- `npm audit`
- `python -m pip_audit`
- `python -m bandit -r .`
- `sonar-scanner -Dsonar.projectKey=<project-key>`
- `gh api "repos/{owner}/{repo}/code-scanning/alerts" --paginate`

## Pylance strict mode

This repository includes `.vscode/settings.json` with:

- `python.analysis.typeCheckingMode: strict`
- `python.analysis.diagnosticMode: workspace`

This is an editor-level requirement that complements command-line checks from `mypy`.

## Adoption notes

The commands in this repo are templates for consuming repositories. Teams should update paths, scripts, runner details, and review base refs to match their actual app layout while keeping the same lane boundaries and standards.

For copy-ready repo-local contract files and the turnkey verification script, use `templates/turnkey/**` in this library instead of re-creating those files from scratch.

If a consuming frontend does not use Vite, React Router loaders or actions, React Hook Form + Zod, or Tailwind CSS, adapt the framework and styling details while preserving strict typing, explicit auth decisions, accessible interaction design, user-focused tests, and the split between implementation, linting, unit or integration tests, browser tests, review, and scan.

If a consuming backend does not use Authentik, OAuth2, or disposable Postgres test environments, adapt the provider and fixture details while preserving typed contracts, explicit auth decisions, strict typing, and the clean unit versus integration split.

For detailed lane inventory and rollout guidance, see:

- `docs/agent-catalog.md`
- `docs/adoption-guide.md`
- `docs/use-this-library-in-another-repo.md`
