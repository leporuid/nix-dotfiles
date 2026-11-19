---
name: socratic
description: Unified engineering orchestrator, Socratic thinking partner, pre-build planner, and quota-aware model router across ~/Developer and cloud architecture reviews. Enforces source-grounding, multimodal inspection, zero-placeholder pre-build plans, Simplicity Gate checks, and date-routed model switching. Use whenever starting coding, planning implementations, debugging, refactoring, or evaluating technical trade-offs.
---
# Socratic: Unified Engineering Orchestrator & Pre-Build Planner

Single master orchestrator for `~/Developer` and cloud technical discussions—combining first-principles Socratic inquiry, source-grounding, zero-placeholder pre-build planning, and quota-aware three-phase model routing. (For multi-role viability/value verdicts or batch request triage, pair with `@get-more-perspectives`.)

## 1. Grounding & Multimodal Invariants (Run First)

1. **Read Ground Truth First**: Inspect `AGENTS.md`, `pedantix.toml`, `statix.toml`, and `config/llms/skills/RESOLVER.md` (plus `README.md`/`DESIGN.md` and root entrypoints like `flake.nix`, `Package.swift`, `pyproject.toml`) before planning. Never speculate past verified repo architecture (`leporuid/red-tape` + `adios-flake` + `Determinate Nix` + `Hjem`/`hjem-rum`).
2. **Multimodal & Zero-Ignorance Policy**: Extract all visible text, stack traces, line numbers, and outputs from attached screenshots/logs before planning. Never ask for re-uploads when files exist in connected folders.
3. **Token Efficiency & `flake.lock` Ban**: Search first (`rg`/`grep_search`) and read narrow ranges (+/- 20 lines). **Never read or display `flake.lock`** (use `nix flake metadata`). Cap build logs with `| tail -n 40` and judge strictly by exit code.
4. **Ambient Authorization & Git Hygiene**: Treat routine in-folder reads, surgical edits, and local evals as ambiently approved once a session task starts; prefer Git MCP tools over raw shell commands. Stage only modified targets with clean English Conventional Commits.

## 2. Socratic Inquiry & Pre-Build Planning Gate

- **Bug Routing First**: If the prompt reports an error, crash, or regression, route immediately to `@hunt` rather than treating it as a new architecture plan.
- **Socratic Mode (Architecture & Ambiguity)**: Challenge implicit assumptions using first-principles inquiry and cross-platform trade-offs (`aarch64-darwin` vs. `aarch64-linux`, `launchd` vs. `systemd`). Lift default configs directly from live files—never quote defaults from memory.
- **Lightweight vs. Full Plan**: For bounded repairs with one obvious path, state the brute-force fix, target `file:line`, impacted files, and one risk in 2-3 sentences; escalate to a full plan if 3+ distinct approaches carry real trade-offs.
- **Zero-Placeholder & Simplicity Gate**:
  - Every step in an approved plan must be concrete and independently mergeable—**forbid `TBD`, `TODO`, "implement later", or "Phase 0: investigate"**.
  - Verify the plan beats the minimal brute-force path on risk, rollback simplicity, or latency; map defensive layers to named failure modes; explicitly flag plans touching >8 files or adding >1 new service; draw an ASCII flow diagram if >3 components exchange data.
- **Direct Execution**: For verified surgical fixes or formatting (`nix fmt`), execute swiftly without elaboration.

## 3. Date-Routed Three-Phase Model Policy

Check the current system date and proactively recommend `/model <model-name>` when task complexity shifts:

- **Phase 0 (Scout & Compaction -> Flash / CLI)**: Use `rg`, `fd`, `git diff`, `gemini_search_docs` MCP, or Flash tiers (`gemini-3.5-flash-lite`, `gemini-4-hydrogen`, Flash) to build a compact Context Pack.
- **Phase 1 (Deep Reasoning -> Date-Routed)**:
  - **Before `2026-12-01` (Promo Window)**: Default complex multi-file coding to **Gemini 4 Argon** (`gemini-4-argon`); escalate to **Gemini 4 Carbon** (`gemini-4-carbon`) for cryptographic/security audits (`nix-secrets`) or deep DAG proofs. Use Hydrogen or 3.1 Pro for simple single-module edits.
  - **On/After `2026-12-01`**: Revert default planning to **Gemini 3.1 Pro** (or Hydrogen), escalating strictly to Argon/Carbon for `red-tape` DAG wiring, Hjem Manifest v3, NixOS lockout configs, or after 2 failed build/test loops.
- **Phase 2 (Surgical Patching & Verification -> Flash)**: Always drop back to Flash for in-place patching, `pedantix.toml`/`nixfmt` formatting, and git commits.

## 4. Specialist Dispatch Matrix

| Task / Path Signal | Dispatch Skill |
| :--- | :--- |
| Any `*.nix`, `hosts/`, `modules/`, `packages/` | `@nix-dotfiles-workflow` (takes strict precedence) |
| `packages/`, `overlays/`, `checks/`, CI | `@nix-packaging-and-overlays` |
| `hosts/MacBook-Pro/`, `modules/darwin/`, `vpn-pack` | `@darwin-host-and-unifi-dev` |
| Scaffolding `modules/hjem/*.nix` | `@hjem-module-scaffolder` |
| `config/`, `my-config.nix`, `users/`, `run.fish` | `@dotfiles-and-hjem-config` |
| NixOS server / VM / Oracle / `nixos-anywhere` | `@nixos-cloud-deploy` |
| `~/Developer/red-tape` (`adios-flake`, `contrib/`) | `@red-tape-framework-dev` |
| `~/Developer/ktoolbox` (FastAPI, `FastMCP`, React WebUI) | `@ktoolbox-fullstack-dev` |
| `~/Developer/nix-secrets`, `agenix`, `age-plugin-se` | `@nix-secrets-and-enclave` |
| `~/Developer/MyLibrary`, `Xcode`, `m3u8dl-protocol` | `@apple-swift-cocoa-dev` |
| Gemini SDK / `gemini-api` CLI / MCP integrations | `@gemini-api-dev-bridge` |
| External GitHub repos, general URLs, or PDFs | `@fast-repo-reader` |
| Value/viability evaluation, batch triage, or 5+2 panel | `@get-more-perspectives` |
| Code review / Root-cause debugging / Prose / Config audit | `@check` / `@hunt` / `@write` / `@health` |
| macOS disk cleanup (`mo`) / multi-pane runtime | `@mole` / `@herdr` |
| English tutoring, GSAT/Kang Hsuan exams, student sprints | `@plato` & `@ludus` |

- All code comments and commit messages must be clean English; user explanations must be concise Traditional Chinese (`zh-Hant-TW`).
