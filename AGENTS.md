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

- **Nix Toolchain**: Built with Determinate Nix (`determinateNix` on macOS, `determinate` on NixOS) aligning with the [Determinate Nix Reference Manual](https://manual.determinate.systems/introduction.html).
  - **Modern CLI Invariant**: Exclusively use modern Nix 3 CLI commands (`nix profile`, `nix store`, `nix flake`) instead of legacy tools (`nix-env`, `nix-collect-garbage`).
  - **Profile Lifecycle**: Manage profile generations via `nix profile wipe-history [--profile <path>] [--older-than <duration>]`.
  - **Store Management**: Run store garbage collection via `nix store gc --verbose` and hard-link deduplication via `nix store optimise --verbose`.
  - **Build Diagnostics**: Use `nix top` and `nix ps` for active build process inspection and memory monitoring.
  - **Configuration Semantics**: Centralize daemon options in `modules/common/vars.nix` (`vars.customSettings`) supporting additive `extra-*` options, `parallel-eval`, and FlakeHub substituters (`https://install.determinate.systems`).
- **Development Shell**: Enter the shell via `nix develop` or automatic `direnv` activation.
  - Shell hook exports `IN_NIX_CONFIG_DEVSHELL=1`, unlocking commands in `run.fish`.
  - Single-Nix invariant: `packages/{nixos-rebuild.nix,nixos-anywhere.nix}` wrap scripts via `pkgs.writeShellScriptBin` to avoid putting a second `nix` binary in `PATH`.
- **Command Launcher (`run`)**:
  Commands follow the `run <verb>-<host>` format generated dynamically by `run.fish` (with `run <verb>-host` alias for the current machine). Note that Home Manager is embedded directly into `nix-darwin` via Blueprint, so `switch-MacBook-Pro` applies both macOS system settings and Home Manager user environments in a single unified execution:
  ```fish
  run switch-MacBook-Pro   # Apply nix-darwin + Home Manager unified configuration on macOS (requires sudo)
  run switch-host          # Shortcut for current host (e.g. switch-MacBook-Pro on macOS)
  run build-host           # Build current host toplevel closure without activating (outputs ./result)
  run check-host           # Builds current host toplevel closure with --no-link (no activation, no root required)
  run switch-nixos         # Build and deploy remote NixOS configuration to Oracle Cloud
  run edit-age             # Interactively select and edit encrypted secrets with fzf + agenix
  ```
  - **Verification Matrix & Exit Status Invariant**:
    | Changed Paths | Required Verification Before Commit / Push |
    | :--- | :--- |
    | `*.nix`, `flake.lock`, `modules/`, `hosts/`, `users/`, `packages/`, `devshell.nix` | `run check-MacBook-Pro` (+ NixOS eval if `hosts/nixos` or cloud profile modified) |
    | Only `config/**` (raw dotfiles not consumed by Nix expressions) | May skip Nix build; add `no-nix-check` to commit body |
    | Newly added / deleted files referenced by Nix expressions | Must run `git add` before evaluating (`nix build` requires files tracked by git) |
    - **Never Mask Exit Codes**: Never pipe verification commands directly into `tail` or `head` without preserving pipeline status (`set -o pipefail` in Bash/Zsh, `$pipestatus` in Fish). Evaluate success strictly by the process exit status (`$? == 0`), never by the presence of terminal output lines.
- **Secrets Management**:
  - Encrypted files and keys live in the private repository `~/Developer/nix-secrets`.
  - Recipient rules are defined in `agenix-rules.nix` (migrated from deprecated `secrets.nix`; explicit fallback via `AGENIX_RULES`).
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
   - **Flake Input Updates**: Always use `nix flake update <input> --flake ~/Developer/nix-dotfiles` when updating flake inputs (instead of `nix flake lock --update-input`). If a user-supplied command conflicts with this specification, follow `AGENTS.md` and state the substitution in a single concise line.
   - **Git Staging Guardrail**: Flakes evaluate only files tracked by Git. Always stage newly added files (`git add`) before running `nix flake check` or evaluations.
   - **Git Tooling Split & Safe Execution**:
     - IDE / Gemini sessions with the `git` MCP server must use `client:execute_mcp`.
     - Terminal `agy` sessions without MCP execute native `git` CLI directly in the shell.
     - Destructive operations (`--force`, `reset --hard`, `clean -fd`, branch deletions) strictly require explicit user confirmation.
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
7. **Staging & Commit Protocol**:
   - **Pre-Commit Index Audit**: Before committing, inspect `git status --short` and compare against intended targets. Proactively alert on unexpected staged entries (especially file deletions `D ` or untracked sensitive files) before executing `git commit`.
   - **Tracked vs. Untracked (`git add -u`)**: Remember that `git add -u` strictly stages tracked modifications and skips untracked files (`??`). After `git add -u`, always check `git status --short` for untracked files that were intended to be included.
   - **Flake Lock Invariant**: When running `nix flake update <input>`, always stage `flake.lock` in the exact same commit as the `flake.nix` modification that required it (`git add flake.nix flake.lock`).
   - **Format Isolation**: Run `nix fmt` as a standalone style commit (`style: nix fmt`), never bundled into feature or bugfix commits.
   - **Accurate Scope & Multi-Agent Concurrency**: Commit messages must accurately describe only the files present in that commit. When collaborating across multiple active agents, run `git status` immediately before committing; if git reports `nothing to commit`, inspect `git log -3 --stat` to verify whether a concurrent agent already committed those changes.
8. **Terminal Tool Contract (`agy`)**:
   - Tool nomenclature varies by client runtime: `agy` uses `read_file` / `edit_file` / `write_file` / `run_command`, which correspond conceptually to `view_file` / `replace_file_content` / `write_to_file`.
   - In interactive Zsh environments, always quote wildcards and globs (e.g. `--include="*.nix"`).
   - Fish-specific commands must be invoked inside the devshell: `nix develop --command fish -c "run <verb>-<host>"`.

---

## 6. Available Skills & Agent Instructions

Automated agents (`agy`, Claude, Gemini, Copilot, Cursor) operating on this repository have access to modular skills located in `.agents/skills/`, `.gemini/skills/`, and `~/.gemini/skills/`:

| Skill | Path | Description & When to Load |
| :--- | :--- | :--- |
| `@fast-repo-reader` | `.agents/skills/fast-repo-reader/SKILL.md` | Non-intrusive remote inspection of external Git/GitHub repos without shell network prompts. |
| `@nix-dotfiles-workflow` | `.agents/skills/nix-dotfiles-workflow/SKILL.md` | Core architecture guardrails (no `flake.lock` reading, single-tier module headers, out-of-store symlinks). |
| `@tiered-agent-workflow` | `.agents/skills/tiered-agent-workflow/SKILL.md` | Two-tiered execution strategy: Pro-tier deep reasoning for planning -> Flash-tier surgical execution. |
| `@get-more-perspectives` | `.agents/skills/get-more-perspectives/SKILL.md` | Simulated 5-role advisory panel (Operator, Skeptic, Visionary, Customer, Finance) for trade-offs. |

Agents should consult the relevant `SKILL.md` before executing multi-repo analyses or structural modifications.

---

## 7. Operational Retrospectives & Triad Collaboration

1. **Foreign Binary Packaging (Non-NixOS Target)**:
   - When cross-compiling or packaging ELF binaries destined for non-NixOS systems (e.g., UniFi OS, Debian, OpenWrt), **always** invoke `patchelf --set-interpreter /lib/ld-linux-aarch64.so.1` (or the target dynamic loader). Never allow the ELF interpreter to point to a `/nix/store/...` path that does not exist on the target machine.
2. **Push Secret Security Invariant**:
   - Never decrypt or bake secrets into Nix derivations or tarballs (which leak into world-readable `/nix/store`).
   - For non-NixOS hosts, decrypt secrets in-memory on the deployment controller (macOS) and pipe them directly into remote processes via SSH stdin (`read -r k; cmd --secret="$k"`).
3. **Dependency Parity First (Avoid Trial-and-Error Loops)**:
   - When a project uses Go `replace` directives or monorepo submodules (like `vpn-pack-manager` $\leftrightarrow$ `tailscale`), **never** guess dependency versions or iterate blindly against compiler errors.
   - Always inspect the upstream `go.mod` / `Cargo.lock` first, synchronize all transitive dependencies in one batch, and update `vendorHash` once.
4. **Triad Division of Labor**:
   - **Gemini (Lead Architect)**: Project-wide planning, multi-file atomic in-place patching, Blueprint conformity, and AGENTS.md maintenance.
   - **agy (Terminal Executor)**: Command execution in the active shell (`git add`, `nix fmt`, `run check-host`), live build inspection, and stderr capture.
   - **GitHub Copilot (Exploratory Scout)**: Open-source repository exploration on the web and in-editor snippet completions.
5. **Secret-Handling Wrapper Scripts**:
   - Scripts that serve purely as execution wrappers delegating secret decryption to `run.fish` must declare self-certification on line 2:
     `# agents: wrapper-only -- delegates to run.fish; no secret handling in this file`
   - Agents shall not re-audit annotated wrappers for secrets, but must immediately reject any script containing `age -d`, `agenix`, private key paths, or inline plaintext credentials.
   - Secret decryption and SSH-stdin transmission stay strictly encapsulated within `run.fish` memory.

---

## 8. Application Configuration Pitfalls & Verified Patterns

- **Ghostty Keybind Names (W3C Standard)**:
  - Ghostty keybind specifications follow W3C naming standards: use `bracket_left` and `bracket_right` (e.g. `super+bracket_left`), never `open_bracket` or `close_bracket` (which produce `keybind: unknown error error.InvalidFormat`).
- **Ghostty Window Decoration & macOS Native Tabs**:
  - Setting `window-decoration = none` in `config/ghostty/config` strips the macOS native window titlebar that hosts tabs.
  - When utilizing `macos-titlebar-style = tabs`, do not set `window-decoration = none`.
- **Helix Language Server Definitions**:
  - In `languages.toml`, every entry in `language-servers = [...]` requires a corresponding `[language-server.<name>]` definition block and a verified Nix-provided binary in `PATH` (e.g. `pkgs.taplo`, `pkgs.nil`).
- **GitHub Actions Runner Matrix**:
  - Never evaluate or build `darwinConfigurations` closures on Linux runners (`ubuntu-latest`). Darwin configurations require a macOS runner or pure evaluation modes (`nix eval`).
- **External Snippet Verification**:
  - Before applying configurations discovered from external repositories or LLM suggestions, cross-reference option names and schemas against the pinned `nixpkgs` and package release versions.
