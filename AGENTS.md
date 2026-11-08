# Agent Guide (`nix-dotfiles`)

This repository collects project-specific expectations, tool contracts, and architectural guardrails for automated coding agents working across macOS (`nix-darwin`) and Linux (`NixOS`).

---

## 1. Repository Layout

| Directory / File | Description & Purpose |
| :--- | :--- |
| `flake.nix` | Root Blueprint flake entrypoint; configures substituters, caches, and flake inputs. |
| `devshell.nix` | Developer shell toolchain (`run`, `nixos-rebuild`, `agenix`, `age-plugin-se`). |
| `run.fish` | Interactive command runner and environment launcher (`run <verb>-<host>`). |
| `hosts/MacBook-Pro/` | Darwin host configuration (`darwin-configuration.nix`) and user profile bridge. |
| `hosts/nixos/` | Self-contained native NixOS configuration for Oracle Cloud ARM A1 (`configuration.nix`). |
| `modules/darwin/` | System-level Darwin modules (`system-defaults.nix`, `fish-environment.nix`, `applications.nix`). |
| `modules/home/` | Home Manager modules (`my-config.nix`, `my-themes.nix`, `my-programs-fish.nix`, `my-programs-neovim.nix`). |
| `modules/common/` | Shared multi-platform modules (`vars.nix` for users/hosts/caches, `nixpkgs-unstable.nix`). |
| `packages/*.nix` | Custom derivations and package wrappers consumed via `perSystem.self.<name>`. |
| `users/leporuid/` | Shared user profiles (`cloud-configuration.nix`, `home-configuration.nix`). |
| `config/` | Raw upstream configurations (`fish/`, `git/`, `nvim/`, `direnv/`, `jj/`, `starship.toml`, etc.). |

---

## 2. Environment & Tooling Contracts

- **Nix Toolchain**: Built with Determinate Nix (`determinateNix` on macOS, `determinate` on NixOS).
- **Development Shell**: Enter the shell via `nix develop` or automatic `direnv` activation.
  - Shell hook exports `IN_NIX_CONFIG_DEVSHELL=1`, unlocking commands in `run.fish`.
  - Single-Nix invariant: `packages/{nixos-rebuild.nix,nixos-anywhere.nix}` wrap scripts via `pkgs.writeShellScriptBin` to avoid putting a second `nix` binary in `PATH`.
- **Command Launcher (`run`)**:
  Commands follow the `run <verb>-<host>` format generated dynamically by `run.fish` (with `run <verb>-host` alias for the current machine). Note that Home Manager is embedded directly into `nix-darwin` via Blueprint, so `switch-MacBook-Pro` applies both macOS system settings and Home Manager user environments in a single unified execution:
  ```fish
  run switch-MacBook-Pro   # Apply nix-darwin + Home Manager unified configuration on macOS (requires sudo)
  run switch-host          # Shortcut for current host (e.g. switch-MacBook-Pro on macOS)
  run build-host           # Build current host toplevel closure without activating (outputs ./result)
  run check-host           # Fast evaluation check without creating ./result or building closures
  run switch-nixos         # Build and deploy remote NixOS configuration to Oracle Cloud
  run edit-age             # Interactively select and edit encrypted secrets with fzf + agenix
  ```
- **Secrets Management**:
  - Encrypted files and keys live in the private repository `~/Developer/nix-secrets`.
  - macOS uses `age-plugin-se` (Touch ID / Secure Enclave) alongside SSH keys.
  - `devshell.nix` overrides `agenix` with `pkgs.age` (`ageBin = "${pkgs.age}/bin/age"`) because standard `rage` lacks plugin support.

---

## 3. Core Architecture Guardrails

- **Single-Tier Module Headers**:
  - Modules under `modules/darwin/`, `modules/home/`, and `modules/common/` strictly use standard single-tier module functions:
    ```nix
    { inputs, pkgs, config, lib, vars, ... }: { ... }
    ```
  - Do **NOT** convert them into two-stage curried headers (`{ inputs, flake, ... }: { config, pkgs, lib, ... }:`).
- **Import via Flake Outputs**:
  - Always import Blueprint modules via flake outputs:
    - `inputs.self.darwinModules.<name>`
    - `inputs.self.homeModules.<name>`
    - `inputs.self.modules.common.<name>`
  - Never use relative file paths (e.g. `../../modules/...`) across module boundaries.
- **Shared Common Variables (`modules/common/vars.nix`)**:
  - Centralizes `username`, `hostname`, `homeDirectory`, `locale`, `timezone`, `sshKeys`, `sshKeyFiles`, and binary `caches`.
  - Consumed directly via `vars.<attribute>` in both Darwin and NixOS configurations.
- **Raw Application Configurations (`config/`)**:
  - Preserve raw application configurations directly in `config/` (never rewrite them into Nix-generated module settings like `programs.<name>.settings`).
  - Mapped via `my.config.source` on macOS (`useOutOfStoreSymlinks = true`) and `environment.etc` on NixOS.

---

## 4. Platform Split & Security Model

### macOS (`hosts/MacBook-Pro`)
- Managed by `nix-darwin` + Home Manager.
- **Login Shell**: System shell is Zsh, which cleanly hands off to Fish for interactive sessions (compatible with Terminus, Blink, Ghostty).
- **Symlinks**: Uses out-of-store symlinks (`my.config.useOutOfStoreSymlinks = true`) pointing to `~/Developer/nix-dotfiles/config/`.
- **Privilege Separation**: Strict privilege model; only trust `config.system.primaryUser`, never broad `@admin`.

### Oracle NixOS (`hosts/nixos`)
- Self-contained native configuration in `hosts/nixos/configuration.nix` (no Home Manager, no extra module indirection).
- **Kernel & Network**: BBR congestion control, FQ packet scheduling, Jumbo Frames (MTU 9000), ZRAM swap (zstd, 50% RAM), and socket receive buffer tuning (`net.core.rmem_default = 2MB`, `net.core.rmem_max = 16MB`).
- **Tailscale & Resilience**: Runs with Tailscale SSH (`--ssh`), exit node advertising, subnet routing, and systemd service auto-restart (`Restart = "always"`, `RestartSec = "5s"`). Never broadcast Oracle metadata IP `169.254.169.254/32`.
- **User Hardening**: `mutableUsers = false`, root password locked (`!`), OpenSSH restricted with `PermitRootLogin = "prohibit-password"` and `PasswordAuthentication = false`.

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
4. **Cache & Git Hygiene**:
   - **Purge Stale Direnv Cache**: When modifying Flake inputs, toolchains, or local build derivations that encounter persistent build or locking failures, purge the stale cache with `rm -rf .direnv` before rebuilding.
   - **Flake Input Updates**: Always use `nix flake update --flake ~/Developer/nix-dotfiles && cd ~/Developer/nix-dotfiles` when updating flake inputs (instead of `cd ~/Developer/nix-dotfiles && nix flake lock --update-input blueprint`).
   - **Git Staging Guardrail**: Flakes evaluate only files tracked by Git. Always stage newly added files (`git add`) before running `nix flake check` or evaluations.
   - For all Git version control operations, use `client:execute_mcp` with the `git` MCP server.
5. **Tiered Execution Strategy (Architect vs. Executor)**:
   - **Architect Mode (Pro Tier Reasoning)**: Prioritize deep, structured analysis when comparing external repositories, evaluating architecture trade-offs, or planning complex refactors before modifying code.
   - **Executor Mode (Flash Tier Efficiency)**: Once the plan is established, transition to token-minimal, surgical execution—apply targeted in-place patches, stage specific files (`git add <files>`), and commit with concise conventional commit messages without dumping full files.
6. **Session-Level Ambient Authorization & Prompt Suppression**:
   - **Continuous Session Authorization**: Once the user grants permission ('Allow') in a session or task, treat that grant as ambient approval for all subsequent operations within connected folders (reading files, in-place patches, git staging, local evaluations, and commits) for the remainder of the session without pausing for redundant confirmations.
   - **Prevent Unnecessary Client Permission Popups**:
     - Never set `RequiresNetworkAccess: true` on shell commands unless external network calls are genuinely required (setting network access triggers sandbox permission prompts).
     - Prefer specialized filesystem tools (`replace_file_content`, `write_to_file`, `view_file`) and `client:execute_mcp` for git operations instead of raw terminal commands.
     - Batch related filesystem and git operations into unified turns rather than prompting across fragmented micro-steps.
     - Reserve interactive user confirmation strictly for destructive, irreversible operations (such as force-pushing to remote or wiping uncommitted branches).
