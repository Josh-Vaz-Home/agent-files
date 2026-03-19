---
name: scan-cli-workflows
description: "CLI-first scan playbook. Use for SonarQube Server or Cloud, GitHub code scanning or SARIF, dependency audits, Gitleaks, Trivy, Bandit, and evidence-driven scan reporting."
---
# Scan CLI Workflows

## When to use
- Running tool-based scan workflows
- Triaging existing scan artifacts
- Gathering evidence for secrets, dependencies, containers, or code scanning
- Reporting findings without changing CI or policy

## CLI references
- `gitleaks dir . --no-banner --redact`
- `trivy fs .`
- `trivy image ghcr.io/org/app:sha`
- `npm audit`
- `python -m pip_audit`
- `python -m bandit -r .`
- `sonar-scanner -Dsonar.projectKey=<project-key>`
- `gh api "repos/{owner}/{repo}/code-scanning/alerts" --paginate`

## Required workflow
1. Collect evidence.
	- Record the exact command, tool version, branch or commit context, and artifact path.
2. Audit or triage.
	- Group findings by category such as dependency, secrets, container, code, or platform scan.
	- Separate raw tool severity from your triage note.
3. Validate.
	- Recheck noisy or surprising findings before escalating them.
	- Require evidence before calling something a false positive or accepted risk.
4. Report.
	- Include paths, dependency or image identifiers, commands, impact, and the suggested next owner or lane.

## Default stance
- Scan is tool-first and report-only by default.
- Prefer free or open-source examples when possible.
- If GitHub or code-scanning MCP tools are available in the adopted workspace, use them for structured alert, PR, and workflow context, but keep commands and artifact references explicit in the report.
- Use `gitleaks` as the primary secrets example.
- Use `trivy` as the primary container or image example.
- Support self-hosted SonarQube Server, SonarCloud, and GitHub code scanning or SARIF workflows.
- Review handles design, architecture, security judgment, and go-no-go decisions that go beyond tool output.
- Use `github-cli-playbook` when `gh` workflows are the clearest fallback for PR, checks, or alert inspection.

## Compact patterns

### Secrets scan with Gitleaks
Brief rationale: secrets findings need real evidence before dismissal because false confidence is worse than noise.

```text
gitleaks dir . --no-banner --redact --report-format sarif --report-path reports/gitleaks.sarif
```

- Record whether the secret is live, rotated, test-only, or already revoked.
- If you dismiss the finding, state the reason explicitly and keep the evidence with the report.

### Trivy filesystem or image triage
Brief rationale: container findings are only actionable when you tie them to the real base image, package, or filesystem path.

```text
trivy fs .
trivy image ghcr.io/org/app:sha
```

- Record the package name, installed version, fixed version if available, and the image or path that produced the alert.
- When the same CVE appears in multiple layers, report the owning base image or dependency once instead of inflating the count.

### SonarQube or SonarCloud evidence capture
Brief rationale: project or branch mix-ups make scan output useless.

```text
sonar-scanner -Dsonar.projectKey=<project-key>
```

- Do not guess the project key.
- Record whether the result came from self-hosted SonarQube Server or SonarCloud.
- Keep branch or PR context explicit.

### SARIF triage note
Brief rationale: SARIF is an artifact to inspect, not automatic proof that every finding is real.

```md
- Tool: Trivy 0.60.0
- Artifact: `reports/trivy.sarif`
- Finding: `CVE-2025-12345` in `openssl` from the production base image
- Validation: present in the image built from `Dockerfile` used by the release workflow
- Suggested next owner/lane: `backend`
```

### False-positive or suppression note
Brief rationale: suppressions without evidence rot fast.

```md
- Finding: `reports/gitleaks.sarif` secret hit in `tests/fixtures/sample-token.txt`
- Validation: fixture contains a documented fake token used only in unit tests
- Dismissal reason: test fixture only
- Approval status: repo-approved fixture allowlist already exists
```

- Prefer repo-owned baselines or suppressions only when repeated noise is understood and approved.
- Tie suppression notes to exact files, dependencies, images, or artifacts.
