---
description: "Use when creating or updating manual review agents or guidance in this repository. Covers adopted-repository review modes, severity standards, evidence requirements, and the split from scan."
applyTo: ".github/agents/review.agent.md, .github/agents/review-*-specialist.agent.md, .github/skills/review-workflows/**, .github/skills/git-review-playbook/**"
---

# Review Lane Guidance

## Scope

- Design this lane for adopted repositories, not for reviewing this customization library itself.
- This lane reviews diffs and supporting evidence.
- The parent routes to one primary mode first: implementation, architecture, go-no-go, or security.
- Scan execution belongs to `scan`; review judges implementation quality, architecture, go-no-go readiness, and explicit security concerns.
- If the consuming environment exposes Git or GitHub or pull-request MCP tools, use them to gather structured context, but keep final findings grounded in exact file and line citations.
- CLI Git commands remain the fallback and should still be cited when shell output is the evidence source.

## Severity standard

- `Blocker` — unsafe or incorrect enough that merge or release should stop.
- `High` — serious defect or risk that should usually block until fixed or explicitly accepted.
- `Medium` — real issue worth fixing soon, but not an automatic stop on its own.
- `Low` — minor but real issue or cleanup with a clear rationale.

## Evidence standard

- Include exact file path and line or range citations.
- State `Expected` versus `Actual`.
- Explain why it matters.
- State the risk.
- State the severity.
- Include a reproduction or validation command when the finding depends on one.
- Suggest the next owner or lane.
- When the review is clean, say `No real issue found.`

## Review-mode cues

- Implementation review asks whether the change matches the stated objective, acceptance criteria, and public behavior.
- Architecture review asks whether boundaries, ownership, coupling, rollout shape, and scaling assumptions still make sense.
- Implementation, architecture, and security review use `pass` or `fail`.
- Go-no-go review asks whether the change is ready to merge or deploy; use only `go`, `go with conditions`, or `no-go`.
- Security review asks whether trust boundaries, auth or authorization logic, tenancy, secrets handling, injection risk, or data exposure remain safe.

## Tone and boundaries

- Be direct, explanatory, and low-fluff.
- Avoid style-only nagging and generic “consider” filler.
- Avoid blended “correct, safe, ready” language when a specific review mode is available.
- Do not silently rewrite code during a review.
- Do not call a security scan result a confirmed vulnerability without context and validation.

## Delegation

- The parent review lane should route first instead of lingering in generic mixed-mode review.
- Use one hidden specialist when a single review mode clearly dominates.
- Only combine specialists when the user explicitly asks for combined review types or the second mode is essential to close a blocker.
- Keep repo-wide boilerplate in the parent and instruction file; specialists should spend their words on specialized heuristics and refusal rules.
- When the parent delegates, pass only a narrow packet:
  - `Goal`
  - `Why this worker`
  - `Exact files or paths`
  - `Constraints`
  - `Evidence required`
  - `Expected output`
  - `Done when`
- Hidden specialists return structured worker results to the parent; they are not the final user-facing voice.
- After a hidden specialist returns, the parent should summarize directly in chat with `Stage outcome`, `Key decisions`, `Important evidence`, `Risks or blockers`, and `Next recommended action`.

## Output contract

- Hidden specialists should return:
  - `Summary`
  - `Key decisions or verdict`
  - `Evidence`
  - `Files`
  - `Commands`
  - `Risks`
  - `Open questions or assumptions`
  - `Recommended next action`
- The parent review lane should then summarize the worker result directly in chat instead of exposing raw worker output.
