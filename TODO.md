# TODO

## CI

- [x] Add `.github/workflows/` to run `nix flake check` and host evaluation for `darwinConfigurations.MacBook-Pro` and `nixosConfigurations.nixos`.
- [x] Adopt Determinate `nix-eval-jobs` (`flakehub.com/f/DeterminateSystems/nix-eval-jobs/3`) for parallel evaluation once CI exists.
- [x] Decide how CI accesses the private `nix-secrets` input (`git+ssh://git@github.com/leporuid/nix-secrets.git`) (read-only deploy key on `nix-secrets` + `NIX_SECRETS_SSH_KEY` secret in `nix-dotfiles` via `webfactory/ssh-agent`).

## hosts/nixos-vm

- [x] Define `users.users.leporuid` in `hosts/nixos-vm/configuration.nix` (currently only `services.getty.autologinUser = "root"`).
- [x] Import `../../modules/nixos` to test the full Hjem environment in the VM.

## Post-reboot verification (after `darwin-rebuild switch` at c310995)

- [x] `nix config show | grep experimental-features` no longer lists `external-builders` (fixed via `determinateNixd.builder.state = "disabled"` plus `sudo launchctl kickstart -k system/systems.determinate.nix-daemon`).
- [x] In a fresh Ghostty window, `echo $XDG_CONFIG_HOME` should print `/Users/leporuid/.config`.
- [x] `nu -c 'print $nu.default-config-dir'` should print `~/.config/nushell`, and the prompt, atuin, and carapace should load.
- [x] `echo $BAT_THEME` in Nushell should be `Catppuccin Mocha`.

## Push

- [x] Push local commits `74380df` (skills and AGENTS.md alignment) and `c310995` (Determinate trim) to `origin/main`.

## Optional follow-ups

- [x] Reconsider `accept-flake-config = true` in `modules/common/vars.nix` (removed; this flake's caches already live in `customSettings`).
