---
name: gemini-api-dev-bridge
description: Cross-harness development bridge for Google Gemini API SDKs (Python google-genai, TypeScript @google/genai), Interactions/Decisions/Live APIs, gemini-api CLI dev/CI workflows, and gemini-api-docs MCP lookup across ~/Developer. Use when writing Gemini API application code (e.g. in ktoolbox or scripts), automating log/CI checks with gemini-api CLI, or authoring modular SKILL.md files.
---
# Gemini API Development Bridge

Bridges the installed `gemini-api` plugin (`/Users/leporuid/.gemini/config/plugins/gemini-api`) to all agent harnesses (`~/.agents/skills`, `~/.claude/skills`, `~/.gemini/skills`) strictly for **software and Nix development workflows**.

> **Plugin Deferral Rule**: When running inside Gemini / Antigravity with `plugin:gemini-api` active, consult `gemini-api-dev`, `gemini-live-api-dev`, and `gemini-api-cli` directly and use `gemini_search_docs` / `gemini_get_doc` MCP tools as the single source of truth — **never** manually scrape `aistudio.google.com` URLs when MCP tools are present.

## When to Use

- Writing or reviewing Python (`google-genai`) or TypeScript (`@google/genai`) code using Gemini APIs (such as `ktoolbox` integrations or dev utilities).
- Using the `gemini-api` CLI inside shell scripts, `run.fish`, or CI pipelines for structured build/error extraction or offline request validation.
- Structuring new modular skills in `config/llms/skills/` following `plugin:gemini-api`'s progressive-disclosure convention.

## Mandatory SDK & Model Contracts

1. **Current SDKs Only**:
   - Python: `google-genai >= 3.2.0` (`uv add "google-genai>=3.2.0"`).
   - JS/TS: `@google/genai >= 3.2.0` (`npm install @google/genai`).
   - **Never use** deprecated `google-generativeai` (Python) or `@google/generative-ai` (JS/TS).

2. **Current Dev Models (Never Use `gemini-2.5-*`, `gemini-2.0-*`, `gemini-1.5-*`)**:
   - `gemini-4-carbon`: frontier coding, proofs, and security auditing (1M context).
   - `gemini-4-argon`: interactive coding, research, and fast production loops.
   - `gemini-4-hydrogen`: default balanced model for agentic/dev tasks.
   - `gemini-3.5-flash-lite` / `gemini-3.1-flash-lite`: high-throughput / lightweight checks.
   - `gemini-decision-1`: calibrated `noul` (yes/no), `choice`, and `score` classifiers (`v1beta`, `client.decisions.create` / `ai.decisions.create`, 0 output tokens).
   - `gemini-3.8-live` / `gemini-3.8-live-extended-thinking`: bidirectional WebSocket streaming (`behavior: "NON_BLOCKING"`, `interaction_status` tracking).
   - `antigravity-preview-09-2026` / `deep-research-preview-04-2026`: managed sandboxed coding/research agents (`v1beta`, `environment="remote"`).

3. **API Versioning & State**:
   - `Interactions API` (`client.interactions.create`) is GA on `v1`; `store=True` is default (opt out with `store=False`, which disables `previous_interaction_id` and `background=True`).
   - `tools`, `system_instruction`, and `generation_config` are **interaction-scoped** — re-specify them every turn.
   - Opt into `v1beta` (`http_options={"api_version": "v1beta"}` / `{ apiVersion: "v1beta" }`) for `Decisions API` and `Managed Agents`.

## `gemini-api` CLI for Dev & CI Automation

Use `gemini-api` in shell/CI pipelines rather than raw `curl` or `google-genai` boilerplate for one-off CLI tasks:
- **Auth Guard**: `gemini-api whoami` (note: an exported `GEMINI_API_KEY` env var overrides keychain and `~/.config/gemini-api/config.yaml`).
- **Offline Request Validation**: `--dry-run` (with `-o json` or `--jq`) validates payloads without spending tokens or network calls.
- **Agent / Machine Mode**: `--agent-mode` emits compact TOON on stdout and structured JSON errors on stderr.
- **Structured Log / Error Extraction**:
  ```sh
  cat build.log | gemini-api generate "Extract unique compiler/Nix errors." --stdin --body '{
    "response_format": {
      "type": "text",
      "mime_type": "application/json",
      "schema": {"type": "object", "properties": {"errors": {"type": "array", "items": {"type": "string"}}}, "required": ["errors"]}
    },
    "store": false
  }'
  ```
- **Context Guard**: Never pipe bare `gemini-api --usage` or `--schema` un-filtered into agent context; use `--help` or `gemini-api generate --schema | jq '...'`.

## Skill Authoring Convention (Token Efficiency)

When expanding skills under `config/llms/skills/<name>/`:
- Keep `SKILL.md` concise and high-signal (frontmatter `name` matching directory + sharp trigger `description`).
- Split large reference tables or helper scripts into `<name>/references/*.md` and `<name>/scripts/*` (matching `plugin:gemini-api` layout) rather than bloating `SKILL.md`.
