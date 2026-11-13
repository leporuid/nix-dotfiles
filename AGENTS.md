# Agent Guide (`nixos-and-darwin-shared-hjem`)

This repository collects project-specific expectations, tool contracts, and architectural guardrails for automated coding agents working across macOS (`nix-darwin`) and Linux (`NixOS`) powered by **`red-tape`**, **`adios-flake`**, **`hjem`**, and **`hjem-impure`**.

---

## 1. Repository Layout

| Directory / File | Description & Purpose |
| :--- | :--- |
| `flake.nix` | Root `red-tape.mkFlake` entrypoint; tracks inputs, system matrix, and flake settings. |
| `devshell.nix` | Developer shell toolchain sourcing `git-hooks.nix` (`nil`, `statix`, `treefmt`) and generating `.pre-commit-config.yaml`. |
| `pedantix.toml` | Nix code style and argument sorting rules enforced across the repository. |
| `hosts/MacBook-Pro/` | Darwin host configuration (`darwin-configuration.nix`) and user profile bridge. |
| `hosts/nixos/` | Self-contained native NixOS configuration for Oracle Cloud / server (`configuration.nix`). |
| `hosts/nixos-vm/` | Lightweight NixOS VM configuration. |
| `modules/darwin/` | Darwin system modules (`applications.nix`, `system-defaults.nix`, `hjem.nix`). |
| `modules/nixos/` | NixOS system modules (`host-shared.nix`, `hjem.nix`). |
| `modules/hjem/` | User-level Hjem modules (`my-config.nix`, `fish.nix`, `neovim.nix`, `nixcord.nix`, `themes.nix`, `direnv-instant.nix`). |
| `modules/common/` | Shared platform configurations (`vars.nix`, `hjem.nix`). |
| `packages/*.nix` | Custom derivations and package wrappers consumed via `inputs.self.packages.<system>.<name>`. |
| `users/leporuid/` | Shared user profile (`home-configuration.nix`) managing packages and files. |
| `config/` | Raw upstream configurations (`fish/`, `nushell/`, `starship.toml`, `git/`, `nvim/`, `agents/`, etc.). |

---

## 2. Environment & Tooling Contracts

- **Nix Toolchain**: Built with Determinate Nix (`determinateNix` on macOS, `determinate` on NixOS) aligning with the Determinate Nix Reference Manual.
  - **Modern CLI Invariant**: Exclusively use modern Nix 3 CLI commands (`nix profile`, `nix store`, `nix flake`) instead of legacy tools (`nix-env`, `nix-collect-garbage`).
  - **Profile Lifecycle**: Manage profile generations via `nix profile wipe-history [--profile <path>] [--older-than <duration>]`.
  - **Store Management**: Run store garbage collection via `nix store gc --verbose` and hard-link deduplication via `nix store optimise --verbose`.
  - **Build Diagnostics**: Use `nix top` and `nix ps` for active build process inspection and memory monitoring.
- **Home Management via Hjem & Hjem-Impure**:
  - Replaces heavy Home Manager with ultra-lightweight `hjem`.
  - **Clobber Invariant**: Always ensure `hjem.clobberByDefault = true;` to avoid collisions with existing files. File overrides use the `clobber` attribute (never deprecated `force`).
  - **No Empty Files**: Hjem modules must never generate empty or placeholder files.
  - **Impure Dev Mode**: Run `hjem-impure` in terminal to replace immutable store symlinks with live links pointing directly back to `config/`.
- **Formatting & Style**:
  - Code formatting is managed via `treefmt` (`nix fmt`).
  - Function argument ordering is strictly enforced by `pedantix.toml`:
    `first = ["self", "inputs", "config", "lib", "pkgs"]`, followed by alphabetical domain args, and `<defaulted>`, `...` last.
- **Verification Matrix & Exit Status Invariant**:
  | Changed Paths | Required Verification Before Commit / Push |
  | :--- | :--- |
  | `*.nix`, `flake.lock`, `hosts/`, `users/`, `modules/`, `packages/` | `nix fmt`, `nix flake check`, and host evaluation check (`darwinConfigurations.MacBook-Pro` & `nixosConfigurations.nixos`) |
  | Only `config/**` (raw dotfiles) | May skip full rebuild; test with `hjem-impure` |
  | Newly added / deleted files referenced by Nix expressions | Must run `git add` before evaluating (`nix flake check` requires tracked files) |
  - **Never Mask Exit Codes**: Never pipe verification commands directly into `tail` or `head` without preserving pipeline status. Evaluate success strictly by exit code (`$? == 0`).

---

## 3. Core Architecture Guardrails

- **red-tape Convention**:
  - `red-tape.mkFlake` automatically discovers `hosts/`, `packages/`, `modules/`, and `devshell.nix`.
  - Pass `inherit self inputs;` to `red-tape.mkFlake`.
  - Enable platform modules explicitly:
    ```nix
    modules = [
      inputs.red-tape.modules.redTape.darwin
      inputs.red-tape.modules.redTape.hjem
    ];
    ```
  - Module headers must strictly follow `pedantix.toml` argument order.
- **Top-Level Imports**:
  - Never place `imports = [ ... ];` inside a `config = lib.mkIf ... { ... }` block; module imports must always remain at the top level of the module file.
- **Hjem Configuration & Arguments**:
  - Pass flake inputs to Hjem modules via `hjem.specialArgs = { inherit inputs; };`.
  - Program options are located under `rum.programs.<program>` (e.g. `rum.programs.git`, `rum.programs.fish`).
- **Raw Application Configurations (`config/`)**:
  - Keep application configurations directly under root `config/`.
  - Linked via Hjem `files` (`my.config.source`) and managed live via `impure.dotsDir` / `impure.dotsDirImpure` (`hjem-impure`).

---

## 4. Platform Split & Security Model

### macOS (`hosts/MacBook-Pro`)
- Managed by `nix-darwin` + `hjem`.
- **Primary Interactive Shell**: **Fish** (`programs.fish.enable = true;`, `users.users.${config.system.primaryUser}.shell = pkgs.fish;` in `modules/darwin/system-defaults.nix`).
- **Home Directory**: Explicitly set `directory = "/Users/leporuid";` under `hjem.users.leporuid`.
- **Determinate Daemon**: `nix.enable = false;` to avoid conflicting with Determinate Nix daemon and launchd services.
- **License**: Unfree packages permitted via `nixpkgs.config.allowUnfree = true;`.

### Linux / Server (`hosts/nixos`)
- Managed by `nixos` + `hjem`.
- **Interactive Shell**: `bashInteractive` login shell chaining to `nushell`, with system `programs.fish.enable = true`.
- **Home Directory**: Standard `/home/leporuid`.
- **User Hardening**: `mutableUsers = false`, root password locked, OpenSSH key authentication only.

---

## 5. Agent Workflow & Execution Rules

1. **Mandatory Skills Loading (`agy` & Automated Agents)**:
   - Automated agents (`agy`, Claude, Gemini, Copilot, Cursor) operating in this repository **must** proactively load and strictly adhere to all skills located in `.agents/skills/` (and `config/agents/skills/`).
2. **Token Efficiency & Search-First**:
   - Locate targets using `grep_search` or `find_by_name` first.
   - Read only the specific target range (±20 lines) required; never dump whole directories or entire multi-hundred line files into context.
   - **Absolute Ban on Reading `flake.lock`**: Never read or display `flake.lock`. Use `nix flake metadata` for input revisions.
3. **In-Place Patching & Diffs**:
   - Apply edits directly using file edit tools.
   - Explain changes using concise targeted diffs. Never reprint full files in chat responses.
4. **Strict English Code Comments**:
   - All code comments (`#`, `//`, `/* */`) across all Nix expressions, shell scripts, and configuration files must strictly be written in English.
   - Conversation responses to the user should be in concise Traditional Chinese (Taiwan usage).
5. **Session-Level Ambient Authorization & Prompt Suppression**:
   - Once the user grants permission in a session, treat that grant as ambient approval for routine operations within connected folders (reading files, in-place patches, git staging, local evaluations, and commits).
   - Prefer specialized filesystem tools and git MCP tools over raw shell commands to prevent unnecessary permission prompts.
6. **Git Hygiene**:
   - Stage only modified target files (`git add <files>`), review `git status --short`, and write concise Conventional Commits.

---

## 6. Available Skills & Agent Instructions

Automated agents operating on this repository have access to modular skills located in `config/agents/skills/` (symlinked from `.agents/skills/`):

| Skill | Path | Description & When to Load |
| :--- | :--- | :--- |
| `@developer-workflow` | `.agents/skills/developer-workflow/SKILL.md` | Master orchestrator enforcing source-grounding, active context inspection, and multi-skill execution. |
| `@nix-dotfiles-workflow` | `.agents/skills/nix-dotfiles-workflow/SKILL.md` | Core Nix architecture guardrails (no `flake.lock` reading, single-tier module headers, out-of-store symlinks). |
| `@fast-repo-reader` | `.agents/skills/fast-repo-reader/SKILL.md` | Non-intrusive remote inspection of external Git/GitHub repositories without shell network prompts. |
| `@tiered-agent-workflow` | `.agents/skills/tiered-agent-workflow/SKILL.md` | Two-tiered execution strategy: Pro-tier deep reasoning for planning $\rightarrow$ Flash-tier surgical execution. |
| `@get-more-perspectives` | `.agents/skills/get-more-perspectives/SKILL.md` | Simulated 5-role advisory panel for evaluating trade-offs and architecture decisions. |

Agents must consult the relevant `SKILL.md` before executing multi-repo analyses or structural modifications.
