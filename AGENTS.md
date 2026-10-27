# Agent Workflow & Architecture Rules (`nix-dotfiles`)

## 1. Token Budget & Cross-Agent Handover Guardrail (Highest Priority)
- **Pre-Task Token Budget Check**:
  - Before starting non-trivial inspection, heavy builds, or long multi-step workflows, evaluate whether the remaining conversation token budget is sufficient.
  - **Early Warning & Handover Trigger**: If context compaction has occurred or context approaches the window limit, do NOT attempt sprawling edits. Immediately update the **Active Task Status & Handover Context** section in this file, output a concise status summary, and provide a ready-to-run prompt for **Antigravity** (or another agent).
  - **Single Source of Truth**: All active task state, blockers, root causes, and recommended solutions live in Section 4 below. Do not scatter temporary markdown handovers across untracked files.
- **Strict Output Limiting**:
  - **Absolute Ban on Reading `flake.lock`**: Never inspect, read, or print `flake.lock`. Run `nix flake metadata` or use targeted `grep` on specific input names.
  - **Truncate Command & Build Outputs**: Cap Nix evaluation, check, and build command outputs with `2>&1 | tail -n 40` (or `head -n 40`). Never dump raw build logs or compiler traces into conversation.
  - **Search-First, Narrow Inspection**: Never scan directories recursively. Use `rg`, `grep -rn`, or `ast-grep` to locate lines, then read only target lines (±15 lines).
  - **In-Place Patching & Diff Edits**: Apply edits directly via replacement/patch tools. Present changes as concise line-level diffs; never reprint full unmodified files.

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

## 4. Active Task Status & Handover Context (Oracle OCI Deployment)
- **Current State**:
  - NixOS has been installed on Oracle Cloud instance (`nixos`) and is reachable via SSH (`leporuid@nixos`).
  - Remote rebuild (`run switch-nixos --impure`) failed during `nix.conf.drv` validation due to `auto-allocate-uids = true` without the experimental feature enabled.
  - Fixed `modules/nixos/base.nix`: Removed `auto-allocate-uids = true`, pruned unsupported settings (`eval-cores`, `lazy-trees`, `parallel-eval`), and ensured `trusted-users = [ "root" "leporuid" ]`.
- **Next Command to Execute**:
  - Run remote rebuild:
    ```fish
    run switch-nixos --impure
    ```
- **Post-Switch Verification**:
  - Verify services: `ssh leporuid@nixos "systemctl status fail2ban systemd-networkd"`
  - Verify Tailscale / Tailzero status.
