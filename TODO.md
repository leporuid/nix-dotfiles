# TODO

## Completed

- [x] Add `.github/workflows/ci.yml` with Determinate `nix-eval-jobs` and `NIX_SECRETS_SSH_KEY` support (`webfactory/ssh-agent`).
- [x] Include `nixpkgs#nixfmt` in the CI `Format and Lint` step (`fa8e49a`).
- [x] Fix `packages/comview.nix` FOD hash mismatch by pinning commit `8508f29ddcdf8dd8a93e93e2d7b0b940c31b6ab8` (`b15ad91`).
- [x] Configure `hosts/nixos-vm` user `leporuid` and import `modules/nixos`.
- [x] Complete post-reboot Darwin & Determinate Nix verification (`external-builders` disabled, Ghostty `XDG_CONFIG_HOME`, Nushell config dir, `BAT_THEME`).
- [x] Remove `accept-flake-config` and redundant `mac-app-util` input/module (`b2c39b1`).
- [x] Configure `hosts/nixos` (`aarch64-linux`) as remote builder on `MacBook-Pro`, switch macOS `UserShell` to `/run/current-system/sw/bin/zsh` (bootstrapping `fish` via `.zshrc` with `unsetopt nomatch`), and document reference repo patterns (`8ca81d3`).
- [x] Configure single-line `[profiles] nu` in `config/starship.toml` and `modules/hjem/starship.nix` (`7748d87`), remove stale `~/.config/nushell/vendor/autoload/starship.nu` backup, and verify generated Nushell prompt output (`"✶⎪⌽⎪◎ "` / `"⌂ /󰲋 "`).
- [x] Pin mutable branch `rev`s in remaining `packages/*.nix` (`kumono.nix` + `pkg-config`/`aws-lc` for `aws-lc-sys`, `schemat.nix`, `unxip.nix`, `cktool.nix`, `age-plugin-se/default.nix`) and verify package builds.
- [x] Push `main` to `origin/main` (`64e3026..eba9a71`).
- [x] Deploy `/Applications` apps with `rsync` (`mkAppSyncScript` in `lib/darwin.nix`, used by `modules/darwin/applications.nix`) (`626cd29`).
- [x] Port declarative Determinate module to `modules/darwin/determinate/` using local installer plists, and switch `system-defaults.nix` to `darwinModules.determinate` (`c9656b2`, `eba9a71`).
- [x] Trim `determinate` / `nixcord` transitive inputs via `follows` in `flake.nix` (kept `determinate/3`) (`c9656b2`).
- [x] Run `darwin-rebuild switch` after the Determinate port: nix-daemon runs from the new `determinate-nixd` store path, hook plist runs `/usr/bin/true`, `nix store info --store daemon` reports `2.35.3`, `Discord.app` and `M3U8DLProtocol.app` are real directories.
- [x] Reboot `MacBook-Pro` and confirm `/nix` mounts through `/usr/local/libexec/darwin/<name>/determinate-nixd` (`nix store info --store daemon` reports `2.35.3`, `/usr/local/libexec/darwin/...` is `0:0 0755`, `/etc/determinate/config.json` is `0:0 0644`).
- [x] Check GitHub Actions CI for `eba9a71` (run `43735739463` passed all 5 jobs).
- [x] Test building `nixosConfigurations.nixos-vm` from `MacBook-Pro` via the `nixos` remote builder (`ssh-ng://leporuid@nixos`).
- [x] Extend `check-links` in `run.fish` to compare NixOS host Hjem generations (`nixos`, `nixos-vm`) against the standalone manifest.
- [x] Add `dix` closure diff activation module (`modules/common/dix.nix`, wired into `darwinModules.aggregate` and `nixosModules.aggregate`); `hjemSchemas` unit tests already exist in `red-tape/tests/hjem.nix`.
- [x] Confirm the single-line Starship prompt interactively in Nushell.
- [x] Replace `flake-utils` with `nixpkgs.lib.genAttrs` in `ktoolbox` (`2943254`), run `nix flake update ktoolbox` (dropping `ktoolbox/flake-utils` and `ktoolbox/flake-utils/systems`), and sync `AGENTS.md` / `docs/*.md` before removing `~/Developer/refer`.
- [x] Confirm `~/Developer/nix-dotfiles-archive` is removed (already absent).
