# Use This Library in Another Repo

## Goal

Move this Copilot customization library into another repository with the smallest amount of guesswork.

The default recommendation is simple:

- copy the whole library shape first
- wire the repo-local contract files
- verify the setup
- then prune lanes only if you are sure you do not need them

That default is safer than trying to assemble one-off agent fragments by hand.

## What to copy

For the easiest adoption path, copy these groups into the target repository.

### Core customization files

- `.github/copilot-instructions.md`
- `.github/agents/**`
- `.github/instructions/**`
- `.github/skills/**`

### Editor profile

- `.vscode/extensions.json`
- `.vscode/settings.json`

### Repo-local contract files

Copy these template files into their live paths in the target repo:

- `templates/turnkey/docs/copilot-turnkey.md` -> `docs/copilot-turnkey.md`
- `templates/turnkey/.env.example` -> `.env.example`
- `templates/turnkey/requests.http` -> `requests.http` or `api/*.http`
- `templates/turnkey/openapi/openapi.yaml` -> `openapi/openapi.yaml` or `docs/openapi.yaml`
- `templates/turnkey/scripts/verify-copilot-turnkey.ps1` -> `scripts/verify-copilot-turnkey.ps1`

## Fastest copy order

1. Copy `.github/copilot-instructions.md`.
2. Copy `.github/agents/`.
3. Copy `.github/instructions/`.
4. Copy `.github/skills/`.
5. Copy `.vscode/extensions.json` and `.vscode/settings.json`.
6. Copy the turnkey files into their live target-repo paths.
7. Fill in `docs/copilot-turnkey.md`.
8. Replace every `<replace-me>` token in the copied contract files.
9. Open the target repo in VS Code.
10. Run `scripts/verify-copilot-turnkey.ps1` from the target repo root.

## What to fill in first

Do not start by editing the agents. Start by filling the repo-local contract.

### `docs/copilot-turnkey.md`

This is the main source of truth for repo-specific facts.

Fill in:

- repo roots
- install, lint, test, coverage, and migration commands
- auth model, issuer, audience, and roles
- Playwright bootstrap decisions
- workflow names and artifact paths
- Sonar host or project binding
- review base ref and release-owner details

### `.env.example`

Keep placeholder variable names only. Do not put secrets here.

### `requests.http` and OpenAPI

Use these to pin stable HTTP and contract entrypoints so agents do not have to guess API paths.

## How to use the agents after copying

Use the user-facing parent lanes only:

- `frontend`
- `frontend-test`
- `frontend-lint`
- `backend`
- `backend-test`
- `backend-lint`
- `functional-test`
- `postgres`
- `review`
- `scan`

Do not invoke hidden specialists directly. They are internal workers.

The intended flow is:

1. you pick the parent lane that matches the job
2. the parent delegates internally when one narrower worker clearly owns the next move
3. the parent summarizes the important result back in chat

You should not need user-visible handoff buttons for normal use.

## Which lane to use

### Product implementation

- Use `frontend` for React or TypeScript UI work.
- Use `backend` for FastAPI or Python API work.
- Use `postgres` when schema, migration, SQL, or query-plan work becomes the primary concern.

### Testing

- Use `frontend-test` for Vitest unit or integration coverage.
- Use `backend-test` for pytest unit or integration coverage.
- Use `functional-test` for Playwright browser journeys, traces, reports, screenshots, or video triage.

### Static analysis and quality

- Use `frontend-lint` for ESLint, Prettier, and strict TypeScript cleanup.
- Use `backend-lint` for Ruff, MyPy strict, and Pylance-strict cleanup.
- Use `scan` for SonarQube, SARIF, dependency audit, secrets, and container scans.

### Human judgment

- Use `review` for implementation review, architecture review, go-no-go, or explicit manual security review.

## Smallest safe subset if you do not want the whole library

The recommended default is still to copy the whole library first.

If you insist on copying only part of it, keep the dependency shape intact:

- a parent agent needs its hidden specialists
- a parent agent needs the instruction files that apply to it
- a parent agent usually needs the skills referenced in its body guidance or in repo docs
- repo-wide behavior still depends on `.github/copilot-instructions.md`

Examples:

### Frontend-only subset

Copy:

- `.github/copilot-instructions.md`
- `frontend.agent.md`
- `frontend-test.agent.md`
- `frontend-lint.agent.md`
- all `frontend-*.agent.md` hidden specialists
- `.github/instructions/frontend*.instructions.md`
- `.github/skills/react-patterns/**`
- `.github/skills/frontend-test-playbook/**`
- `.github/skills/vitest-debug-playbook/**`
- `.github/skills/frontend-lint-playbook/**`

### Backend-only subset

Copy:

- `.github/copilot-instructions.md`
- `backend.agent.md`
- `backend-test.agent.md`
- `backend-lint.agent.md`
- all `backend-*.agent.md` hidden specialists
- `.github/instructions/backend*.instructions.md`
- `.github/skills/fastapi-service-patterns/**`
- `.github/skills/backend-test-playbook/**`
- `.github/skills/backend-lint-playbook/**`

### Review and scan subset

Copy:

- `.github/copilot-instructions.md`
- `review.agent.md`
- `scan.agent.md`
- all `review-*.agent.md` hidden specialists
- `.github/instructions/review.instructions.md`
- `.github/instructions/scan.instructions.md`
- `.github/skills/review-workflows/**`
- `.github/skills/git-review-playbook/**`
- `.github/skills/scan-cli-workflows/**`
- `.github/skills/github-cli-playbook/**`

## How the worker model works

Parent agents are coordinators. Hidden specialists are workers.

When a parent delegates internally, it should pass only:

- `Goal`
- `Why this worker`
- `Exact files or paths`
- `Constraints`
- `Evidence required`
- `Expected output`
- `Done when`

That is why `docs/copilot-turnkey.md`, request files, OpenAPI files, and other repo-local contract files matter: they let the parent point at exact facts instead of stuffing every worker prompt with bloated repository context.

## How to verify the setup

From the target repo root:

- run `scripts/verify-copilot-turnkey.ps1`
- replace every remaining `<replace-me>` token the script reports
- confirm the required VS Code extensions are installed
- confirm the required VS Code settings are present
- confirm the required contract files exist at the expected paths

Then do a quick manual check in VS Code:

- make sure the user-facing parent agents appear
- make sure hidden specialists do not appear in the picker
- open Chat Customizations diagnostics if an agent does not load as expected

## How to keep your adopted repo maintainable

Use this split:

- keep library-wide defaults in the copied agent, instruction, and skill files
- keep repo-specific values in `docs/copilot-turnkey.md`, `.env.example`, request files, OpenAPI files, and test bootstrap files

That split makes future updates easier because you can refresh the shared library files without losing every repo-specific decision.

## How to update later

When this library changes upstream:

1. copy the changed shared files into your adopted repo
2. do not overwrite repo-local contract facts blindly
3. re-run `scripts/verify-copilot-turnkey.ps1`
4. spot-check the parent agents that matter most in your repo

If you made local behavior changes to the shared agent files, record those decisions in your repo before refreshing from upstream so you can re-apply them deliberately instead of by memory.

## Recommended default for most repos

If you want the easiest path, do this:

- copy the whole library shape
- fill `docs/copilot-turnkey.md`
- wire the turnkey files
- verify with the PowerShell script
- use the parent lanes only

That is the lowest-friction way to get the agents working in another repository without playing scavenger hunt with missing specialists, missing skills, or guessed repo facts.
