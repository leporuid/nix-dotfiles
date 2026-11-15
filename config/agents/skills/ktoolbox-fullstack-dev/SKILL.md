---
name: ktoolbox-fullstack-dev
description: Full-stack development, testing, OpenAPI codegen, and uv2nix packaging guide for ~/Developer/ktoolbox (Python FastAPI/Cyclopts/FastMCP backend + React 19/TypeScript/Vite WebUI). Use when editing ktoolbox/, webui/, k_generator/, scripts/, tests/, pyproject.toml, or ktoolbox/flake.nix, or syncing the uv-pawchive fork with nix-dotfiles.
---
# KToolBox Full-Stack Development

Develops, tests, and packages `~/Developer/ktoolbox` (`leporuid/KToolBox`, consumed by `nix-dotfiles/packages/ktoolbox.nix`).

> Never read `flake.lock` or `uv.lock` wholesale; use targeted searches and inspect `pyproject.toml`, `flake.nix`, and `webui/package.json`.

## When to Use

- Modifying Python CLI/API/MCP code under `ktoolbox/` (including `ktoolbox/webui/mcp_server.py`).
- Modifying React/TypeScript frontend under `webui/`, OpenAPI contracts (`webui/openapi.yaml`), or `k_generator/`.
- Updating `pyproject.toml`, `flake.nix` (`uv2nix`), or syncing `uv-pawchive` with upstream before updating `nix-dotfiles`.

## Python Backend & `uv2nix` Flake

1. **Environment (`flake.nix` + `pyproject.toml`)**:
   - Uses `pyproject-nix` + `uv2nix` (`lib.genAttrs`, no `flake-utils`).
   - DevShell sets `UV_NO_SYNC = "1"`, `UV_PYTHON_DOWNLOADS = "never"`, and exposes `editablePythonSet` (`ktoolbox = [ "webui" "urwid" ]`); run `uv` commands with `--no-sync` inside `nix develop`.
   - Core stack: `pydantic` v2, `pydantic-settings`, `cyclopts`, `httpx[socks]`, `tenacity`, `fastapi`, `uvicorn`, `aiosqlite`, `argon2-cffi`, `cryptography`, `fastmcp >= 3.4`.

2. **FastMCP OpenAPI Bridge (`ktoolbox/webui/mcp_server.py`)**:
   - `create_mcp_server` builds tools via `FastMCP.from_openapi` backed by `httpx.ASGITransport(app=app)`.
   - Routes opt into MCP strictly via `x-ktoolbox-mcp` OpenAPI extensions (`enabled == True`, `scope`, `safety`), and `_mcp_schema` strips `securitySchemes` and `x-csrf-token` parameters while `DatabaseTokenVerifier` enforces scoped bearer tokens.

3. **Code Generation Boundaries**:
   - **Never hand-edit generated files** under `ktoolbox/api/generated/` or `webui/src/generated/api.ts`.
   - Regenerate API client types & OpenAPI spec from `webui/`:
     ```sh
     npm run generate:api   # exports openapi.yaml via ../scripts/export_webui_openapi.py + openapi-typescript
     npm run check:api      # verifies generated files have no uncommitted drift
     ```
   - Regenerate WebUI locale config labels after editing `ktoolbox` settings schema: `uv run --no-sync python scripts/generate_config_locale_catalogs.py`.

## WebUI Frontend (`webui/`)

- Stack: Node `>=24`, React 19, TypeScript 5.9 (`tsc -b`), Vite 8, `@heroui/react`, `@tailwindcss/vite`, `@tanstack/react-query`, `react-hook-form` + `zod` v4, `i18next`, `@uiw/react-codemirror`.
- Standard checks inside `webui/`:
  ```sh
  npm run typecheck
  npm run lint
  npm run test        # vitest run
  npm run build       # tsc -b && vite build
  npm run test:e2e    # playwright test (includes @axe-core/playwright)
  ```

## Python Lint, Typecheck & Test Gates

Run inside `~/Developer/ktoolbox`:
```sh
uv run --no-sync ruff check .
uv run --no-sync ruff format --check .
uv run --no-sync mypy ktoolbox tests
uv run --no-sync pytest
```
- `pytest` enforces `-W error` and `--disable-socket --allow-unix-socket` (`respx` for HTTP mocking) plus `>= 85%` branch coverage (`ktoolbox/api/generated/*` omitted).
- `mypy` enforces `strict = true` on `ktoolbox.api` and `ktoolbox.api.*`.

## Upstream Fork & `nix-dotfiles` Sync

- Sync `uv-pawchive` with upstream `master`/`devel` via `git rebase` (never manual file copying) to maintain clean history.
- After pushing `ktoolbox` (`uv2nix` branch), update `nix-dotfiles` with `nix flake update ktoolbox` and re-evaluate `packages/ktoolbox.nix`.
