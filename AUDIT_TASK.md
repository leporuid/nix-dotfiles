# Migration Audit & Completion Task (`nix-dotfiles-archive` -> `nix-dotfiles`)

## Context & Repositories
- **Target repo (new `red-tape` + `Hjem` architecture)**: `/Users/leporuid/Developer/nix-dotfiles`
- **Legacy reference (old Blueprint + Home Manager architecture)**: `/Users/leporuid/Developer/nix-dotfiles-archive`
- **Framework repo**: `/Users/leporuid/Developer/red-tape`

## Hard Guardrails
1. **NEVER read `flake.lock`** in full or dump lockfiles into context. Use `rg` / `git diff` / `nix flake metadata` for targeted checks only.
2. **Exclude `.DS_Store`** from all directory diffs.
3. Follow `pedantix.toml` argument order (`["self", "inputs", "config", "lib", "pkgs", ..., "<defaulted>", "..."]`), `nixfmt` (RFC 166), and `statix.toml`.
4. All code comments and commit messages must be in clean English; final report to the user in Traditional Chinese (`zh-Hant`).

## Audit Scope (Execute in Order)

### 1. `devshell.nix` & Development Environment Completeness
- Compare `~/Developer/nix-dotfiles-archive` (e.g., `devshell.nix` / `flake.nix` devShell definitions) against `~/Developer/nix-dotfiles`.
- Verify all developer tools, `shellHook`s, and `numtide/llm-agents.nix` (`llm-agents-launcher` / `agy`), formatters/linters (`nixfmt`, `treefmt`, `pedantix`, `statix`, `nil`), `rage`/`agenix`, `just`, `nixos-anywhere`, etc., are completely ported to `nix-dotfiles`'s `devShells`.
- Patch any missing packages, inputs, or shell hooks in `devshell.nix` (or `flake.nix`).

### 2. `red-tape` & `Hjem` / `Hjem-Rum` Integration Completeness
- Cross-check `/Users/leporuid/Developer/red-tape` (`contrib/hjem.nix`, `contrib/darwin.nix`, `modules/hosts.nix`, `modules/default.nix`) against `~/Developer/nix-dotfiles/flake.nix` and `modules/`.
- Confirm whether all intended `red-tape` modules, `hjemModules`, `rumModules`, `hjemConfigurations`, `darwinModules`, `nixosModules`, and `lib` helpers are properly imported and exposed in `nix flake show`.
- Verify `users/leporuid/home-configuration.nix` and `hosts/*/users/leporuid/home-configuration.nix` cleanly evaluate both system-integrated Hjem and standalone `hjemConfigurations.leporuid`.

### 3. Duplicate Definitions & Dead Code Detection
- Audit `modules/{common,darwin,nixos,hjem}/`, `hosts/{MacBook-Pro,nixos,nixos-vm}/`, and `users/leporuid/home-configuration.nix` for:
  - Duplicate packages installed across both `environment.systemPackages` / `homebrew` and Hjem `packages`.
  - Duplicate `my.config.source` entries, `environment.sessionVariables`, or `files` declarations.
  - Unused module arguments or leftover template files from `red-tape` / `blueprint`.

### 4. Blueprint (`nix-dotfiles-archive`) Feature Parity Gap Analysis
- Run targeted structural diffs between `~/Developer/nix-dotfiles-archive` and `~/Developer/nix-dotfiles` across `lib/`, `overlays/`, `packages/`, `hosts/`, `modules/`, `config/`, and `checks/`.
- Categorize every difference into:
  1. **Intentional obsolescence** (e.g., legacy Home Manager bridges replaced by Hjem/Hjem-Rum).
  2. **Accidental omission / missing feature** (missing overlay, package, formatter check, host setting, or `lib` function) -> **fix and port these directly**.

## Verification Before Reporting
Run and ensure all pass with zero regressions:
```zsh
cd ~/Developer/nix-dotfiles
nix fmt
nix flake show
nix flake check
nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
nix eval .#hjemConfigurations.leporuid.manifest --json | head -n 20