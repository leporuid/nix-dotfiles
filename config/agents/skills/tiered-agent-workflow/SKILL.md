---
name: tiered-agent-workflow
description: Orchestrates a quota-aware three-phase model execution strategy for coding tasks. Uses fast/cheap retrieval (Phase 0 Scout) to gather and compact diffs, traces, and symbol slices, dispatches deep reasoning (Phase 1 Pro 3.1) strictly on curated high-signal context for architecture and patch specs, and transitions to token-efficient execution (Phase 2 Flash) for surgical patching, formatting, Git commits, and verification.
---
# Tiered Agent Workflow

Enforces a quota-aware three-phase execution model that protects Pro 3.1 reasoning budget while keeping mechanical retrieval and patching fast and token-efficient across `~/Developer`.

## When to Use

- Tackling architectural changes across Nix flakes (`~/Developer/nix-dotfiles`, `~/Developer/red-tape`), Hjem/Hjem-Rum modules, and system hosts.
- Evaluating multi-repo patterns (e.g., synthesizing `moni-dz`, `Mic92/adios-flake`, `leporuid/red-tape`, `paperdev-code/dendritic-nix`, and `snugnug/hjem-rum` into local modules).
- Preventing Pro quota burn and context bloat during brute-force repo scanning, mechanical file patching, formatting (`pedantix.toml` / `statix.toml` / `nixfmt`), Git staging, and committing.

## 0. Phase 0: Scout & Context Compaction (Flash Tier / CLI First)

Never burn Pro 3.1 quota on brute-force directory scanning or raw file dumps. Gather and compress context first:

1. **Deterministic & Parallel Retrieval**:
   - Use `rg`, `fd`, `git diff`, `git status -s`, or parallel Flash subagents for multi-repo/multi-file discovery.
   - Read only targeted line ranges (±15 lines), error traces (preserving exit codes), and `AGENTS.md` / `pedantix.toml` / `statix.toml`.
   - Never ingest `flake.lock`, `.DS_Store`, or full unrelated modules into reasoning context.

2. **High-Signal Context Pack**:
   - Distill findings into a compact brief: exact file paths, option signatures, failing trace lines, and verified upstream URLs before escalating to Phase 1.

## 1. Phase 1: Strategic Planning & Deep Synthesis (Pro 3.1 Tier)

Spend Pro 3.1 budget strictly on high-leverage reasoning over the curated Context Pack:

1. **Architecture & Edge-Case Analysis**:
   - Map external patterns to local constraints (`leporuid/red-tape` + `adios-flake` DAG, Determinate Nix, Hjem Manifest v3, macOS `aarch64-darwin` vs. Oracle NixOS `aarch64-linux`).
   - Evaluate cross-platform edge cases (e.g., `useOutOfStoreSymlinks = isDarwin;`, Linux `systemd` vs. Darwin `launchd` guards, zero-empty-file rules, `meta.platforms` filtering).

2. **Exact Patch Specification**:
   - Produce a concrete, file-by-file patch plan (`modules/{common,darwin,nixos,hjem}/`, `lib/`, `contrib/`) with exact option names and expected behavior, then hand off immediately.

## 2. Phase 2: Surgical Execution & Verification (Flash Tier)

Once the patch spec is settled, execute with minimal token overhead:

1. **In-Place File Patching & Style Compliance**:
   - Apply surgical edits without reprinting full files in chat.
   - Pre-format written Nix code to match `pedantix.toml` and `nixfmt` (RFC 166):
     - Sort module arguments with `["self", "inputs", "config", "lib", "pkgs"]` first, domain args alphabetically, and `["<defaulted>", "..."]` last (omitting unused arguments to satisfy `deadnix`/`statix`).
     - Sort `inherit` lists alphabetically and use location-aliased `let ... in` bindings (`inherit (lib.modules) mkIf;`, `inherit (lib.options) mkEnableOption mkOption mkPackageOption;`).

2. **Git Hygiene & Verification**:
   - Stage only modified target files (`git add <files>`) and commit using clean English Conventional Commits (`feat(hjem): ...`, `fix(darwin): ...`, `chore(nix): ...`, `docs(agents): ...`).
   - Run `nix fmt` and `nix flake check --no-write-lock-file` (judging by exit code, never masking `$?`) and deliver a concise Traditional Chinese summary.
