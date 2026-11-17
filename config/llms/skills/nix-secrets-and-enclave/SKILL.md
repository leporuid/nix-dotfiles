---
name: nix-secrets-and-enclave
description: Security, agenix rules, Apple Secure Enclave (age-plugin-se), and SSH key lifecycle guide for ~/Developer/nix-secrets and secret consumers in nix-dotfiles. Use when editing agenix-rules.nix, adding/rekeying .age secrets, updating SSH keys in vars.nix, or configuring age vs rage binaries.
---
# Nix Secrets and Secure Enclave Lifecycle

Manages private `agenix` secrets in `~/Developer/nix-secrets` (`leporuid/nix-secrets`) and their consumers in `~/Developer/nix-dotfiles`.

> **Critical Security Rule**: Never decrypt `.age` secrets into agent output, never print private keys, and never store unencrypted secrets or device keys in `nix-dotfiles`.

## When to Use

- Adding, editing, or rekeying `.age` secrets in `~/Developer/nix-secrets`.
- Updating `~/Developer/nix-secrets/agenix-rules.nix`, `flake.nix`, or `keys/*.pub`.
- Modifying `nix-dotfiles/modules/darwin/agenix.nix`, `nix-dotfiles/modules/common/vars.nix`, `hosts/nixos/configuration.nix` (`age.*`), or `run.fish edit-age`.

## Architecture & Invariants

1. **`agenix-rules.nix` (Not `secrets.nix`)**:
   - `~/Developer/nix-secrets` uses `agenix-rules.nix` to declare recipient public keys (`MacBook-Pro-system.pub`, `MacBook-Pro-user.pub`, `MacBook-Pro-se.pub`, `nixos-system.pub`).
   - Always ensure `AGENIX_RULES="$PWD/agenix-rules.nix"` is exported when running `agenix` manually (or use `run.fish edit-age` from `nix-dotfiles`, which selects `.age` files via `fd` + `fzf` and sets `AGENIX_RULES`).

2. **`age` vs. `rage` Binary Trap**:
   - **Darwin (`devshell.nix`, `modules/darwin/agenix.nix`)**: Apple Secure Enclave (`age-plugin-se`, `MacBook-Pro-se.pub`) REQUIRES `pkgs.age` — `rage` lacks `age-plugin` support. Keep `ageBin = "${pkgs.age}/bin/age";` in `modules/darwin/agenix.nix` and the `agenix` override in `devshell.nix`.
   - **NixOS (`hosts/nixos/configuration.nix`)**: Headless Oracle server decrypts via `/etc/ssh/ssh_host_ed25519_key` (`pkgs.rage` / `age` without SE hardware), and `virtualisation.vmVariant` disables `age.secrets` for local VM testing.

3. **Pure Flake Evaluation & SSH Keys (`modules/common/vars.nix`)**:
   - Never use `curl` or unhashed `fetchurl` inside `.nix` files.
   - `nix-secrets/flake.nix` imports `https://sshid.io/leporuid/ECDSA-SK` as a `flake = false` input (`ssh-keys`) and exports `secrets`, `sshKeys`, and `authorizedKeys` (`keys/authorized_keys.pub`).
   - Keep `inputs.nix-secrets.sshKeys` in `vars.sshKeyFiles` alongside `keys/*.pub`; it provides hardware security keys and is NOT a duplicate of `authorized_keys.pub`.

## Safe Update & Sync Workflow

1. Edit or rekey inside `~/Developer/nix-secrets` (`agenix -e <secret>.age` or `run edit-age`).
2. Verify SSH lockout safety before modifying `authorized_keys.pub` or `vars.sshKeyFiles` (confirm at least one active key remains valid on `nixos`).
3. **Commit and push `~/Developer/nix-secrets` FIRST**, then run inside `~/Developer/nix-dotfiles`:
   ```fish
   nix flake update nix-secrets
   ```
4. Re-verify `darwinConfigurations.MacBook-Pro` and `nixosConfigurations.nixos` evaluations (`nix eval`) before committing `flake.lock` in `nix-dotfiles`.
