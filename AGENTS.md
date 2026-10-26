# Agent Workflow & Architecture Rules (`nix-dotfiles`)

## 1. Token-Efficient Workflow
- **Inspect Narrowly**: Read only the target module or line range instead of scanning the entire repository.
- **Edit In-Place**: Patch files directly rather than outputting full-file copy-paste tutorials in chat.
- **Verify Locally**: Run `nix flake check` (or targeted `nix eval`) before replying. Fix errors before presenting results.
- **Respond Concisely**: Think in English, keep code comments (`#`) in English, and reply in concise Traditional Chinese (Taiwan usage).

## 2. Core Architecture Guardrails
- **Blueprint Two-Stage Modules**: Every module under `modules/darwin/`, `modules/nixos/`, `modules/home/`, and `modules/common/` must use the two-stage publisher header (`{ inputs, flake, ... }: { config, pkgs, lib, ... }:`) so `leporuid/blueprint` evaluates it as a function rather than a raw path during `nix flake check`.
- **Import via Flake Outputs**: Import Blueprint modules via `inputs.self.nixosModules.*`, `inputs.self.darwinModules.*`, or `inputs.self.homeModules.*` instead of relative paths (`../../modules/...`).
- **Platform Split**:
  - **macOS (`hosts/MacBook-Pro`)**: Uses `nix-darwin` + Home Manager (`users/leporuid/home-configuration.nix` importing `users/leporuid/cloud-configuration.nix`) with `my.config.useOutOfStoreSymlinks = true`. Login shell is Zsh handing off to Fish.
  - **Oracle NixOS (`hosts/nixos`)**: Uses system-level `modules/nixos/` (`essentials`, `programs`, `tailscale`) without Home Manager. Login shell is `pkgs.bashInteractive` handing off to Fish interactively when a TTY is present and the parent process is not Fish.
- **Raw Config Symlinks**: Keep raw application configs in `config/` and symlink them via `my.config.source`. Do not rewrite `config/` files into Nix-generated `programs.<name>.settings`.
- **Determinate Nix & Devshell**: Both macOS (`determinateNix`) and NixOS (`determinate`) use Determinate Nix. In `devshell.nix`, never add a second `nix` binary to `PATH` (wrap `nixos-rebuild-ng` via `writeShellScriptBin` instead of `pkgs.nixos-rebuild`) so `nix doctor` passes with a single Nix in `PATH`.
- **Package Overrides**: Place package-specific overrides or custom tools in `packages/*.nix` (consumed via `perSystem.self.<pkg>`) rather than global overlays.
