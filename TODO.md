# TODO

## CI

- [ ] Add `.github/workflows/` to run `nix flake check` and host evaluation for `darwinConfigurations.MacBook-Pro` and `nixosConfigurations.nixos`.
- [ ] Adopt Determinate `nix-eval-jobs` (`flakehub.com/f/DeterminateSystems/nix-eval-jobs/3`) for parallel evaluation once CI exists.
- [ ] Decide how CI accesses the private `nix-secrets` input (`git+ssh://git@github.com/leporuid/nix-secrets.git`).

## hosts/nixos-vm

- [ ] Define `users.users.leporuid` in `hosts/nixos-vm/configuration.nix` (currently only `services.getty.autologinUser = "root"`).
- [ ] Import `../../modules/nixos` to test the full Hjem environment in the VM.

## Post-reboot verification (after `darwin-rebuild switch` at c310995)

- [ ] `nix config show | grep experimental-features` should no longer list `external-builders`. If it still does, find where it is set (`determinate-nixd` vs `/etc/nix/nix.conf`).
- [ ] In a fresh Ghostty window, `echo $XDG_CONFIG_HOME` should print `/Users/leporuid/.config`.
- [ ] `nu -c 'print $nu.default-config-dir'` should print `~/.config/nushell`, and the prompt, atuin, and carapace should load.
- [ ] `echo $BAT_THEME` in Nushell should be `Catppuccin Mocha`.

## Push

- [ ] Push local commits `74380df` (skills and AGENTS.md alignment) and `c310995` (Determinate trim) to `origin/main`.

## Optional follow-ups

- [ ] Reconsider `accept-flake-config = true` in `modules/common/vars.nix` (accepts any flake `nixConfig` without prompting).
