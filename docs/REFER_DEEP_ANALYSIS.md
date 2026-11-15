# Deep Analysis of `~/Developer/refer` Repositories

Comprehensive architectural breakdown and pattern extraction across all 7 repositories under `~/Developer/refer/`, evaluated against `leporuid/nix-dotfiles` (`red-tape` + `adios-flake` + `Determinate Nix` + `Hjem` / `Hjem-Rum`).

---

## Executive Comparison Matrix

| Repository | Core Framework | Home Layer | Key Strengths | Adopt in `nix-dotfiles`? |
| :--- | :--- | :--- | :--- | :--- |
| **`4evy-dotfiles`** | `flake-parts` + `Just` + `Bun/TS` (`bun2nix`) | `feel-co/hjem` (standalone + per-platform) | Modular `Justfile` sub-modules (`just/*/*.just`), `hjem` standalone validation (`just hjem check`), `determinate-nixd` CLI recipes, clean `sops` / `renovate` / `bun2nix` packaging (`lib.fileset.toSource`) | **Selective**: `lib.fileset.toSource` packaging pattern, `just` task organization, and `hjem` standalone check ideas |
| **`cnix`** (`cnsta/cnix`) | `flake-parts` + `treefmt-nix` + `agenix` | `feel-co/hjem` + `nvf` | `clib` host-letter scoping (`clib.mkWhen`/`mkEn`/`mkPer`), `scripts/default.nix` `writeShellApplication` factory, `modules/settings/` matrix | **Optional**: `scripts/` factory & `clib` helpful if `hosts/` grows beyond 4–5 Linux servers |
| **`mikos-den`** (`sk4rd/mikos-den`) | `denful/den` + `import-tree` + `treefmt-nix` | `feel-co/hjem` | Dendritic aspect-per-feature (`den.aspects.<name>.{nixos,hjem}`), `virtualisation.vmVariant` test overrides, pure-data semantic `lib/theme/` | **Selective**: `vmVariant` test override pattern for `hosts/nixos-vm` & semantic theme helper structure |
| **`dotfiles`** (Skullheadx) | Raw `flake.nix` (`nix-darwin` + `nixosSystem`) | `feel-co/hjem` + `nvf` | Minimalist `hjem-darwin.nix` (`Library/Application Support/lazygit`), `programs.zsh` native options (`unsetopt nomatch` for `.#host` flake refs in Zsh!) | **Yes (Small Gem)**: `unsetopt nomatch` in `config/zsh/.zshrc` so `.#MacBook-Pro` never requires quoting in Zsh |
| **`nixfiles`** | Raw `flake.nix` (`nixosSystem`) | `feel-co/hjem` + `nixugen` | Clean `pkgs.formats.toml` generation for `helix/config.toml` & `helix/languages.toml` paired with `matugen` | **Reference**: Shows pure Nix-generated Helix config vs. our `config/helix` out-of-store symlink approach |
| **`nixugen`** | Minimal Flake (`overlays` + `hjemModules`) | `feel-co/hjem` | Runtime `matugen` wallpaper theming without Nix rebuilds; clean `hjemModules.default` + `overlays.default` | **Future**: Ready-to-use if migrating from static Soft Neon Violet to dynamic wallpaper theming |
| **`ai-native`** | `leporuid/blueprint` (`generic-users`) | Legacy | Historical personal `blueprint` starter (`431 B` `flake.nix`) | **No**: Superseded by `leporuid/red-tape` |
| **`rust`** | `rvolosatovs/nixify` | N/A | Minimal 3-line Rust flake template with `rust-toolchain.toml` | **Reference**: Useful only for standalone Rust repos |

---

## 1. `4evy-dotfiles` (`github:4evy/dotfiles`)

The largest and most engineering-heavy repository in `refer/` (from the author of `4evy/nixcord`).

### Architecture & Key Files
- **`flake.nix` & `nix/flake/outputs.nix`**: Uses `flake-parts` (`nix/flake/{darwin,nixos,hjem,lib,nixpkgs,packages}.nix`) with `determinate` pinned (`=3.24.2`), `4evy/ndw` (custom `nix-darwin` wrapper), `4evy/nixcord`, `4evy/ai`, `sops-nix`, `bun2nix`, and `treefmt-nix`.
- **Input Hygiene**: Explicitly zeroes out unused transitive inputs (`home-manager.follows = "";`, `nix-darwin.follows = "";`) to keep `flake.lock` lean and avoid redundant evaluations.
- **TypeScript + `bun2nix` (`package.nix`)**: Bundles Effect-native CLI/activation tools (`bun build --target=bun --minify`) using `lib.fileset.toSource` (strictly whitelisting only needed files instead of copying the entire repo into the store) and `makeBinaryWrapper`.
- **Modular `Justfile` (`just/*/*.just`)**: Splits operational workflows into `just/{bun,check,determinate,dotfiles,github,hjem,homebrew,nix,records,renovate,sops,spectrum}/*.just`:
  - `just/hjem/hjem.just`: Pre-renders and validates Hjem homes across `darwin`, `fedora`, and `nixos`, and updates `systemd --user` environment (`PATH`, `XDG_DATA_DIRS`, `MANPATH`, `INFOPATH`) on non-NixOS Linux standalone switches.
  - `just/determinate/determinate.just` & `fix.just`: Wraps `determinate-nixd status`, `sudo determinate-nixd upgrade` (asserting `!path_exists('/etc/NIXOS')` so NixOS upgrades go through `flake.lock`), and `determinate-nixd fix hashes` for fixing mismatched SRI/FOD hashes.
- **Standalone Hjem Builder (`nix/flake/hjem.nix`)**: Exposes `flake.lib.hjemHome`, `flake.lib.hjemConfiguration`, and `perSystem.packages.hjem-files`, separating public runtime JSON parameters from private host data.

### Takeaways for `nix-dotfiles`
1. **`lib.fileset.toSource` for Custom Packages**: In `packages/*.nix` (e.g., `m3u8dl-protocol`, `ktoolbox`), using `lib.fileset.toSource` guarantees clean, minimal build contexts even when `.DS_Store` or editor artifacts exist.
2. **Transitive Input Pruning**: Zeroing unused `follows = ""` on inputs like `nixcord` or `direnv-instant` (already partially done in `nix-dotfiles/flake.nix`) keeps evaluation fast.
3. **Declarative Determinate on macOS**: Unlike `4evy-dotfiles` (which relies on `sudo determinate-nixd upgrade` on macOS), `nix-dotfiles` manages `determinate-nixd` declaratively via `modules/darwin/determinate/` (`nix flake update determinate` + `darwin-rebuild switch`), while `determinate-nixd fix hashes` remains a useful CLI helper for SRI hash updates.
4. **Skip the Heavy Bun/TS Layer**: `4evy-dotfiles` relies on Bun/TypeScript scripts (`home/deploy/*.ts`) for orchestration; our `red-tape` + `run.fish` + `adios-flake` setup is already much lighter and pure-Nix.

---

## 2. `cnix` (`cnsta/cnix`)

A clean, multi-host NixOS desktop/homelab flake (`bunk`, `kima`, `sobotka`, `toothpc`, `ziggy`) built on `flake-parts` + `hjem` + `agenix` + `treefmt-nix`.

### Architecture & Key Files
- **`lib/default.nix` (`clib`) & `hosts/registry.nix`**: Defines a single-letter host registry (`k` = `kima`, `b` = `bunk`, `t` = `toothpc`, `s` = `sobotka`, `z` = `ziggy`) and helpers (`clib.mkWhen`, `clib.mkEn`, `clib.mkPer`) throwing explicit errors on duplicate letters or unknown host/scope letters.
- **`hosts/default.nix`**: Uses `inputs.nixpkgs.nixosModules.readOnlyPkgs` (`nixpkgs.pkgs = pkgs`) and binds `hjem.users.${user}` dynamically from `config.cnix.settings.accounts.username`.
- **`scripts/default.nix`**: Wraps `pkgs.writeShellApplication` with typed `enable` + `readOnly` `package` options, filtering enabled scripts via `lib.pipe` into `environment.systemPackages`.
- **`modules/settings/`**: Centralizes typed host-scoped settings (`accounts`, `boot`, `fonts`, `graphics`, `locale`, `monitors`, `network`, `nix`, `peripherals`, `theme`).

### Takeaways for `nix-dotfiles`
- Right now we have 3 hosts (`MacBook-Pro`, `nixos`, `nixos-vm`), so our 4-domain `modules/{common,darwin,nixos,hjem}/` layout is cleaner than single-letter host codes. If we ever expand to 4+ NixOS servers/homelabs, `clib.mkWhen` / `clib.mkEn` and the `scripts/default.nix` `writeShellApplication` factory are great patterns to adopt.

---

## 2B. `mikos-den` (`sk4rd/mikos-den`)

A dendritic NixOS + `feel-co/hjem` flake built on `denful/den` + `denful/import-tree` + `disko` + `agenix` + `treefmt-nix` (55-line `flake.nix` evaluating `./modules` via `evalModules`).

### Architecture & Key Files
- **Dendritic Aspect Features (`modules/features/*.nix`)**: Each feature file defines `den.aspects.<feature>.{nixos,hjem}` together (e.g., `common-utils.nix`, `syncthing.nix`, `yubikey.nix`, `proton-vpn-client.nix`) and registers into `den.schema.{host,user}.includes`.
- **VM Test Variant (`modules/features/nixos-testing-vm.nix`)**: Uses `virtualisation.vmVariant` to override normal user passwords to `"test"` and disable `age.secrets` when running `nixos-rebuild build-vm`, avoiding secret/SSH key setup during local VM tests.
- **Pure-Data Semantic Theme (`lib/theme/` & `lib/settings-type.nix`)**: Separates raw palette (`oxocarbon.nix`) from semantic roles (`colors.bg`, `colors.syntax.*`, `colors.diff.*`), keeps font packages as attribute paths, and provides color conversion helpers (`lib.rgb`, `lib.channels`).

### Takeaways for `nix-dotfiles`
1. **`virtualisation.vmVariant` for `hosts/nixos-vm`**: Useful if expanding `nixos-vm` for interactive `build-vm` testing without agenix secrets.
2. **Keep `red-tape` 4-Domain Split**: `den` + `import-tree` is a full dendritic paradigm shift; our `red-tape` + `modules/{common,darwin,nixos,hjem}` split already achieves cross-platform sharing cleanly with simpler tooling.

---

## 3. `dotfiles` (Skullheadx)

A compact, Suckless-inspired multi-OS flake (`x86_64-linux` NixOS + `aarch64-darwin` `nix-darwin`) using raw `flake.nix` + `hjem` + `nvf`.

### Architecture & Key Files
- **`flake.nix`**: Directly wires `hjem.nixosModules.default` and `hjem.darwinModules.default` with `specialArgs = { inherit inputs ips username; }`.
- **`hjem-darwin.nix`**: Maps macOS-specific paths cleanly via `hjem.users.${username}.files` (including `"Library/Application Support/lazygit/config.yml"` and `".gnupg/gpg-agent.conf"`).
- **`common-darwin.nix` & `zsh-darwin.nix`**:
  - Sets `unsetopt nomatch` in Zsh (`interactiveShellInit`) so Nix flake references containing `#` (such as `.#MacBook-Pro`) pass through literally without Zsh globbing errors!
  - Uses `system.keyboard` (`remapCapsLockToEscape`, `swapLeftCtrlAndFn`) and `sudo.extraConfig` (`Defaults timestamp_timeout=60`).

### Takeaways for `nix-dotfiles`
- **Adopt `unsetopt nomatch` in `config/zsh/.zshrc`**: Since `MacBook-Pro` now uses `zsh` as its login shell (`UserShell`), adding `unsetopt nomatch` prevents `zsh: no matches found: .#MacBook-Pro` whenever running `darwin-rebuild` or `nix` commands directly inside `zsh`.

---

## 4. `nixfiles` & 5. `nixugen`

- **`nixfiles`**: Minimalist NixOS flake (`cv01`, `tetobook`) combining `disko`, `agenix`, `hjem`, `chaotic-nyx`, and `nixugen`. Its `modules/hjem/helix.nix` demonstrates generating both `helix/config.toml` and `helix/languages.toml` purely with `pkgs.formats.toml { }` (wiring `nixfmt`, `rustfmt`, `rumdl`, and `theme = "matugen"`).
- **`nixugen` (`pyndys/nixugen`)**: Exposes `hjemModules.default` (`programs.matugen`) and `overlays.default` (`pkgs.matugenTemplates`). Rather than baking colors at Nix build time, `matugen` runs at runtime against a wallpaper and writes `~/.config/matugen/config.toml` via `pkgs.formats.toml`.
- **Takeaway for `nix-dotfiles`**: Keep our `my.config.useOutOfStoreSymlinks = isDarwin;` for `config/helix` (live edits on macOS) and static `Soft Neon Violet` in Ghostty; if we ever want dynamic wallpaper-based terminal colors, `nixugen` plugs directly into `hjem` with ~10 lines.

---

## 6. `ai-native` & 7. `rust`

- **`ai-native`**: An obsolete `leporuid/blueprint/generic-users` starter (`flake.nix` = 431 B). Fully superseded by `leporuid/red-tape` + `leporuid/nix-dotfiles`.
- **`rust`**: A 3-line `rvolosatovs/nixify` flake wrapping `Cargo.toml` + `rust-toolchain.toml`. Useful as a standalone template for future Rust projects, not needed inside `nix-dotfiles`.
