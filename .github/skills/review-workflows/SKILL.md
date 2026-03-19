---
name: review-workflows
description: "Manual review playbook for adopted repositories. Use for implementation review, architecture review, go-no-go decisions, and explicit security review with evidence-backed findings."
---

# Review Workflows

## When to use

- Reviewing a PR or diff manually
- Checking requirement completeness or correctness
- Reviewing design and architecture decisions
- Making a go-no-go recommendation
- Performing an explicit manual security review

## CLI references

- `git diff --name-only origin/HEAD...HEAD`
- `git diff --stat origin/HEAD...HEAD`
- `git diff --unified=3 origin/HEAD...HEAD -- path/to/file`
- `npm run lint && npm run test`
- `python -m ruff check . && python -m pytest`

## Default stance

- Pick one primary review mode before commenting.
- Review the diff and the proof attached to it.
- If Git or GitHub or pull-request MCP tools are available in the adopted workspace, use them for structured diff or PR context, but keep the final review grounded in exact citations and explicit reasoning.
- Severity scale: `Blocker`, `High`, `Medium`, `Low`.
- Every real finding needs `Location`, `Expected`, `Actual`, `Why it matters`, `Risk`, `Validation or reproduction`, and `Next owner or lane`.
- If the request is a generic PR review, default to implementation review unless boundary, release, or security concerns clearly dominate.
- When the review is clean, say `No real issue found.`
- Scan gathers tool findings; review judges implementation fit, architecture, merge or deploy readiness, and explicit security risk.
- Use `git-review-playbook` when the review needs deeper CLI-only diff, rename, blame, or history tactics.
- If the parent review agent delegates to a hidden specialist, keep the packet narrow and summarize the returned decision directly in chat rather than exposing raw worker chatter.

## Coordinator and worker pattern

### Delegation packet

- Pass only:
  - `Goal`
  - `Why this worker`
  - `Exact files or paths`
  - `Constraints`
  - `Evidence required`
  - `Expected output`
  - `Done when`

### Worker result

- Hidden review specialists should return:
  - `Summary`
  - `Key decisions or verdict`
  - `Evidence`
  - `Files`
  - `Commands`
  - `Risks`
  - `Open questions or assumptions`
  - `Recommended next action`

### Parent chat synthesis

- After the worker returns, the parent should summarize directly in chat with:
  - `Stage outcome`
  - `Key decisions`
  - `Important evidence`
  - `Risks or blockers`
  - `Next recommended action`

## Review modes and dispatch cues

- Implementation review — use when the question is whether the change matches the stated objective, acceptance criteria, or public behavior; verdict is `pass` or `fail`.
- Architecture review — use when the question is whether boundaries, ownership, coupling, rollout shape, or scaling assumptions still make sense; verdict is `pass` or `fail`.
- Go-no-go review — use when the question is whether the change is ready to merge or deploy; use only `go`, `go with conditions`, or `no-go`.
- Security review — use when the question is whether trust boundaries, auth or authorization logic, injection risk, tenancy, secrets handling, or data exposure remain safe; verdict is `pass` or `fail`.

## Compact patterns

### Implementation finding example

```md
Summary

- Mode: Implementation
- Verdict: fail
- Top risk: High. The happy path works, but the failure path still returns success to the caller.

Evidence

- High — `backend/orders/service.py:118-136`
  - Expected: a payment provider failure stops order completion and returns an error to the caller.
  - Actual: the exception is swallowed and the order is marked complete anyway.
  - Why it matters: callers receive a false success result and downstream accounting can drift.
  - Risk: a failed payment can look complete to users and operators.
  - Validation: `python -m pytest tests/orders/test_service.py -q`
  - Next owner/lane: `backend`
```

### Architecture finding example

```md
Summary

- Mode: Architecture
- Verdict: fail
- Top risk: Medium. Permission rules are duplicated across layers.

Evidence

- Medium — `frontend/src/routes/settings.tsx:14-82` and `backend/app/services/session_service.py:41-97`
  - Expected: session and permission policy should have one clear ownership boundary.
  - Actual: the diff duplicates the same role logic in both the frontend route and backend service.
  - Why it matters: role changes can drift and break in uneven ways.
  - Risk: future permission changes will be harder to review and easier to ship incorrectly.
  - Validation: `npm run lint && npm run test`
  - Next owner/lane: `frontend` with `backend`
```

### Go-no-go summary example

```md
Summary

- Mode: Go-no-go
- Verdict: `no-go`
- Top risk: Blocker. The migration adds a non-null column without a backfill or rollout split.

Evidence

- Blocker — `backend/alembic/versions/20260317_add_status.py:22-34`
  - Expected: the rollout keeps existing rows deployable and has a rollback or safe roll-forward path.
  - Actual: the migration introduces a non-null column immediately with no backfill or compatibility window.
  - Why it matters: existing rows can fail on deploy and there is no safe release posture.
  - Risk: deployment failure with no credible recovery path.
  - Validation: `python -m alembic upgrade head && python -m alembic downgrade -1`
  - Next owner/lane: `postgres`
```

### Security review finding example

```md
Summary

- Mode: Security
- Verdict: fail
- Top risk: High. The route enforces authentication but not object ownership.

Evidence

- High — `backend/app/api/routes/invoices.py:48-71`
  - Expected: invoice access should require both authentication and account-ownership or equivalent authorization.
  - Actual: the route checks authentication but never verifies account ownership.
  - Why it matters: an authenticated user can reach another account's invoice by guessing or obtaining its identifier.
  - Risk: insecure direct object reference with confidentiality exposure.
  - Validation: `python -m ruff check . && python -m pytest`
  - Preconditions: the attacker has any valid authenticated session and can supply another invoice identifier.
  - Impact: unauthorized access to invoice data.
  - Next owner/lane: `backend`
```

### No-issue-found example

```md
Summary

- Mode: Implementation
- Verdict: pass
- No real issue found.
```
