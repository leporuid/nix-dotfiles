# Agent Workflow & Architecture Rules (`nix-dotfiles`)

## 1. Token-Efficient Workflow
- **Inspect Narrowly**: Read only the target module or line range instead of scanning the entire repository.
- **Edit In-Place**: Patch files directly rather than outputting full-file copy-paste tutorials in chat.
- **Verify Locally**: Run `nix flake check` (or targeted `nix eval`) before replying. Fix errors before presenting results.
- **Respond Concisely**: Think in English, keep code comments (`#`) in English, and reply in concise Traditional Chinese (Taiwan usage).

## 2. Core Architecture Guardrails
- **Blueprint Two-Stage Modules**: Every module under `modules/darwin/`, `modules/home/`, and `modules/common/` must use the two-stage publisher header (`{ inputs, flake, ... }: { config, pkgs, lib, ... }:`) so `leporuid/blueprint` evaluates it as a function rather than a raw path during `nix flake check`.
- **Import via Flake Outputs**: Import Blueprint modules via `inputs.self.darwinModules.*`, `inputs.self.homeModules.*`, or `inputs.self.modules.common.*` instead of relative paths (`../../modules/...`).
- **Shared Common Modules (`modules/common/`)**:
  - `vars.nix`: Exposes both `_module.args.vars` (platform-aware `username`, `hostname`, `homeDirectory`, `locale`, `timezone`, `sshKeys`, `sshKeyFiles`) and `_module.args.nixCaches` (`extra-substituters` and `extra-trusted-public-keys`).
- **Platform Split**:
  - **macOS (`hosts/MacBook-Pro`)**: Uses `nix-darwin` + Home Manager (`users/leporuid/home-configuration.nix` importing `users/leporuid/cloud-configuration.nix`) with `my.config.useOutOfStoreSymlinks = true`. Login shell is Zsh handing off to Fish.
  - **Oracle NixOS (`hosts/nixos`)**: Self-contained native NixOS configuration in `hosts/nixos/configuration.nix` (no `modules/nixos/*.nix` indirection, no Home Manager). Includes BBR congestion control, ZRAM swap, Jumbo frames (MTU 9000), Tailscale, and login shell `pkgs.bashInteractive` handing off to Fish with TTY guard.
- **Raw Config Symlinks**: Keep raw application configs in `config/` and symlink them via `my.config.source` (Mac) or `environment.etc` (Oracle). Do not rewrite `config/` files into Nix-generated `programs.<name>.settings`.
- **Determinate Nix & Devshell**: Both macOS (`determinateNix`) and NixOS (`determinate`) use Determinate Nix. In `packages/{nixos-rebuild.nix,nixos-anywhere.nix}`, wrap `nixos-rebuild-ng` and `nixos-anywhere` via `writeShellScriptBin`, consumed in `devshell.nix` as `perSystem.self.nixos-rebuild` and `perSystem.self.nixos-anywhere` so `nix doctor` passes with a single Nix in `PATH`.
- **Package Overrides (`packages/*.nix`)**: Place package-specific overrides or custom tools in `packages/*.nix` (consumed via `perSystem.self.<pkg>`) rather than global overlays.
