---
name: git-review-playbook
description: "Git CLI playbook for adopted-repository review. Use when you need diff slicing, rename detection, blame context, file history, or CLI-only review evidence because structured MCP context is unavailable or incomplete."
---
# Git Review Playbook

## When to use
- Reviewing a diff with CLI-only tooling
- Isolating renamed or moved files before writing a finding
- Understanding file history or authorship before escalating a concern
- Gathering evidence for implementation, architecture, go-no-go, or security review
- Falling back when Git or GitHub or pull-request MCP context is unavailable or incomplete

## CLI references
- `git diff --name-only origin/HEAD...HEAD`
- `git diff --stat origin/HEAD...HEAD`
- `git diff --find-renames --stat origin/HEAD...HEAD`
- `git diff --unified=3 origin/HEAD...HEAD -- path/to/file`
- `git diff --word-diff origin/HEAD...HEAD -- path/to/file`
- `git log --oneline --decorate origin/HEAD..HEAD`
- `git log --follow -- path/to/file`
- `git blame -L 40,80 -- path/to/file`

## Default stance
- Start wide, then narrow: changed files, diff summary, renamed paths, then file-level context.
- Use CLI output to support review reasoning, not to replace `Expected`, `Actual`, risk, or next-owner analysis.
- Prefer rename-aware or history-aware commands before treating churn as new behavior.
- Keep the review base ref explicit and adapt it to the adopted repo if `origin/HEAD` is not the right comparison point.
- If the diff or history view is noisy or incomplete, say so directly instead of overstating certainty.

## Compact patterns

### Rename-aware diff triage
Brief rationale: review comments get noisy fast when a move or rename looks like a brand-new implementation.

```text
git diff --find-renames --stat origin/HEAD...HEAD
git diff --unified=3 origin/HEAD...HEAD -- backend/app/services/invoice_service.py
```

- Confirm whether the change is a rename plus edits or an actual rewrite.
- Use the file-level diff after the rename-aware summary so comments stay tied to the real behavior change.

### File history before a review finding
Brief rationale: context from earlier commits helps distinguish a regression from an older debt item that the current diff only exposed.

```text
git log --follow -- backend/app/services/invoice_service.py
git blame -L 40,80 -- backend/app/services/invoice_service.py
```

- Use history to understand when a boundary or assumption was introduced.
- Do not turn authorship into blame theater; use it to verify change intent and reviewable ownership.

### CLI-only review evidence note
Brief rationale: a good review finding should stay readable even when the supporting evidence came from multiple Git commands.

```md
Evidence
- High — `backend/app/services/invoice_service.py:52-79`
  - Expected: invoice settlement should stop when the provider callback fails validation.
  - Actual: the diff catches the exception and still marks the invoice as settled.
  - Why it matters: operators and users can receive a false success result.
  - Risk: financial state drifts away from the payment provider.
  - Validation: `git diff --unified=3 origin/HEAD...HEAD -- backend/app/services/invoice_service.py`
  - Next owner/lane: `backend`
```

- Record the exact Git command when shell output is the evidence source.
- Keep the finding anchored to the changed lines, not to generic repository commentary.
