# TODO

## CI

- [ ] Add `.github/workflows/` to run `nix flake check` and host evaluation for `darwinConfigurations.MacBook-Pro` and `nixosConfigurations.nixos`.
- [ ] Adopt Determinate `nix-eval-jobs` (`flakehub.com/f/DeterminateSystems/nix-eval-jobs/3`) for parallel evaluation once CI exists.
- [ ] Decide how CI accesses the private `nix-secrets` input (`git+ssh://git@github.com/leporuid/nix-secrets.git`).

## hosts/nixos-vm

- [ ] Define `users.users.leporuid` in `hosts/nixos-vm/configuration.nix` (currently only `services.getty.autologinUser = "root"`).
- [ ] Import `../../modules/nixos` to test the full Hjem environment in the VM.
