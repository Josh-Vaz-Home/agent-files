---
description: "Use when creating or updating scan, SonarQube, dependency-audit, or security-scan guidance in this repository. Supports the scan lane's staged workflow of collect evidence, audit or triage, validate, then report."
applyTo: ".github/agents/scan.agent.md, .github/skills/scan-cli-workflows/**, .github/skills/github-cli-playbook/**"
---

# Scan Lane Guidance

These guidelines support `scan.agent.md` and related scan skills.

## Lane stance

- Keep scan tool-first and report-only by default.
- Do not change CI, policies, quality gates, or repo-wide scan configuration without approval.
- Scan gathers findings; `review` judges architecture, security, and release-risk implications.
- Keep CI failure triage for scan and quality jobs in this lane instead of pushing it into frontend or backend test lanes.

## Required staged workflow

1. Collect evidence.
   - Record the exact command, tool, version, branch or commit context, and artifact path when available.
   - GitHub or code-scanning MCP context is acceptable input when available, but still record the exact artifact path or command when CLI output produced the evidence.
2. Audit or triage.
   - Group findings by category such as dependency, secrets, container, code, or platform scan.
   - Separate raw tool severity from your triage note.
3. Validate.
   - Recheck noisy or surprising findings before escalating them.
   - Require evidence before calling something a false positive or accepted risk.
4. Report.
   - Include paths, dependency or image identifiers, commands, impact, and suggested next owner or lane.

## Preferred tool examples

- Support self-hosted SonarQube Server, SonarCloud, and GitHub code scanning or SARIF workflows.
- Prefer the best free or open-source CLI examples where possible.
- Use `gitleaks` as the primary secrets-scan example.
- Use `trivy` as the primary container or image-scan example.
- Keep dependency examples concrete with `npm audit`, `pip-audit`, and `bandit` where relevant.

## False positives, dismissals, and baselines

- Do not dismiss findings without evidence.
- Record the dismissal reason explicitly, such as test fixture only, unreachable code path, already-rotated secret, vendored file, or repo-accepted risk.
- Prefer repo-owned baselines or suppressions only when repeated noise is understood and approval exists.
- Tie mitigation or suppression notes to exact files, dependencies, images, or generated artifacts.

## SonarQube and GitHub code scanning notes

- If a SonarQube project key is mentioned, look it up instead of guessing.
- Keep branch or PR context explicit when relevant.
- If GitHub or code-scanning MCP tools are available, use them to inspect alert state, PR linkage, and workflow context before falling back to manual API or CLI pagination.
- Explain when a local snippet check is not equivalent to a full server-side scan.
- Call out authentication and permission failures plainly.
- Treat SARIF as an artifact to inspect and report, not as automatic proof that a finding is real.

## Reporting standard

- Include exact file paths or dependency identifiers whenever the tool provides them.
- Include the reproduction command.
- Include the validation note, dismissal reason if any, and the suggested next owner or lane.
- When tool output is noisy, partial, or stale, say so directly.
