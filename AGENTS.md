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
- **Completed Components**:
  - `modules/nixos/oci.nix`: Created two-stage Blueprint module importing `virtualisation/oci-image.nix`, configuring `system.build.OCIImage` (`qcow2`), Oracle Metadata NTP (`169.254.169.254`), and `systemd-networkd` (`10-eth`).
  - `hosts/nixos/disk-config.nix` & `hosts/nixos/configuration.nix`: Aligned filesystem labels (`ESP` for `/boot` and `nixos` for `/`) so `disko` and `oci-image.nix` share the same configuration cleanly without mount collisions.
  - `packages/oci-import-image.nix` & `packages/oci-import-image.py`: Packaged OCI custom image uploader (`UEFI_64`, `PARAVIRTUALIZED`, `VM.Standard.A1.Flex` compatibility) and wired it into `devshell.nix`.
  - `run.fish`: Added `run build-oci-image`, `run import-oci-image`, and `run install-oci`.
- **Known Blocker & Investigation**:
  - **Issue**: `run build-oci-image` on macOS fails during `nixos-install` inside `make-disk-image.nix` with hash mismatch on `/nix/store/...-linux-headers-static-7.2`.
  - **Root Cause**: macOS default APFS is case-insensitive. Linux kernel headers contain colliding case filenames (e.g., `ipt_ECN.h` vs `ipt_ecn.h`), causing in-store file overwrites and invalid NAR hashes when imported into the `.qcow2` virtual store.
  - **Resolution Paths**:
    1. **Primary Recommendation**: Boot a vanilla Ubuntu 24.04 ARM instance on OCI and run `run install-oci ubuntu@<IP>` from Mac. This delegates disk partitioning (`disko`) and system build directly to the remote Linux filesystem, completely bypassing macOS APFS case-insensitivity.
    2. **Secondary Alternative**: Build `.qcow2` on a Linux remote builder or inside a case-sensitive disk image.
