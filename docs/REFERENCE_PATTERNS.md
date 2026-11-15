# External Reference Patterns (`~/Developer` Archive Notes)

Distilled architectural patterns and reusable Nix snippets extracted from local reference clones prior to cleanup.

---

## 1. `moni-dz/nix-config` & `moni-dz/nixpkgs-f2k`

- **Full Repository Layout (`moni-dz/nix-config`)**:
  - `hosts/` (per-machine configs: `hands` NixOS, `riscake` nix-darwin), `modules/` (`common`, `nixos`, `darwin`, `hjem` option definitions), `profiles/` (reusable host/user presets enabling modules), `packages/` (overlays & custom packages), `dev/` (`treefmt` partition), `secrets/` (`agenix-rekey`), `.github/` + `.tangled/workflows/`.
- **Module Style (`modules/hjem/`)**:
  - Consistently import `inherit (lib.modules) mkIf mkDefault;` and `inherit (lib.options) mkEnableOption mkPackageOption;`, separate option schema (`modules/`) from enabled presets (`profiles/` / `users/leporuid/home-configuration.nix`), and gate shell hooks via `integrations.<shell>.enable` + `lib.mkMerge`.
- **Closure Diff on Activation (`profiles/dix.nix`)**:
  - Run `dix diff --full --color=always /run/current-system "$systemConfig" >&2 || true` inside `system.activationScripts.preActivation.text` (Darwin) and `system.activationScripts.dix` with `supportsDryActivation = true` (NixOS). Already adopted in `modules/common/dix.nix`.
- **Darwin Nushell Path Mirroring (`modules/hjem/nushell-darwin.nix`)**:
  - When `XDG_CONFIG_HOME` is not inherited by GUI-launched tools on macOS, mirror `config.xdg.config.files."nushell/{config.nu,env.nu}".source` into `Library/Application Support/nushell/`.
- **Remote Builders (`profiles/remote-builders.nix`)**:
  - Use `ssh-ng://<user>@<host> <arch> <keyPath> <jobs> <speed> big-parallel,benchmark -` under `nix.settings.builders` (or `determinateNix.customSettings.builders` on macOS Determinate Nix). Already adopted in `hosts/MacBook-Pro/darwin-configuration.nix` for `nixos`.
- **Personal Package Flake (`moni-dz/nixpkgs-f2k`)**:
  - Dedicated flake for custom/git packages with scheduled GitHub Actions updates and binary cache. In `nix-dotfiles`, `red-tape` already auto-discovers `packages/*.nix`; split into a separate cached repo only if build times justify Cachix overhead.

---

## 2. `snugnug/hjem-rum` (`hjr-wrapped`)

- **Cross-Shell Integration Pattern (`modules/collection/programs/zoxide.nix`)**:
  - Expose `integrations.{fish,nushell,zsh}.enable` boolean sub-options; emit `mkAfter` init hooks for Fish/Zsh and `pkgs.runCommand` generated `.nu` files for Nushell.
  - **Collision Guard**: Never enable `integrations.<shell>.enable = true` if `my.config.source` already manages that shell's main config file (e.g., `fish/config.fish`).

---

## 3. `Malix-Labs/Nix_Schemas-Evaluator` (`Nix_Schemas-Evaluator`)

- **Pure-Nix Schema Unit Tests (`flake.nix`, `test/*.nix`)**:
  - Validate `flake-schemas` (`inventory`, `manifest`, `options`, `frameworks`) using pure Nix assertions (`assert allPassing; pkgs.runCommand "unit-tests" { } "touch $out"`). Useful if adding regression checks to `leporuid/red-tape`'s `hjemSchemas`.
- **Formatter Exit-Code Handling**:
  - When wrapping `pre-commit` as a `nix fmt` formatter, re-run once on exit code `1` (which indicates files were reformatted) to distinguish clean auto-formatting from real syntax failures.

---

## 4. `pyndys/nixugen` (`nixugen`)

- **Dynamic Matugen Theming for Hjem**:
  - Exposes `hjemModules.default` and `overlays.default` (`pkgs.matugenTemplates`). Enables runtime wallpaper-driven theme regeneration for Ghostty/Starship without Nix rebuilds if moving beyond static themes (e.g., Soft Neon Violet).

---

## 5. `jakeisnt/nixcfg`, `different-name/bundle-of-nix`, `azukit-dev`, `age-plugin-se`

- **`nixcfg`**: Confirms `determinateNix.customSettings` writes `/etc/nix/nix.custom.conf` alongside Determinate Nix daemon management.
- **`bundle-of-nix`**: Feature-grouped `flake-parts` alternative; lacks standalone `hjem` host support (our `leporuid/red-tape` + `hjemConfigurations` Manifest v3 is already further ahead).
- **`azukit-dev`**: Fast cached `sheldon` Zsh plugin initialization (already integrated into `config/zsh/.zshrc`).
- **`age-plugin-se`**: Upstream SwiftPM/Secure Enclave source; already packaged cleanly in `packages/age-plugin-se.nix`.

---

## 6. `4evy/ndw` (`ndw`)

- **Minimal `nix-darwin` Hard Fork**: Strips `nix-darwin` down to `aarch64-darwin` (macOS 27+) core modules (`determinate`, `system`, `environment`, `files`, `users`, `networking`, `bash`, `zsh`, `launchd`, `homebrew`).
- **Why Not Replace `nix-darwin` in `nix-dotfiles`**: Drops `programs.fish`, `security.pam` (`sudo_local` Touch ID), `services.openssh`, `ids.gids.nixbld`, and `nix-index-database`, and conflicts with `hjem.darwinModules.default` (`system.activationScripts`) and `modules/darwin/determinate/`.
- **Adopted Pattern (`system.settings` / `settings-current`)**: Exposes `apps.aarch64-darwin.settings-{current,capture,apply}` (ported from `nix-plist-manager`). Useful as an on-demand scanner (`nix run github:4evy/ndw#settings-current`) to audit live macOS preferences and sync missing keys into `modules/darwin/system-defaults.nix`.

---

## 7. `SushyDev/nix-plist-manager`

- **Scope**: 552 macOS 27 System Settings (506 per-user via `home-manager`, 46 system-wide via `nix-darwin`; 398 verified round-tripped against System Settings UI).
- **Hjem-First Feasibility**:
  - **Recommended (CLI Diff)**: `nix run github:sushydev/nix-plist-manager#current -- mac.nix` and `--against mac.nix` to track UI changes on demand without adding flake inputs.
  - **Full Module Integration**: Not drop-in for Hjem because the 506 user settings target `home-manager`; keeping `modules/darwin/system-defaults.nix` avoids maintaining a custom Hjem shim.

---

## 8. `sk4rd/mikos-den` & `cnsta/cnix`

- **`sk4rd/mikos-den` (Dendritic `den` + `import-tree` + `hjem`)**:
  - **Aspect-per-Feature (`modules/features/*.nix`)**: Combines NixOS system and `hjem` user configuration inside a single dendritic aspect (`den.aspects.<name>.{nixos,hjem}`).
  - **VM Testing Variant (`modules/features/nixos-testing-vm.nix`)**: Uses `virtualisation.vmVariant` to override normal user passwords to `"test"` and disable `age.secrets` for frictionless VM boot tests.
  - **Pure-Data Semantic Theme (`lib/theme/`)**: Maps raw palette hexes to semantic roles (`colors.bg`, `colors.syntax.*`, `colors.diff.*`) and keeps font packages as attribute paths (`[ "nerd-fonts" "blex-mono" ]`).
- **`cnsta/cnix` (`flake-parts` + `hjem` + `agenix`)**:
  - **Script Factory (`scripts/default.nix`)**: Wraps `pkgs.writeShellApplication` with typed `enable` + `readOnly` `package` options and `lib.pipe` filtering into `environment.systemPackages`.
  - **Host-Letter Scoping (`hosts/registry.nix`, `lib/default.nix`)**: `clib.mkWhen` / `clib.mkEn` / `clib.mkPer` with duplicate-letter and unknown-host assertions.
