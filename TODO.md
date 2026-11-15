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

## Next Session

- [ ] Pin mutable branch `rev`s in remaining `packages/*.nix` (resolving the second CI FOD mismatch in `kumono.nix`), verify builds + `nix fmt` + `nix flake check --no-write-lock-file` + host evals, and commit:
  - `packages/kumono.nix`: `rev = "9024bc9bee36c9d6ddf97b3516fcdfcf1f124526"`, `hash = "sha256-jZquLkvYQz0RM2oJBmMMGJW56/w+yaPnPEdhCvCt1u0="`, `cargoHash = "sha256-4uWdzPK3ER/ckdnIhDHm6FSzWTHr9/dagQ4ZyukJb9w="` (run `nix build .#packages.aarch64-darwin.kumono` to confirm).
  - `packages/schemat.nix`: `rev = "9f1355f6cb16fa67232d5d48347d4fe80407bca5"` (matches current `hash`; or update to `a0b0031c5bf6e1d4e2dc2fdd0f55b61a5b77be61` + `sha256-LpcgQU32KCtFGhRhHyh9k8itdooWS6qhr3G6fUsmixk=` and verify `cargoHash`).
  - `packages/unxip.nix`: `rev = "6c3990517fcc4c1db6952fccf4c562fb14097601"` (matches current `hash`; or update to `3182d078f302399700d0d4941dd555bbb3c6af04` + `sha256-jFChmKUA7+obHkZnd7ZpqeejZfeA+gTUELo1iYeFMFo=`).
  - `packages/cktool.nix`: `rev = "1c999a1cbe17477d04970d3657f6ecfa9478f56f"` (matches current `hash`).
  - `packages/age-plugin-se/default.nix`: `rev = "6a01275884604dada06d9ec5d84085448841eaca"` (matches current `hash`).
- [ ] Push local `main` commits (`b15ad91`, `f6b6feb`, plus package pinning commits) to `origin/main`, then check GitHub Actions CI (`NIX_SECRETS_SSH_KEY` access to `nix-secrets`, `Format and Lint`, and `Flake Check and Host Eval`).
- [ ] Run `darwin-rebuild switch` (`run switch-host`) on `MacBook-Pro` so `~/.config/nushell/config.nu` activates the updated Hjem store path, and confirm the single-line Starship prompt interactively in Nushell.
- [ ] Test building `nixosConfigurations.nixos-vm` / `nixos` from `MacBook-Pro` via the `nixos` remote builder.
- [ ] Optional: extend `check-links` to compare NixOS host Hjem generations against the standalone manifest (normalizing `/nix/store/<hash>-config/...` paths and platform-specific file subsets).
- [ ] Optional: add `dix` closure diff (per `docs/REFERENCE_PATTERNS.md`) or `hjemSchemas` unit tests in `red-tape`.
- [ ] Optional: remove `~/Developer/nix-dotfiles-archive` and `~/Developer/refer` once everything is settled.
