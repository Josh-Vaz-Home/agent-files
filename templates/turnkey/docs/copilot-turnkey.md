# Copilot Turnkey Contract

Complete this file before declaring the repository turnkey-ready for this agent library.

## Repo identity

- Repository: `<replace-me>`
- Default branch: `<replace-me>`
- Frontend root: `<replace-me-or-n/a>`
- Backend root: `<replace-me-or-n/a>`
- Browser-test root: `<replace-me>`
- Migration root: `<replace-me-or-n/a>`

## Commands

| Concern           | Command        | Notes                                                |
| ----------------- | -------------- | ---------------------------------------------------- |
| Frontend install  | `<replace-me>` | Example: `npm install`                               |
| Frontend lint     | `<replace-me>` |                                                      |
| Frontend test     | `<replace-me>` |                                                      |
| Frontend coverage | `<replace-me>` |                                                      |
| Playwright run    | `<replace-me>` |                                                      |
| Backend install   | `<replace-me>` | Example: `python -m pip install -r requirements.txt` |
| Backend lint      | `<replace-me>` |                                                      |
| Backend test      | `<replace-me>` |                                                      |
| Backend coverage  | `<replace-me>` |                                                      |
| Migrations up     | `<replace-me>` |                                                      |
| Migrations down   | `<replace-me>` |                                                      |
| Scan entrypoint   | `<replace-me>` |                                                      |

## URLs and contracts

- Frontend local URL: `<replace-me>`
- API local URL: `<replace-me>`
- OpenAPI file path: `<replace-me>`
- OpenAPI runtime URL: `<replace-me>`
- Health endpoint: `<replace-me>`
- Session or auth-status endpoint: `<replace-me>`

## Auth and session model

- Auth model: `<replace-me-cookie-session|bearer-token|other>`
- Issuer: `<replace-me>`
- Audience: `<replace-me>`
- Roles used in route guards: `<replace-me>`
- Test admin identity source: `<replace-me>`
- Test member identity source: `<replace-me>`
- Frontend session source of truth: `<replace-me>`

## Browser testing

- Playwright base URL: `<replace-me>`
- Playwright browser projects: `<replace-me>`
- Auth bootstrap strategy: `<replace-me-ui-login|api-assisted|storage-state>`
- Seed strategy: `<replace-me-backend-helper|api-helper|db-level>`
- Storage-state path if used: `<replace-me-or-n/a>`
- Screenshot baseline path: `<replace-me>`
- Trace artifact path in CI: `<replace-me>`
- HTML report artifact path in CI: `<replace-me>`

## Postgres and data

- Database profile or connection name: `<replace-me>`
- Docker compose service name: `<replace-me-or-n/a>`
- Primary database name: `<replace-me>`
- Test database name: `<replace-me>`
- Migration tool and path: `<replace-me>`
- Query-plan evidence path if stored in repo: `<replace-me-or-n/a>`

## Scan and Sonar

- Sonar host: `<replace-me>`
- Sonar organization: `<replace-me-or-n/a>`
- Sonar project key: `<replace-me>`
- SARIF artifact path in CI: `<replace-me-or-n/a>`
- Gitleaks artifact path in CI: `<replace-me-or-n/a>`
- Trivy artifact path in CI: `<replace-me-or-n/a>`
- Approved suppression or baseline files: `<replace-me-or-none>`

## CI and artifacts

- Frontend test workflow name: `<replace-me>`
- Browser test workflow name: `<replace-me>`
- Scan workflow name: `<replace-me>`
- Required status checks: `<replace-me>`
- Artifact naming pattern: `<replace-me>`

## Review and release

- Review base ref: `<replace-me>`
- Merge gate summary: `<replace-me>`
- Go-no-go owner: `<replace-me>`
- Rollback or safe roll-forward note location: `<replace-me-or-n/a>`

## Required repo files

- `.env.example`: yes
- `requests.http` or `api/*.http`: yes
- OpenAPI file at stable path: yes
- `playwright.config.*`: yes
- `scripts/verify-copilot-turnkey.ps1`: yes

## Notes

- Keep this file updated when roots, scripts, CI workflow names, auth behavior, or Sonar binding changes.
- Parent agents should cite this file when they need repo-local facts for narrow worker packets instead of copying those values into every delegation prompt.
- Do not store secrets here.
- If a field genuinely does not apply, write `n/a` instead of leaving a placeholder behind.
