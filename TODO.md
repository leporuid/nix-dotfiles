# TODO

## Completed

- [x] Add `.github/workflows/ci.yml` with Determinate `nix-eval-jobs` and `NIX_SECRETS_SSH_KEY` support (`webfactory/ssh-agent`).
- [x] Include `nixpkgs#nixfmt` in the CI `Format and Lint` step (`fa8e49a`).
- [x] Fix `packages/comview.nix` FOD hash mismatch by pinning commit `8508f29ddcdf8dd8a93e93e2d7b0b940c31b6ab8`.
- [x] Configure `hosts/nixos-vm` user `leporuid` and import `modules/nixos`.
- [x] Complete post-reboot Darwin & Determinate Nix verification (`external-builders` disabled, Ghostty `XDG_CONFIG_HOME`, Nushell config dir, `BAT_THEME`).
- [x] Remove `accept-flake-config` and redundant `mac-app-util` input/module (`b2c39b1`).
- [x] Configure `hosts/nixos` (`aarch64-linux`) as remote builder on `MacBook-Pro`, switch macOS `UserShell` to `/run/current-system/sw/bin/zsh` (bootstrapping `fish` via `.zshrc` with `unsetopt nomatch`), and document reference repo patterns (`8ca81d3`).
- [x] Configure single-line `[profiles] nu` in `config/starship.toml` and `modules/hjem/starship.nix` (`7748d87`), remove stale `~/.config/nushell/vendor/autoload/starship.nu` backup, and verify generated Nushell prompt output (`"✶⎪⌽⎪◎ "` / `"⌂ /󰲋 "`).

## Next Session

- [ ] Confirm GitHub Actions CI has `NIX_SECRETS_SSH_KEY` configured to access private `nix-secrets`.
- [ ] Test building `nixosConfigurations.nixos-vm` / `nixos` from `MacBook-Pro` via the `nixos` remote builder.
- [ ] Run `darwin-rebuild switch` (`run switch-host`) on `MacBook-Pro` so `~/.config/nushell/config.nu` activates the updated Hjem store path.
- [ ] Pin mutable branch `rev`s in remaining `packages/*.nix` to prevent future upstream FOD drift in CI:
  - `packages/kumono.nix`: `rev = "9024bc9bee36c9d6ddf97b3516fcdfcf1f124526"`, `hash = "sha256-jZquLkvYQz0RM2oJBmMMGJW56/w+yaPnPEdhCvCt1u0="`, `cargoHash = "sha256-4uWdzPK3ER/ckdnIhDHm6FSzWTHr9/dagQ4ZyukJb9w="`
  - `packages/schemat.nix`: `rev = "9f1355f6cb16fa67232d5d48347d4fe80407bca5"` (matches current `hash`)
  - `packages/unxip.nix`: `rev = "6c3990517fcc4c1db6952fccf4c562fb14097601"` (matches current `hash`)
  - `packages/cktool.nix`: `rev = "1c999a1cbe17477d04970d3657f6ecfa9478f56f"` (matches current `hash`)
  - `packages/age-plugin-se/default.nix`: `rev = "6a01275884604dada06d9ec5d84085448841eaca"` (matches current `hash`)
- [ ] Optional: extend `check-links` to compare NixOS host Hjem generations against the standalone manifest (normalizing `/nix/store/<hash>-config/...` paths and platform-specific file subsets).
- [ ] Optional: add `dix` closure diff (per `docs/REFERENCE_PATTERNS.md`) or `hjemSchemas` unit tests in `red-tape`.
- [ ] Optional: remove `~/Developer/nix-dotfiles-archive` and `~/Developer/refer` once everything is settled.
