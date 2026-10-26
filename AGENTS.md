# Agent Workflow & Architecture Rules (`nix-dotfiles`)

## 1. Strict Token-Limiting Guardrails (Highest Priority)
- **Absolute Ban on Reading `flake.lock`**: Never inspect, read, or print `flake.lock`. If verifying inputs or hashes, run `nix flake metadata` or use targeted `grep`.
- **Truncate Command & Build Outputs**: Nix evaluation, check, and build commands can output massive stack traces. Always cap output by piping: `2>&1 | tail -n 40` (or `head -n 40`). Never dump raw compiler logs into conversation.
- **Search-First, Narrow Inspection**: When auditing, reviewing, or tracing files, never scan full directories recursively. Use `rg`, `grep -rn`, or `ast-grep` to locate line numbers first, then read only the target lines (±15 lines).
- **In-Place Patching & Diff Edits**: Apply edits directly via replacement/patch tools. Present changes as concise line-level diffs. Never reprint full unmodified files.
- **Eliminate Conversational Filler**: Skip pleasantries and greetings; provide actionable diffs and commands directly.

## 2. Core Architecture Guardrails
- **Git Staging Guardrail (`git add`)**: Flakes strictly ignore untracked files. Stage new/modified files (`git add <file>`) before running `nix flake check`, `nix eval`, or rebuilds.
- **Blueprint Two-Stage Modules**: Every module under `modules/darwin/`, `modules/nixos/`, `modules/home/`, and `modules/common/` must use the two-stage publisher header (`{ inputs, flake, ... }: { config, pkgs, lib, ... }:`) so Blueprint evaluates them as functions.
- **Import via Flake Outputs**: Import Blueprint modules via `inputs.self.nixosModules.<name>`, `inputs.self.darwinModules.<name>`, or `inputs.self.homeModules.<name>` instead of relative paths.
- **Platform Split**:
  - **macOS (`hosts/MacBook-Pro`)**: Uses `nix-darwin` + Home Manager (`users/leporuid/home-configuration.nix`) with `my.config.useOutOfStoreSymlinks = true`. Login shell is Zsh handing off to Fish.
  - **Oracle NixOS (`hosts/nixos`)**: Uses system-level `modules/nixos/` without Home Manager. Login shell is `pkgs.bashInteractive` handing off to Fish interactively when a TTY is present and parent process is not Fish. Never delete `hosts/nixos/users/`.
- **NixOS vs. Darwin Syntax**:
  - NixOS: Use standard `nix.settings.experimental-features = [ ... ]` (never `extra-experimental-features`).
  - Darwin: Use `determinateNix.customSettings` (where additive `extra-experimental-features` is supported).
  - Use `trusted-users = [ "root" ]` on NixOS (never broad `@wheel`).
- **Raw Config Symlinks**: Keep raw application configs in `config/` (e.g. `config/fish/`, `config/direnv/`, `config/jj/`) and map them via `my.config.source` / `my.system.config.source`. Do not rewrite them into Nix options.
- **Determinate Nix & Devshell**: Both platforms use Determinate Nix. In `devshell.nix`, never add a second `nix` binary to `PATH` (wrap `nixos-rebuild-ng` via `pkgs.writeShellScriptBin` instead of adding `pkgs.nixos-rebuild`).
- **Custom Packages & N_m3u8 (`packages/*.nix`)**:
  - Place custom packages in `packages/<name>.nix` (consumed via `perSystem.self.<name>`) instead of global overlays.
  - Keep `packages/m3u8dl-protocol/main.m` as native Objective-C compilation; do not convert to Python scripts.
  - Document any skipped upstream test overrides with an explanatory English comment.
- **State Version Safety**: Keep `system.stateVersion` and `home.stateVersion` pinned to the deployment release (e.g., `25.11`), never bump to future unreleased versions.
- **Oracle Network Security**: Run Tailzero exclusively (`services.tailscale.enable = false`). Never broadcast metadata IP `169.254.169.254`. Keep UDP 41641 open, set SSH `ClientAliveInterval = 60`, and configure Fail2ban to ignore `100.0.0.0/8`.

## 3. Communication & Code Standards
- **Language**: Think in English, write all code comments (`#`, `/* */`) and terminal strings in English, and reply to user prompts in concise Traditional Chinese (Taiwan usage).