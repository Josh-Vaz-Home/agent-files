---
name: github-cli-playbook
description: "GitHub CLI playbook for scan-first and review-support workflows. Use when you need `gh`-driven PR context, checks, code-scanning alerts, workflow logs, or artifact discovery because GitHub MCP context is unavailable or incomplete."
---
# GitHub CLI Playbook

## When to use
- Inspecting pull request context for scan or review support
- Gathering GitHub code-scanning alert evidence with `gh`
- Checking failed workflow runs, checks, or downloadable artifacts
- Falling back when GitHub or code-scanning MCP tools are unavailable or incomplete

## CLI references
- `gh auth status`
- `gh pr view <number> --json number,title,body,headRefName,baseRefName,author,labels,reviewDecision,mergeStateStatus`
- `gh pr checks <number>`
- `gh api "repos/{owner}/{repo}/code-scanning/alerts" --paginate`
- `gh api "repos/{owner}/{repo}/code-scanning/alerts/{alert_number}"`
- `gh run list --limit 20`
- `gh run view <run-id> --log-failed`
- `gh run download <run-id> -D artifacts/<run-id>`

## Default stance
- Confirm GitHub CLI auth and repository context before collecting evidence.
- Use this playbook to gather context, not to mutate repo policy, branch protection, or scan dismissal rules without approval.
- Keep alert numbers, PR numbers, run IDs, artifact paths, and repository coordinates explicit in the report.
- Treat `scan` as the primary owner for tool evidence and `review` as the owner for design, architecture, or release judgment.
- If CLI output is partial because of permissions or pagination limits, say so directly.

## Compact patterns

### Pull request context capture
Brief rationale: scan or review notes stay sharper when the branch, labels, checks, and merge state are explicit instead of inferred.

```text
gh pr view 142 --json number,title,body,headRefName,baseRefName,author,labels,reviewDecision,mergeStateStatus
gh pr checks 142
```

- Record the PR number and repository once at the top of the note.
- Separate branch or merge-state facts from your judgment about readiness.

### GitHub code-scanning alert triage
Brief rationale: alert counts are less useful than the exact alert, location, state, and owning repo context.

```text
gh api "repos/{owner}/{repo}/code-scanning/alerts" --paginate
gh api "repos/{owner}/{repo}/code-scanning/alerts/{alert_number}"
```

```md
Scan evidence
- Tool: GitHub code scanning
- Repository: `owner/repo`
- Alert: `12345`
- State: open
- Location: `backend/app/api/routes/invoices.py`
- Validation: alert still open on the PR head SHA
- Suggested next owner/lane: `backend`
```

- Keep the repo, alert number, and state explicit.
- If the alert points to a stale commit or closed PR head, say so before escalating it.

### Failed workflow or artifact context
Brief rationale: scan and test follow-up needs the failed run and artifact path, not just “CI is red.”

```text
gh run list --limit 20
gh run view 987654321 --log-failed
gh run download 987654321 -D artifacts/987654321
```

- Record which workflow and run ID produced the evidence.
- Keep downloaded artifacts under a reviewable local folder so later notes can cite exact paths.
