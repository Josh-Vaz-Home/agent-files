---
description: "Use when creating or updating React and TypeScript implementation agents, instructions, or skills in this repository. Covers component boundaries, accessibility expectations, and strict TypeScript defaults."
applyTo: ".github/agents/frontend.agent.md, .github/agents/frontend-component-specialist.agent.md, .github/agents/frontend-a11y-specialist.agent.md, .github/skills/react-patterns/**"
---

# Frontend Library Guidance

- Assume a Vite SPA with React 19, the latest stable TypeScript, and Node.js 22+.
- Keep accessibility requirements explicit: broken keyboard navigation blocks by default; semantics, focus handling, labeling, and form announcements remain high-priority defects.
- Use React Router loaders/actions for route-owned data and mutations; component hooks are for local or isolated behavior.
- Use React Hook Form + Zod when forms involve server validation, conditional fields or steps, async side effects, or advanced inputs.
- Use thin auth hooks/context backed by session endpoints. `useAuth()` should expose `user`, `roles`, `isLoading`, `login()`, `logout()`, and `refreshSession()`.
- If Browser or DevTools MCP tools are available, use them for DOM, console, network, or storage inspection during frontend debugging.
- If HTTP or OpenAPI MCP tools are available, use them to inspect response shape and schema context, but keep API ownership with `backend`.
- Use small focused components with explicit contracts; extract on first clear reuse or when logic exceeds roughly 30 lines or becomes hard to scan.
- Use local state before global state for local UI. Compute derived state directly instead of rebuilding it through `useEffect`.
- Put user-triggered side effects in event handlers; reserve `useEffect` for subscriptions, timers, and synchronization with external systems.
- Use headless, accessible primitives when abstraction is needed.
- Keep parent-agent guidance mostly styling-agnostic, but allow skills and adoption docs to recommend Tailwind CSS plus design tokens/CSS variables for greenfield apps.
- Use mobile-first layouts with explicit `sm`, `md`, and `lg` breakpoint changes, explicit loading/empty/error states, and intentional motion that still respects reduced-motion preferences.
- Treat `any`, `ts-ignore`, and non-null assertions as boundary-only escapes.
- Keep commands near the top and use `npm` examples.
