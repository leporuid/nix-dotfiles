---
name: developer-workflow
description: Comprehensive developer orchestrator that enforces source-grounding, active context and multimodal inspection, ambient authorization, semantic code-pattern distillation, and auto-synthesizes all ~/Developer dev sub-skills across nix-dotfiles, red-tape, ktoolbox, nix-secrets, Apple/Swift, and Gemini API workflows. Use whenever working on coding, debugging, inspecting repositories, distilling external patterns, reviewing developer tasks, or handling attached code, files, or screenshots in ~/Developer.
allowed-tools: client
---
# Developer Workflow

A unified developer orchestration and pattern-distillation skill that ensures grounded, context-aware, and token-efficient execution across software projects, Nix configurations, and system dotfiles in `~/Developer`.

## Summary

Enforce a strict "grounding-first, multimodal-aware" standard for all development tasks in `~/Developer`. Prioritize attached screenshots and local documentation (`AGENTS.md`, `README.md`, `pedantix.toml`, `statix.toml`), proactively maintain `AGENTS.md` baselines, distill external repository patterns through a semantic accept/adapt/reject matrix, and orchestrate all specialized dev sub-skills (`@fast-repo-reader`, `@nix-dotfiles-workflow`, `@hjem-module-scaffolder`, `@tiered-agent-workflow`, `@nixos-cloud-deploy`, `@get-more-perspectives`).

## When to Use

- Starting any coding, debugging, refactoring, or architectural review task in `~/Developer`.
- User provides screenshots of terminal output, error logs, UI mockups, or attached source files.
- Inspecting, distilling, or porting patterns from external repositories into `nix-dotfiles` or `red-tape`.
- Evaluating trade-offs between architectural options or authoring new Hjem/Darwin/NixOS modules.
- Working on projects lacking clear agent instructions or `AGENTS.md`.

## Core Protocols

### 1. Multimodal & Context-First Invariant

- **Zero-Ignorance Policy**: Extract and interpret all visible text, stack traces, line numbers, and check outputs from attached screenshots or files before formulating a plan.
- **Never Ask for Re-Uploads**: Inspect files in connected folders directly using `client:view_file` when connected.
- **Visual Error Triangulation**: Correlate terminal stack traces (`nix flake check`, `treefmt`, `statix`, compiler errors) directly with local source files.

### 2. Source Grounding & Project Inspection

- **Always Read Ground Truth First**:
  1. Primary: `AGENTS.md` (project conventions, verification commands, invariants), `pedantix.toml`, and `statix.toml`.
  2. Secondary: `README.md`, `DESIGN.md`, and `docs/*.md`.
  3. Tertiary: Root entrypoints (`flake.nix`, `lib/default.nix`, `Cargo.toml`, `Package.swift`, `pyproject.toml`).
- **No Speculative Coding**: Ground every suggested command and module signature in the repository's verified architecture (`leporuid/red-tape` + `adios-flake` + `Determinate Nix` + `Hjem` / `Hjem-Rum`).

### 3. No-Doc Negotiation & Self-Healing

- If a project directory lacks `AGENTS.md` or has drifted after an architectural migration:
  1. Synchronize `AGENTS.md` (and `config/llms/skills/` definitions when applicable) with the verified directory layout, module conventions, and check pipelines.

### 4. Ambient Authorization & Frictionless Execution

- **Continuous In-Session Grant**: Once a task is initiated within connected folders (`~/Developer`), treat routine operations (reading files, surgical edits, Git MCP status/diff/staging/commits) as ambiently approved.
- **Suppress Permission Prompts**:
  - Always use `client:execute_mcp` (`ServerName: "git"`) for Git operations when available, or provide clean shell commands tailored to the active shell (`nu` vs `fish`).
  - Apply in-place edits adhering to `pedantix.toml` and `nixfmt` (RFC 166).

### 5. Unified Dev-Skills Fusion Matrix

| Task Signal | Sub-Skill(s) to Synthesize | Primary Responsibility |
| :--- | :--- | :--- |
| Multi-file / high-risk planning | `@tiered-agent-workflow` | Phase 0 Flash/CLI scout -> Phase 1 Date-routed Pro/Argon/Carbon spec -> Phase 2 Flash patch |
| Inspecting external GitHub / local repos | `@fast-repo-reader` | Non-intrusive tree & pattern extraction without terminal network prompts |
| Any `*.nix`, `hosts/`, `modules/`, `packages/` | `@nix-dotfiles-workflow` | Core guardrails (no `flake.lock` reads, `pedantix.toml`, verification matrix) |
| `packages/`, `overlays/`, `checks/`, CI | `@nix-packaging-and-overlays` | Custom derivations (`fileset.toSource`, `pin.json`, `uv2nix`), Determinate/Darwin overlays, `schemas.nix` |
| `hosts/MacBook-Pro/`, `modules/darwin/`, `vpn-pack` | `@darwin-host-and-unifi-dev` | `determinateNix`, `mkAppSyncScript`, `nix-homebrew`, `launchd`, UniFi ARM64 cross-compile |
| Authoring / refactoring `modules/hjem/*.nix` | `@hjem-module-scaffolder` | `my.programs.<app>` boilerplate, `mkPackageOption`, zero-empty-file & collision guards |
| `config/`, `my-config.nix`, `users/`, `run.fish` | `@dotfiles-and-hjem-config` | Out-of-store symlinks, shell handoffs (`zsh`/`fish`/`nushell`), `check-links` parity |
| NixOS server / VM / Oracle / `nixos-anywhere` | `@nixos-cloud-deploy` | Pre-flight checks, zero-lockout SSH/Tailscale rules, remote builder, OCI & `disko` safety |
| `~/Developer/red-tape` (`adios-flake`, `contrib/`) | `@red-tape-framework-dev` | DAG topology, `lib/internal.nix`, Manifest v3 `hjemSchemas`, offline `nix-unit` tests |
| `~/Developer/ktoolbox` (`uv2nix`, FastAPI, WebUI) | `@ktoolbox-fullstack-dev` | Python + `FastMCP` + OpenAPI codegen + React 19/Vite WebUI + `ruff`/`mypy`/`pytest`/`vitest` |
| `~/Developer/nix-secrets`, `agenix`, `age-plugin-se` | `@nix-secrets-and-enclave` | `agenix-rules.nix`, `age` vs `rage` Secure Enclave invariant, cross-repo secret sync & safety |
| `~/Developer/MyLibrary`, `Xcode`, `m3u8dl-protocol` | `@apple-swift-cocoa-dev` | Swift 6.2 SwiftPM, `swiftly`, `__noChroot` Xcode SDK builds, Cocoa `.app` bundle + `lsregister` |
| Gemini SDK / CLI / MCP coding & dev automation | `@gemini-api-dev-bridge` | `google-genai`/`@google/genai` >= 3.2.0, `gemini-api` `--agent-mode`, `gemini-api-docs` MCP |
| Architectural forks & trade-off evaluations | `@get-more-perspectives` | 5-role advisory panel (Operator, Skeptic, Visionary, Customer Advocate, Performance) |
| General pre-build planning, UI, review, debug, prose, research, URLs, config health | `@think`, `@ui`, `@check`, `@hunt`, `@write`, `@learn`, `@read`, `@health` | Waza workflow skills (see `config/llms/skills/RESOLVER.md`; `nix-dotfiles` guardrails take precedence) |
| macOS disk usage & cleanup (`mo`) | `@mole` | Independent read-only-first macOS cleanup via `mo` CLI |

### 6. Semantic Code-Pattern Distillation Matrix

When distilling external repositories (`moni-dz/nix-config`, `cnsta/cnix`, `sk4rd/mikos-den`, `4evy/ndw`, `SushyDev/nix-plist-manager`, `4evy/dotfiles`, `hjem-rum`) into `nix-dotfiles`, classify every pattern before porting:

- **Adopt / Adapt (High-Signal Idioms)**:
  - **Source Hygiene**: `pkgs.lib.fileset.toSource` for local package derivations (`packages/m3u8dl-protocol`, `packages/has-ancestor`).
  - **Module Style**: `inherit (lib.modules) mkIf mkMerge;` + `inherit (lib.options) mkEnableOption mkPackageOption;` + `integrations.<shell>.enable` toggles (never colliding with `my.config.source` owned files).
  - **Script Factories**: `lib.mapAttrs` + `pkgs.writeShellApplication` + `lib.pipe` for typed `my.scripts.<name>` wrappers.
  - **Safe VM Testing**: `virtualisation.vmVariant` overriding normal user passwords and disabling `age.secrets` for `build-vm` runs (`sk4rd/mikos-den`).
  - **Pure-Data Semantic Themes**: Palette-to-role mapping (`bare`, `channels`, `rgb`) keeping package refs as pure data.
  - **Zero-Lock-In CLI Auditing**: On-demand scanners (`nix run github:sushydev/nix-plist-manager#current -- --against mac.nix`) to feed `modules/darwin/system-defaults.nix` without adding flake inputs.
- **Reject / Do Not Mix (Anti-Patterns for `nix-dotfiles`)**:
  - **Framework Swaps**: Do not replace `red-tape` + `adios-flake` with `den`/`import-tree`, `flake-parts`, or replace `nix-darwin` with `4evy/ndw` (drops `security.pam`, `openssh`, `hjem.darwinModules.default` compatibility).
  - **Home Manager Coupling**: Do not import modules tied to `home-manager` options (e.g., `nix-plist-manager`'s 506 user settings).
  - **Premature Complexity**: Avoid single-letter host codes (`clib.mkWhen`) for `<= 3` hosts or splitting `packages/` into a separate `nixpkgs-f2k` flake while `red-tape` + remote builder suffice.

## Communication & Verification Standards

- **Language Conventions**: Code comments, commit messages, and identifiers must be in clean English. User explanations must be in concise Traditional Chinese (Taiwan usage).
- **Git Hygiene**: Stage only modified target files, verify clean status, and write Conventional Commits (`feat:`, `fix:`, `style:`, `refactor:`, `chore:`, `docs:`).
