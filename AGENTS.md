# Agent Workflow & Architecture Rules (`nix-dotfiles`)

## 1. Token-Efficient Workflow
- **Inspect Narrowly**: Read only the target module or line range instead of scanning the entire repository.
- **Edit In-Place**: Patch files directly rather than outputting full-file copy-paste tutorials in chat.
- **Verify Locally**: Run `nix flake check` (or targeted `nix eval`) before replying. Fix errors before presenting results.
- **Strict English Code Comments**: All code comments (`#`, `//`, `/* */`) across all Nix expressions, shell scripts, and configuration files must strictly be written in English. Never use Chinese or non-English comments in the codebase or in code snippets presented in conversations.
- **Respond Concisely**: Think in English, keep code comments in English, and reply in concise Traditional Chinese (Taiwan usage).

## 2. Core Architecture Guardrails
- **Single-Tier Module Headers**: Modules under `modules/darwin/`, `modules/home/`, and `modules/common/` strictly use standard single-tier module functions (`{ inputs, pkgs, config, lib, vars, ... }: { ... }`). Do NOT convert them into two-stage curried headers (`{ inputs, flake, ... }: { config, pkgs, lib, ... }:`) or flag them during checks. In this repository, `specialArgs` and `_module.args` pass all required arguments directly, and single-tier declarations are the intentional, canonical design.
- **Import via Flake Outputs**: Import Blueprint modules via `inputs.self.darwinModules.*`, `inputs.self.homeModules.*`, or `inputs.self.modules.common.*` instead of relative paths (`../../modules/...`).
- **Shared Common Modules (`modules/common/`)**:
  - `vars.nix`: Exposes `_module.args.vars` containing platform-aware `username`, `hostname`, `homeDirectory`, `locale`, `timezone`, `sshKeys`, `sshKeyFiles`, and `caches` (`extra-substituters` and `extra-trusted-public-keys`). Do not create or expect a separate `_module.args.nixCaches`.
- **Platform Split**:
  - **macOS (`hosts/MacBook-Pro`)**: Uses `nix-darwin` + Home Manager (`users/leporuid/home-configuration.nix` importing `users/leporuid/cloud-configuration.nix`) with `my.config.useOutOfStoreSymlinks = true`. Login shell is Zsh handing off to Fish.
  - **Oracle NixOS (`hosts/nixos`)**: Self-contained native NixOS configuration in `hosts/nixos/configuration.nix` (no `modules/nixos/*.nix` indirection, no Home Manager). Includes BBR congestion control, ZRAM swap, Jumbo frames (MTU 9000), Tailscale, and login shell `pkgs.bashInteractive` handing off to Fish with TTY guard.
- **Raw Config Symlinks**: Keep raw application configs in `config/` and symlink them via `my.config.source` (Mac) or `environment.etc` (Oracle). Do not rewrite `config/` files into Nix-generated `programs.<name>.settings`.
- **Determinate Nix & Devshell**: Both macOS (`determinateNix`) and NixOS (`determinate`) use Determinate Nix. In `packages/{nixos-rebuild.nix,nixos-anywhere.nix}`, wrap `nixos-rebuild-ng` and `nixos-anywhere` via `writeShellScriptBin`, consumed in `devshell.nix` as `perSystem.self.nixos-rebuild` and `perSystem.self.nixos-anywhere` so `nix doctor` passes with a single Nix in `PATH`.
- **Package Overrides (`packages/*.nix`)**: Place package-specific overrides or custom tools in `packages/*.nix` (consumed via `perSystem.self.<pkg>`) rather than global overlays.
