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

## Next Session

- [ ] Push local `main` commits (`b15ad91`, `f6b6feb`, plus package pinning commits) to `origin/main`, then check GitHub Actions CI (`NIX_SECRETS_SSH_KEY` access to `nix-secrets`, `Format and Lint`, and `Flake Check and Host Eval`).
- [ ] Run `darwin-rebuild switch` (`run switch-host`) on `MacBook-Pro` so `~/.config/nushell/config.nu` activates the updated Hjem store path, and confirm the single-line Starship prompt interactively in Nushell.
- [ ] Test building `nixosConfigurations.nixos-vm` / `nixos` from `MacBook-Pro` via the `nixos` remote builder.
- [ ] Optional: extend `check-links` to compare NixOS host Hjem generations against the standalone manifest (normalizing `/nix/store/<hash>-config/...` paths and platform-specific file subsets).
- [ ] Optional: add `dix` closure diff (per `docs/REFERENCE_PATTERNS.md`) or `hjemSchemas` unit tests in `red-tape`.
- [ ] Optional: remove `~/Developer/nix-dotfiles-archive` and `~/Developer/refer` once everything is settled.
