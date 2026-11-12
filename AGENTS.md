# Agent Guide (`nixos-and-darwin-shared-hjem`)

This repository collects project-specific expectations, tool contracts, and architectural guardrails for automated coding agents working across macOS (`nix-darwin`) and Linux (`NixOS`) powered by **`red-tape`**, **`adios-flake`**, **`hjem`**, and **`hjem-impure`**.

---

## 1. Repository Layout

| Directory / File | Description & Purpose |
| :--- | :--- |
| `flake.nix` | Root `red-tape.mkFlake` entrypoint; tracks inputs, system matrix, and flake settings. |
| `devshell.nix` | Developer shell toolchain with treefmt and git-hooks. |
| `hosts/MacBook-Pro/` | Darwin host configuration (`darwin-configuration.nix`) and user profile bridge. |
| `hosts/nixos/` | Self-contained native NixOS configuration for Oracle Cloud / server (`configuration.nix`). |
| `modules/` | Shared multi-platform modules (`host-shared.nix`, etc.). |
| `users/leporuid/` | Shared user profile (`home-configuration.nix`) managing packages and files. |
| `config/` | Raw upstream configurations (`fish/`, `nushell/`, `starship.toml`, `git/`, `nvim/`, etc.). |

---

## 2. Environment & Tooling Contracts

- **Nix Toolchain**: Built with Determinate Nix (`determinateNix` on macOS, `determinate` on NixOS) aligning with the Determinate Nix Reference Manual.
  - **Modern CLI Invariant**: Exclusively use modern Nix 3 CLI commands (`nix profile`, `nix store`, `nix flake`) instead of legacy tools (`nix-env`, `nix-collect-garbage`).
  - **Profile Lifecycle**: Manage profile generations via `nix profile wipe-history [--profile <path>] [--older-than <duration>]`.
  - **Store Management**: Run store garbage collection via `nix store gc --verbose` and hard-link deduplication via `nix store optimise --verbose`.
  - **Build Diagnostics**: Use `nix top` and `nix ps` for active build process inspection and memory monitoring.
- **Home Management via Hjem & Hjem-Impure**:
  - Replaces heavy Home Manager with ultra-lightweight `hjem`.
  - **Clobber Invariant**: Always ensure `hjem.clobberByDefault = true;` to avoid collision with existing home files.
  - **Impure Dev Mode**: Run `hjem-impure` in terminal to replace immutable store symlinks with live links pointing directly back to `config/`.
  - **Darwin Purity**: In Darwin with smfh linker, restore store symlinks via `launchctl start org.hjem.activate` or next rebuild.
- **Verification Matrix & Exit Status Invariant**:
  | Changed Paths | Required Verification Before Commit / Push |
  | :--- | :--- |
  | `*.nix`, `flake.lock`, `hosts/`, `users/`, `modules/` | `nix flake check --all-systems` |
  | Only `config/**` (raw dotfiles) | May skip full rebuild; test with `hjem-impure` |
  | Newly added / deleted files referenced by Nix expressions | Must run `git add` before evaluating (`nix flake check` requires tracked files) |
  - **Never Mask Exit Codes**: Never pipe verification commands directly into `tail` or `head` without preserving pipeline status. Evaluate success strictly by exit code (`$? == 0`).

---

## 3. Core Architecture Guardrails

- **red-tape Convention**:
  - `red-tape.mkFlake` automatically discovers `hosts/`, `users/`, `modules/`, and `devshell.nix`.
  - Module parameters provided by red-tape: `{ system, pkgs, inputs, ... }`. Do not request `{ self, ... }` in host modules.
  - Relative module paths (e.g. `../../modules/nixos/host-shared.nix`) ensure clean evaluation without dependency on unresolved inputs.
- **Hjem-Rum Module Ecosystem**:
  - Program options are located under `rum.programs.<program>` (e.g. `rum.programs.git`, `rum.programs.fish`).
  - Configurations use native `settings` attribute sets rather than legacy Home Manager aliases (e.g. `rum.programs.git.settings.user = { name = "..."; email = "..."; };`).
- **Raw Application Configurations (`config/`)**:
  - Keep application configurations directly under root `config/` (never rewrite them into complex Nix DSL unless required).
  - Linked via Hjem `files` and managed live via `hjem-impure.dotsDir = "${configDir}";`.

---

## 4. Platform Split & Security Model

### macOS (`hosts/MacBook-Pro`)
- Managed by `nix-darwin` + `hjem`.
- **Primary Interactive Shell**: **Fish** (`programs.fish.enable = true;`, `users.users.leporuid.shell = pkgs.fish;`).
- **Home Directory**: Explicitly set `directory = "/Users/leporuid";` under `hjem.users.leporuid`.
- **Determinate Daemon**: `nix.enable = false;` to avoid conflicting with Determinate Nix daemon and launchd services.

### Linux / Server (`hosts/nixos`)
- Managed by `nixos` + `hjem`.
- **Home Directory**: Standard `/home/leporuid`.
- **Headless / Server Shell**: Bash / Nushell interactive handoff.

---

## 5. Agent Workflow & Execution Rules

1. **Token Efficiency & Search-First**:
   - Locate targets using `grep_search` or `find_by_name` first.
   - Read only the specific target range (±20 lines) required; never dump whole directories or entire multi-hundred line files into context.
   - **Absolute Ban on Reading `flake.lock`**: Never read or display `flake.lock`. Use `nix flake metadata` for input revisions.
2. **In-Place Patching & Diffs**:
   - Apply edits directly using `replace_file_content`.
   - Explain changes using concise targeted diffs. Never reprint full files in chat responses.
3. **Strict English Code Comments**:
   - All code comments (`#`, `//`, `/* */`) across all Nix expressions, shell scripts, and configuration files must strictly be written in English.
   - Conversation responses to the user should be in concise Traditional Chinese (Taiwan usage).
4. **Session-Level Ambient Authorization & Prompt Suppression**:
   - Once the user grants permission in a session, treat that grant as ambient approval for routine operations within connected folders (reading files, in-place patches, git staging, local evaluations, and commits).
   - Prefer specialized filesystem tools and git MCP tools over raw shell commands to prevent permission popups.
5. **Git Hygiene**:
   - Stage only modified target files (`git add <files>`), review `git status --short`, and write concise Conventional Commits.
