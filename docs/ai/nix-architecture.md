# Nix Architecture Quick Reference

## Core Stack

- **Flake framework**: `leporuid/red-tape` (`red-tape.mkFlake`) auto-discovers `hosts/`, `packages/`, `modules/`, `devshell.nix`, and `formatter.nix`.
- **Home environment**: `hjem` + `hjem-rum` (never Home Manager). Keep `hjem.clobberByDefault = true;` and use `clobber` instead of `force`.
- **Config synthesis (`modules/hjem/my-config.nix`)**:
  - `my.config.useOutOfStoreSymlinks = isDarwin;` links raw files in `config/` live on macOS without rebuilds.
  - Linux hosts (`nixos`, `nixos-vm`) use pure Nix store paths.

## Code Style & Validation

- **Module headers (`pedantix.toml`)**: `self`, `inputs`, `config`, `lib`, `pkgs`, alphabetical domain arguments, defaulted arguments, `...`.
- **No `with pkgs;`**: prefer explicit `pkgs.<name>` and top-level `inherit (lib.<subpath>) ...;`.
- **English comments only** in all Nix, shell, and config files.
- **Stage new files first**: `git add <new-files>` before `nix flake check` or host evaluation.
- **Standard checks**:
  - `nix fmt`
  - `pedantix --check (fd -e nix -E hardware-configuration.nix)` (in devshell)
  - `nix flake check --all-systems --no-build --no-write-lock-file`
  - `nix eval --raw .#darwinConfigurations.MacBook-Pro.config.system.build.toplevel.drvPath`
  - `nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath`
