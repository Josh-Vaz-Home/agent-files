---
description: "Use when creating or updating React and TypeScript linting or type-checking agents, instructions, or skills in this repository. Covers ESLint, Prettier, accessibility linting, and strict compiler expectations."
applyTo: ".github/agents/frontend-lint.agent.md, .github/agents/frontend-style-specialist.agent.md, .github/agents/frontend-type-specialist.agent.md, .github/skills/frontend-lint-playbook/**"
---
# Frontend Linting Guidance

- Assume a Vite SPA with React 19, the latest stable TypeScript, and Node.js 22+.
- Use `npm` command examples.
- This lane owns ESLint + Prettier + `tsc --noEmit`.
- Require zero lint warnings by default.
- Keep `tsc --noEmit` in the command section near the top.
- Treat accessibility lint rules as high-priority defects, with keyboard-navigation regressions treated as especially serious.
- Treat `any`, `ts-ignore`, and non-null assertions as boundary-only escapes.
- Keep SonarQube and dependency auditing out of this lane.
