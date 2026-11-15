# External Reference Patterns (`~/Developer` Archive Notes)

Distilled architectural patterns and reusable Nix snippets extracted from local reference clones prior to cleanup.

---

## 1. `moni-dz/nix-config` (`moni-nixcfg`)

- **Closure Diff on Activation (`profiles/dix.nix`)**:
  - Run `dix diff --full --color=always /run/current-system "$systemConfig" >&2 || true` inside `system.activationScripts.preActivation.text` (Darwin) and `system.activationScripts.dix` with `supportsDryActivation = true` (NixOS) to inspect package upgrades on every rebuild. Already adopted in `modules/common/dix.nix`.
- **Darwin Nushell Path Mirroring (`modules/hjem/nushell-darwin.nix`)**:
  - When `XDG_CONFIG_HOME` is not inherited by GUI-launched tools on macOS, mirror `config.xdg.config.files."nushell/{config.nu,env.nu}".source` into `Library/Application Support/nushell/`.
- **Integration-Gated Hjem Modules (`modules/hjem/rex.nix`)**:
  - Expose `options.<ns>.integrations.<shell>.enable` toggles and compose conditional outputs with `lib.mkMerge` + `lib.mkIf`, ensuring empty derivations/files are never emitted.
- **Remote Builders (`profiles/remote-builders.nix`)**:
  - Use `ssh-ng://<user>@<host> <arch> <keyPath> <jobs> <speed> big-parallel,benchmark -` under `nix.settings.builders` (or `determinateNix.customSettings.builders` on macOS Determinate Nix). Already adopted in `hosts/MacBook-Pro/darwin-configuration.nix` for `nixos`.

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
