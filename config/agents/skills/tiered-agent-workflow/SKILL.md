---
name: tiered-agent-workflow
description: Orchestrates a quota-aware three-phase model execution strategy for coding tasks. Uses fast/cheap retrieval (Phase 0 Scout / Flash / gemini-4-hydrogen / gemini-3.5-flash-lite), routes Phase 1 deep reasoning to Gemini 4 Argon/Carbon before 2026-12-01 and automatically reverts to Gemini 3.1 Pro on/after 2026-12-01 (with on-demand Argon/Carbon escalation on high-risk specs or repeated failures), and transitions to Flash (Phase 2) for surgical patching, formatting, Git commits, and verification.
---
# Tiered Agent Workflow

Enforces a quota-aware three-phase execution model that balances reasoning accuracy, latency, and token cost across `~/Developer` (`Phase 0 Flash` -> `Phase 1 Date-Routed Reasoning` -> `Phase 2 Flash`).

## When to Use

- Tackling architectural changes across Nix flakes (`~/Developer/nix-dotfiles`, `~/Developer/red-tape`), Hjem/Hjem-Rum modules, `ktoolbox`, and system hosts.
- Evaluating multi-repo patterns (e.g., synthesizing `moni-dz`, `Mic92/adios-flake`, `leporuid/red-tape`, `paperdev-code/dendritic-nix`, and `snugnug/hjem-rum` into local modules).
- Preventing reasoning quota/cost burn and context bloat during brute-force repo scanning, mechanical file patching, formatting (`pedantix.toml` / `statix.toml` / `nixfmt`), Git staging, and committing.

## 0. Phase 0: Scout & Context Compaction (Flash Tier / CLI First)

Never burn Phase 1 reasoning budget on brute-force directory scanning or raw file dumps. Gather and compress context first:

1. **Deterministic & Parallel Retrieval**:
   - Use `rg`, `fd`, `git diff`, `git status -s`, or lightweight Flash-tier models (`gemini-3.5-flash-lite`, `gemini-4-hydrogen`) for multi-repo/multi-file discovery.
   - Use `gemini_search_docs` / `gemini_get_doc` MCP tools when querying Gemini API specs (never manually scrape docs URLs when MCP is available).
   - For scripted log/error extraction in dev/CI shells, prefer `gemini-api generate --agent-mode --stdin` with `--body` JSON schema constraints over pasting raw megabyte logs into context.
   - Read only targeted line ranges (+/- 15 lines), error traces (`2>&1 | tail -n 40`), and `AGENTS.md` / `pedantix.toml` / `statix.toml`.
   - Never ingest `flake.lock`, `.DS_Store`, `node-compile-cache`, or full unrelated modules into reasoning context.

2. **High-Signal Context Pack**:
   - Distill findings into a compact brief: exact file paths, option signatures, failing trace lines, and verified upstream URLs before escalating to Phase 1.

## 1. Phase 1: Strategic Planning & Deep Synthesis (Date-Routed + Argon/Carbon Escalation)

### Model Routing Policy

1. **Before `2026-12-01` (Promo Window)**:
   - Default Phase 1 to **Gemini 4 Argon** (`gemini-4-argon`) for complex multi-file coding, terminal reasoning, and low-hallucination synthesis; escalate to **Gemini 4 Carbon** (`gemini-4-carbon`) for frontier security auditing, cryptographic boundaries (`nix-secrets`), or deep multi-repo DAG proofs.
   - Use **Gemini 4 Hydrogen** (`gemini-4-hydrogen`) or **Gemini 3.1 Pro** for standard single-module edits where Argon/Carbon latency is unnecessary.

2. **On/After `2026-12-01` (Post-Promo Revert)**:
   - Automatically revert the Phase 1 default back to **Gemini 3.1 Pro** (or **Gemini 4 Hydrogen** when balanced speed is preferred) to avoid Argon's post-promo ~3x per-task cost ($4/$20 per 1M tokens).

3. **Argon/Carbon-Assists-3.1-Pro Escalation (Post-`2026-12-01`)**:
   - Keep **3.1 Pro** as the primary Phase 1 planner (drafting the initial Patch Spec quickly), and invoke **Gemini 4 Argon** / **Gemini 4 Carbon** strictly as an on-demand **Verification / Escalation Advisor** when any of these triggers hit:
     - **High-Risk Cross-Platform or DAG Changes**: Touching `red-tape` + `adios-flake` DAG wiring, Hjem Manifest v3, or critical NixOS host configs (SSH, Tailscale, `disko`, `nix-secrets`) where misconfiguration risks lockout.
     - **Multi-Step Failure Recovery**: `nix flake check`, `darwin-rebuild`, `nixos-rebuild`, or `pytest` fails across 2 consecutive 3.1 Pro + Flash iterations.
     - **Targeted Spec Audit**: Pass only the compact Context Pack + 3.1 Pro's draft Patch Spec to Argon/Carbon for a single-pass sanity check before Phase 2 execution.

### Synthesis Tasks

1. **Architecture & Edge-Case Analysis**:
   - Map external patterns to local constraints (`leporuid/red-tape` + `adios-flake` DAG, Determinate Nix, Hjem Manifest v3, macOS `aarch64-darwin` vs. Oracle NixOS `aarch64-linux`).
   - Evaluate cross-platform edge cases (e.g., `impure.enable = isDarwin;`, Linux `systemd` vs. Darwin `launchd` guards, zero-empty-file rules, `meta.platforms` filtering).

2. **Exact Patch Specification**:
   - Produce a concrete, file-by-file patch plan (`modules/{common,darwin,nixos,hjem}/`, `lib/`, `contrib/`) with exact option names and expected behavior, then hand off immediately.

## 2. Phase 2: Surgical Execution & Verification (Flash Tier)

Once the patch spec is settled, execute with minimal token overhead (never use Argon in Phase 2):

1. **In-Place File Patching & Style Compliance**:
   - Apply surgical edits or one-shot comment-free shell scripts without reprinting full files in chat.
   - Pre-format written Nix code to match `pedantix.toml` and `nixfmt` (RFC 166):
     - Sort module arguments with `["self", "inputs", "config", "lib", "pkgs"]` first and `["<defaulted>", "..."]` last (omitting unused arguments to satisfy `statix`).
     - Sort `inherit` lists alphabetically and use location-aliased `let ... in` bindings (`inherit (lib.modules) mkIf;`, `inherit (lib.options) mkEnableOption mkOption mkPackageOption;`).

2. **Git Hygiene & Verification**:
   - Stage only modified target files (`git add`) and commit using clean English Conventional Commits (`feat(hjem): ...`, `fix(darwin): ...`, `chore(nix): ...`, `docs(agents): ...`).
   - Run `nix fmt` and `nix flake check` (capped with `| tail -n 35`) and deliver a concise Traditional Chinese summary.
