# Copilot Instructions for This Agent Library

This repository is a **Copilot customization library**, not an application codebase.

## Repository overview

- This repo exists to define reusable Copilot lanes, not to ship product features.
- The primary goal is to produce **specialists with sharp boundaries**, not general helpers with fashionable prose.
- Each agent or skill should read like an operating manual for a narrow job: what it owns, how it validates work, what it refuses to touch, and what “good” looks like.

## Tech stack defaults used in examples

### Frontend

- Vite SPA
- React 19
- latest stable TypeScript
- Node.js 22+
- React Router loaders/actions for route-owned data and mutations
- React Hook Form + Zod for non-trivial forms
- Vitest, Testing Library, `user-event`, and MSW
- Tailwind CSS plus design tokens/CSS variables as the recommended greenfield styling path

### Backend

- FastAPI
- Python 3.12+
- Pydantic v2
- PostgreSQL
- Ruff + MyPy strict + Pylance strict
- OAuth2/JWT flows via Authentik proxy patterns, with backend claim validation kept explicit

## Repository structure and resources

- `.github/agents/` — user-facing parents and hidden specialists; keep parent lanes separate and hidden specialists single-purpose
- `.github/instructions/` — file-scoped rules for maintaining this library
- `.github/skills/` — reusable playbooks and concrete examples; prefer examples here over bloating parent agents
- `docs/agent-catalog.md` — lane overview, boundaries, and specialist inventory
- `docs/adoption-guide.md` — setup and rollout guidance for consuming repositories
- `docs/use-this-library-in-another-repo.md` — practical copy and usage guide for adopted repositories
- `README.md` — shared defaults, CLI references, and repo-wide standards
- `.vscode/settings.json` — editor-level Python strictness guidance

## What to optimize for

- clear agent boundaries
- commands near the top of every agent file
- examples over long theory
- strict standards by default
- CLI-first workflows
- minimal overlap between lanes
- strong defaults over hedged option lists
- concrete file paths, versions, and tools over generic framework labels
- validation-friendly instructions that reduce guesswork

## Writing style for agents and instructions

- Write like an operating manual, not marketing copy.
- Avoid generic phrases like “helpful assistant,” “follow best practices,” or “consider using X/Y/Z” when this library already has a preferred default.
- Pick one default stack or workflow when the repo has a house view; put alternatives in `Ask first`, not in the main path.
- Prefer one real example or snippet over several abstract bullets when a lane has recurring code shapes.
- Name exact folders, commands, and verification steps so an agent does not have to infer them.

## Repository-wide rules

- Use separate user-facing parents for frontend, frontend-test, frontend-lint, backend, backend-test, and backend-lint.
- Do not reintroduce shared `test` or `lint` parent agents.
- Keep Playwright work in `functional-test.agent.md`.
- Keep SonarQube, dependency audit, and deeper security scanning in `scan.agent.md`.
- Keep PostgreSQL schema/query work in `postgres.agent.md`.
- Prefer `npm` examples for frontend commands and `pip`/`python -m ...` examples for backend commands.
- Pylance strict mode is required for Python editor analysis.

## Change discipline

- Keep changes narrow and lane-local unless a repo-wide default is changing.
- When a default changes, update the relevant agent, instruction, skill, `README.md`, `docs/agent-catalog.md`, and `docs/adoption-guide.md` together.
- Do not let one lane quietly drift away from the documented defaults.
- Keep frontmatter specific enough to trigger on real user intent, not generic wording.
- Validate changes with targeted searches for stale stack names, old tools, and contradictory defaults.

## Agent authoring rules

Every `.agent.md` should include these sections in roughly this order:

1. Persona
2. Commands
3. Project knowledge
4. File boundaries
5. Good examples
6. Boundaries
7. Delegation rules
8. Output format

Additional expectations:

- `Commands` should contain real executable commands with the flags or subcommands agents actually need.
- `Project knowledge` should spell out stack versions, preferred tools, and house defaults.
- `File boundaries` should name exact write targets and the risky areas that require approval.
- `Good examples` should be concrete; when a lane has recurring patterns, prefer an exact pattern or snippet over vague adjectives.
- `Boundaries` should use `Always`, `Ask first`, and `Never` to constrain action clearly.
- `Delegation rules` should make handoffs explicit and avoid overlap or recursive ambiguity.

## Coordinator and worker protocol

- User-facing parent agents are coordinators; hidden specialists are workers.
- Delegate internally only when one worker clearly owns the next move.
- Keep delegation packets narrow. Pass only:
  - `Goal`
  - `Why this worker`
  - `Exact files or paths`
  - `Constraints`
  - `Evidence required`
  - `Expected output`
  - `Done when`
- Use repo-local contract files and stable docs for environment facts instead of copying broad repository context into every worker prompt.
- After a worker returns, the coordinator must synthesize the result directly in chat for the human user.
- That synthesized chat summary should include:
  - `Stage outcome`
  - `Key decisions`
  - `Important evidence`
  - `Risks or blockers`
  - `Next recommended action`
- Do not rely on user-visible handoff buttons or blocking stage transitions as the normal orchestration path.

## Quality bar

### Frontend

- TypeScript strictness is expected
- zero lint warnings by default
- accessibility is non-negotiable: broken keyboard navigation blocks by default, and other accessibility defects should usually be fixed rather than normalized away
- avoid `any`, `ts-ignore`, and non-null assertions except at justified boundaries
- prefer route-owned data via React Router loaders/actions, thin auth/session hooks, and polished loading/empty/error states over generic component sprawl

### Backend

- typed public APIs are required
- `mypy --strict` is mandatory in the CLI lane
- Pylance strict mode is mandatory in editor guidance
- undocumented `type: ignore` and `Any` are defects in public-facing code
- prefer explicit auth, validation, and exception-mapping boundaries over convenience shortcuts

## Hidden specialist contract

Hidden specialists must be:

- `user-invocable: false`
- `disable-model-invocation: true`
- single-purpose
- non-recursive in v1
- explicit about what primary concern they own

They should return:

- `Summary`
- `Key decisions or verdict`
- `Evidence`
- `Files`
- `Commands`
- `Risks`
- `Open questions or assumptions`
- `Recommended next action`

Hidden specialists must not act as the final user-facing voice. Parent agents should delegate only when one specialist clearly owns the primary concern, avoid shotgun delegation, and summarize worker results back to the human in chat.

## Skills vs instructions

- Use instructions for file-scoped rules when working on this library
- Use skills for reusable playbooks and CLI workflows
- Do not stuff big procedural manuals into a single instruction file
- Prefer putting concrete recurring examples in skills, while keeping instructions focused on durable rules and defaults
