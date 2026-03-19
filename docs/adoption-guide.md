# Adoption Guide

## Goal

Copy these customization files into an adopted repository with explicit lane boundaries.

Copy-ready repo-local contract files and the turnkey verification script live under `templates/turnkey/` in this library.

If you want the fastest copy-and-use path, start with `docs/use-this-library-in-another-repo.md` first, then come back to this guide for deeper rollout and environment details.

This library is optimized first for:

- Windows local development
- GitHub Actions CI
- Codespaces and dev containers
- self-hosted runners
- monorepos with frontend and backend roots

## Default rollout targets

### Windows local development

- Keep `npm` and `python -m ...` commands copyable in PowerShell.
- Avoid Bash-only assumptions in agent or skill examples unless the consuming repo already depends on them.
- Make Docker, Playwright browser dependencies, and local Postgres setup explicit.

### GitHub Actions CI

- Map lanes to separate jobs or clearly separated steps.
- Keep Playwright artifacts, scan artifacts, and migration evidence explicit in workflow outputs.
- Keep Playwright HTML reports alongside trace, screenshot, and video artifacts when CI browser triage is part of the workflow.
- Do not merge scan into lint or browser suites into unit or integration jobs just to save one workflow block.

### Codespaces and dev containers

- Preinstall Node, Python, Docker CLI, PostgreSQL client tools, and Playwright system dependencies where those lanes need them.
- Keep the same repo paths and scripts that developers use locally when possible.

### Self-hosted runners

- Document browser dependencies, Docker availability, scanner binaries, network reachability, and secret handling.
- Be explicit about which jobs need access to registries, SonarQube, SonarCloud, or GitHub code scanning APIs.

## Common monorepo mapping

| Concern                   | Common roots to map                                                        |
| ------------------------- | -------------------------------------------------------------------------- |
| Frontend implementation   | `frontend/`, `apps/web/`                                                   |
| Backend implementation    | `backend/`, `apps/api/`                                                    |
| Frontend tests            | `frontend/src/tests/`, `apps/web/src/tests/`                               |
| Browser tests             | `tests/e2e/`, `frontend/tests/e2e/`, `apps/web/tests/e2e/`                 |
| Migrations and SQL        | `backend/alembic/`, `apps/api/alembic/`, `db/`, `sql/`                     |
| Scan config and artifacts | `.github/workflows/`, `sonar-project.properties`, `trivy*.yaml`, `*.sarif` |

Adjust file boundaries and commands to match the consuming repo's actual roots, but keep the lane ownership the same.

## Package manager and runtime assumptions

### Frontend

- This library uses `npm` examples.
- Default runtime assumptions: Node.js 22+, React 19, TypeScript, Vite, and modern evergreen browsers.

If the consuming repo uses another Node package manager, translate the commands but keep the lane boundaries the same.

### Backend

- This library uses `pip` examples.
- Recommended Python command style:
  - `python -m pip install -r requirements.txt`
  - `python -m pytest`
  - `python -m ruff check .`
  - `python -m mypy . --strict`

### Database and browser-testing defaults

- PostgreSQL is the default database lane target.
- Playwright is the only browser-testing default.
- Local Postgres examples assume Docker or containerized setup and disposable databases.

## Strict turnkey environment

- Do not hardcode guessed MCP server names into shared agent files for an adopted repo. Use the actual server or tool identifiers exposed in that workspace.
- Keep the CLI commands in this library as the fallback and as the evidence source when shell output or generated artifacts are what you reviewed.

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

### Required settings

- `github.copilot.chat.githubMcpServer.enabled = true`
- `github.copilot.chat.githubMcpServer.toolsets = ["default"]`
- `githubPullRequests.experimental.chat = true`
- `python.analysis.typeCheckingMode = strict`
- `python.analysis.diagnosticMode = workspace`

### Official provider choices

- Browser automation and browser CI debug: Playwright for VS Code plus Firefox, with native Firefox DevTools for live inspection.
- HTTP and OpenAPI: 42Crunch plus REST Client.
- GitHub context: Pull Requests and Issues extension plus GitHub Actions plus the built-in GitHub MCP server.
- Scan and SonarQube work: SonarLint, owned by the `scan` lane.
- Postgres and container workflows: PostgreSQL plus Container Tools plus Docker.

### Stable frontmatter and extension-assisted context

- This library now hardcodes only the stable, non-repo-specific tool identifiers it can name confidently in frontmatter:
  - `containerToolsConfig` for `backend-test` and the backend integration-test specialist
  - `containerToolsConfig` for `postgres`
  - stable GitHub PR and status tool identifiers for `review`, `frontend-test`, and `scan`
  - stable SonarQube analysis tool identifiers for `scan`
- It intentionally does not hardcode browser-inspection tool identifiers, richer pgsql database tool identifiers, generic HTTP or API or OpenAPI tool identifiers, generic Git-history identifiers, or repo-specific workflow or artifact tools when no stable environment-wide custom-agent tool identifier is available.

### Expected extension-assisted context

- Best first MCP or extension-assisted fits in adopted repos are usually:
  - Browser or DevTools context for `frontend`
  - HTTP or OpenAPI context for `frontend`
  - GitHub Actions or workflow context for `frontend-test`
  - HTTP or API context for `backend`
  - Docker context for `backend-test`
  - Git or GitHub or pull-request context for `review`
  - GitHub or code-scanning context for `scan`
  - Postgres or Docker context for `postgres`
  - Browser or DevTools context for `functional-test`
- If the adopted repo does not expose those MCP tools, the new CLI playbooks in this library are the intended fallback.

### CI-debug ownership

- `frontend-test` owns CI failure triage for Vitest and other frontend unit or integration runs.
- `functional-test` owns CI failure triage for Playwright and browser-level runs.
- `scan` owns CI failure triage for SonarQube, SARIF, dependency, secrets, and container-scan jobs.

## Required editor settings for Python

To keep backend typing strict in VS Code, enable Pylance strict mode:

- `python.analysis.typeCheckingMode = strict`
- `python.analysis.diagnosticMode = workspace`

This repo already includes those settings in `.vscode/settings.json`.

## What to customize first

1. Update command paths and script names.
2. Map each lane's file boundaries to the consuming repo's real roots.
3. Copy `templates/turnkey/docs/copilot-turnkey.md` to `docs/copilot-turnkey.md` and fill it in as the single repo-local contract for auth model, repo roots, workflow names, Sonar binding, review base refs, and test bootstrap decisions.
4. Choose the Playwright auth bootstrap pattern for the adopted repo.
5. Decide how browser tests seed data: backend or API helper first, Postgres only when DB-level setup is the real concern.
6. Point the Postgres lane to the real migration folders, query helpers, connection profile names, and disposable DB workflow.
7. Configure SonarQube, SonarCloud, GitHub code scanning, Gitleaks, or Trivy only in the `scan` lane.
8. Set the review lane's validation references and release criteria to match the consuming repo.

## Suggested frontend structure

For greenfield React apps, the frontend lane works best when these areas stay explicit:

- `src/components/` for reusable UI pieces
- `src/hooks/` for reusable client logic
- `src/routes/` for route modules, layouts, loaders, and actions
- `src/features/` for domain-specific UI and orchestration
- `src/lib/` for API clients, schemas, and utilities
- `src/styles/` for tokens, base styles, and shared design primitives
- `src/tests/` for shared test utilities, MSW helpers, and setup files

## Suggested frontend config baselines

### `tsconfig.json`

- Keep `strict` enabled.
- Prefer `moduleResolution: bundler` for Vite-based apps.
- Treat unsafe null handling and loose optional-property behavior as defects to fix rather than ignore.

### `eslint.config.*` and Prettier

- Use `typescript-eslint`, `eslint-plugin-react-hooks`, and `eslint-plugin-jsx-a11y`.
- Keep zero-warning expectations in CI and in agent guidance.
- Let formatting support readability and consistency without changing application behavior.

### `vitest.config.*` and `setupTests`

- Prefer a single shared `setupTests` entry for Testing Library, DOM matchers, and common mocks.
- Use Vitest as the only default frontend unit or integration runner.
- Keep browser-journey coverage in Playwright rather than overloading Vitest with end-to-end behavior.

### MSW setup

- Keep browser and Node MSW setup files explicit.
- Place handlers close enough to features that route and form flows stay readable.
- Use MSW for realistic API behavior in integration tests rather than ad hoc fetch mocking.

### React Router route modules

- Prefer loaders or actions for route-owned data and mutations.
- Keep components focused on rendering and interaction once route data is loaded.
- Use component-level hooks for local state or isolated async needs that do not belong to the route contract.

### Auth or session wiring

- Prefer backend or BFF session endpoints over frontend token storage.
- Keep auth state in a thin hook or context layer.
- Make route guards simple, role-aware, and easy to review.

## Repo-local contract files

For seamless setup, keep repo-specific values explicit in stable files:

- Copy-ready versions of these files live under `templates/turnkey/` in this library.
- Use `templates/turnkey/README.md` as the copy order and replacement checklist.

- `docs/copilot-turnkey.md` — repo roots, scripts, auth model, workflow names, Sonar host/project binding, review base refs, and Playwright bootstrap decisions.
- `.env.example` — placeholder variable names only, never secrets.
- `openapi/openapi.yaml` or `docs/openapi.yaml` — stable OpenAPI entrypoint.
- `requests.http` or `api/*.http` — reviewable REST Client request flows.
- `playwright.config.*` plus auth setup helpers — browser base URL, projects, and auth bootstrap truth.
- `scripts/verify-copilot-turnkey.ps1` — one verification entrypoint for extensions, settings, Docker, browser launch, Sonar binding inputs, and required repo files.

## Narrow delegation packets

When an adopted repository uses these parent agents as coordinators, keep repo-local facts in stable contract files so worker prompts stay small and relevant.

- Prefer `docs/copilot-turnkey.md` as the single source for repo roots, workflow names, auth assumptions, Sonar binding, review base refs, and bootstrap decisions.
- Keep placeholders and local defaults in `.env.example` rather than in agent bodies.
- Keep HTTP and OpenAPI facts in request files and OpenAPI files so a coordinator can point a worker at the exact path instead of copying the contract inline.
- A good coordinator packet should pass only:
  - `Goal`
  - `Why this worker`
  - `Exact files or paths`
  - `Constraints`
  - `Evidence required`
  - `Expected output`
  - `Done when`
- After the worker returns, the parent should summarize the important result directly in chat for the human user instead of requiring a separate handoff step.

## Lane-specific adoption notes

### Frontend

- Keep route-owned data and mutations in the `frontend` lane.
- If Browser or DevTools MCP tools are available, use them for DOM, console, network, or storage inspection while debugging UI behavior.
- If HTTP or OpenAPI MCP tools are available, use them to inspect response shape and contract context without shifting backend ownership into the frontend lane.

### Frontend test

- Keep Vitest-based unit and integration coverage in the `frontend-test` lane.
- If GitHub Actions or workflow MCP tools are available, use them for failed run, log, and artifact context before assuming local reproduction is enough.
- Keep CI failure triage for Vitest and other frontend unit or integration runs in this lane.
- Use `vitest-debug-playbook` for rerun, reporter, snapshot, and coverage triage workflows.

### Backend

- Keep typed API contracts, dependency injection, and service boundaries in the `backend` lane.
- If HTTP or API MCP tools are available, use them for endpoint smoke checks and auth-sensitive response inspection, but keep typed request and response contracts explicit.

### Backend test

- Keep pytest unit and integration coverage in the `backend-test` lane.
- If Docker MCP tools are available, use them for disposable Postgres container lifecycle and diagnostics, but keep fixture scope and request-flow assertions explicit.

### Functional test

- Keep all Playwright specs, page objects, fixtures or setup helpers, auth bootstrap helpers, and snapshot or baseline artifacts in the `functional-test` lane.
- Choose auth setup deliberately: UI login, API-assisted setup, or `storageState` reuse are all valid when matched to the repo's auth model.
- Seed data through backend or API helpers first.
- If Browser or DevTools MCP tools are available, use them for console, network, DOM, or storage inspection before increasing retries or timeouts.
- Use `playwright-ci-debug` when CI trace, report, screenshot, or video triage is the main need after artifact download.
- Keep CI failure triage for Playwright and browser-level runs in this lane.
- Ban `waitForTimeout`-style sleeps, treat retries as diagnostic, and ask first before broad timeout increases.
- Capture trace, screenshot, and video artifacts on failure.
- Treat visual regression and user-visible performance signals as first-class coverage.

### Postgres

- Keep the lane Postgres-first and framework-light.
- Use Alembic-oriented examples when the repo uses Alembic, but do not force SQLAlchemy-specific guidance into every consuming repo.
- Default to psycopg or psycopg3, Docker local Postgres, and disposable test databases.
- If Postgres or Docker MCP tools are available, use them for schema inspection, query execution, plan capture, and container diagnostics, but keep SQL and evidence artifacts explicit.
- Use expand-and-contract for live schema changes.
- Ask first before destructive changes.
- Review autogenerate output manually, separate backfills when possible, and require rollback or safe roll-forward thinking.
- Back performance claims with `EXPLAIN` or `EXPLAIN ANALYZE`, access-pattern context, representative row counts, and before or after comparison when possible.

### Review

- Keep one user-facing `review` parent for adopted repositories.
- Add only the four hidden review specialists: implementation, architecture, go-no-go, and security.
- Keep review focused on diffs and supporting evidence.
- Route to one primary review mode first: implementation, architecture, go-no-go, or security.
- If Git or GitHub or pull-request MCP tools are available, use them for structured diff, history, rename, PR, and check context, but keep findings grounded in exact citations.
- Use `git-review-playbook` when the adopted repo needs deeper CLI-only Git review tactics.
- Use `Blocker`, `High`, `Medium`, and `Low`.
- Every real finding should include exact file and line citations, `Expected`, `Actual`, why it matters, risk rationale, a validation command when the finding depends on it, and the suggested next owner or lane.
- Implementation, architecture, and security review should use `pass` or `fail`.
- Go-no-go review should use only `go`, `go with conditions`, or `no-go`.
- Security review should state preconditions, attack path, and impact when it finds a real issue.
- Say plainly when no real issue is found.

### Scan

- Keep scan tool-first and report-only by default.
- Follow the staged workflow: collect evidence, audit or triage, validate, then report.
- Support self-hosted SonarQube Server, SonarCloud, and GitHub code scanning or SARIF.
- If GitHub or code-scanning MCP tools are available, use them for alert state, PR linkage, workflow context, and artifact metadata, but keep commands and artifact paths explicit.
- Keep CI failure triage for SonarQube, SARIF, dependency, secrets, and container-scan jobs in this lane.
- Use `github-cli-playbook` when the adopted repo relies on `gh` for PR, checks, or code-scanning evidence.
- Lead with `gitleaks` for secrets and `trivy` for container or image scanning when free or open-source examples are needed.
- Include false-positive handling, dismissal reasons, repo-specific mitigations, and baseline or suppression workflows, but require evidence before dismissal.
- Leave design judgment, architecture risk, and go-no-go calls to `review`.

## Suggested environment checks

### Windows local development

- Verify `npm install` works from the chosen frontend root.
- Verify `python -m pip install -r requirements.txt` works from the chosen backend root.
- Verify Playwright can launch browsers locally.
- Verify Docker or the local Postgres path works for migration and integration work.

### GitHub Actions CI

- Verify frontend-test jobs expose enough failed-run logs or artifacts for local Vitest triage.
- Verify browser-test jobs upload trace, screenshot, video, and HTML report artifacts.
- Verify scan jobs upload SARIF or other report artifacts when applicable.
- Verify migration checks and rollback-safe checks run in isolated jobs.

### Codespaces and dev containers

- Verify browser dependencies, Docker access, and `psql` are present.
- Verify the same commands used locally also work in the container.

### Self-hosted runners

- Verify the runner can launch browsers, reach registries or scanners, and store tokens securely.
- Verify Docker and any required scanner binaries are available on the runner.
- Verify any GitHub Actions or workflow context used by the testing lanes has the required permissions.

## Recommended baseline tools

### Frontend

- Node.js 22+
- Vite
- React
- TypeScript
- React Router
- React Hook Form
- Zod
- ESLint
- Prettier
- Vitest
- Testing Library
- user-event
- MSW
- Tailwind CSS (recommended for greenfield examples)
- Playwright
- Playwright Test for VS Code
- 42Crunch OpenAPI
- REST Client

### Backend and data

- FastAPI
- Pydantic v2
- pytest
- pytest-asyncio
- pytest-cov
- Ruff
- MyPy
- Pylance strict mode
- Alembic
- psycopg or psycopg3
- PostgreSQL
- Docker
- Container Tools
- Docker extension
- PostgreSQL extension

### Scan and reporting

- Gitleaks
- Trivy
- pip-audit
- Bandit
- SonarQube scanner or SonarCloud-compatible scanner setup
- SonarLint
- GitHub Pull Requests and Issues extension
- GitHub Actions extension

## What not to collapse

Do not merge these lanes if you want the design to stay sharp:

- `frontend-test` with `backend-test`
- `frontend-lint` with `backend-lint`
- `functional-test` with any unit or integration test lane
- `scan` with any lint lane
- `review` with `scan`

## Suggested rollout order

1. Add `copilot-instructions.md`.
2. Add the core frontend and backend parent agents.
3. Add the frontend and backend hidden specialists.
4. Add the language-specific test and lint parents.
5. Add the adjacent lanes: `functional-test`, `postgres`, `review`, and `scan`.
6. Add the four hidden review specialists.
7. Add the matching instructions and skills.
