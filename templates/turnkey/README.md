# Turnkey Contract Templates

Copy these files into an adopted repository to stand up the strict turnkey profile documented in this library.

## Copy order

1. Copy `.vscode/extensions.json` and `.vscode/settings.json` from this library root into the adopted repo.
2. Copy `templates/turnkey/docs/copilot-turnkey.md` to `docs/copilot-turnkey.md`.
3. Copy `templates/turnkey/.env.example` to `.env.example`.
4. Copy `templates/turnkey/requests.http` to `requests.http` or split it into `api/*.http` files.
5. Copy `templates/turnkey/openapi/openapi.yaml` to `openapi/openapi.yaml` if the repo does not already publish an OpenAPI file at a stable path.
6. Copy `templates/turnkey/scripts/verify-copilot-turnkey.ps1` to `scripts/verify-copilot-turnkey.ps1`.

## Notes

- Replace every `<replace-me>` token in `docs/copilot-turnkey.md`, `requests.http`, and `openapi/openapi.yaml` before calling the repo turnkey-ready.
- Keep `.env.example` free of real secrets.
- If the adopted repo is not using the `performance` lane yet, replace the optional performance fields in `docs/copilot-turnkey.md` with `n/a` instead of leaving placeholders behind.
- If the adopted repo already has better equivalents, keep the path stable and update `docs/copilot-turnkey.md` so the lane instructions point to the real source of truth.
- Run `scripts/verify-copilot-turnkey.ps1` after wiring the repo-specific values to catch missing files, settings, extensions, and unresolved placeholders.
