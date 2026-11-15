---
name: nixos-cloud-deploy
description: Pre-flight auditing, dry-run evaluation, and zero-lockout deployment workflow for NixOS servers (Oracle Cloud ARM A1 aarch64-linux and local VMs) using nixos-anywhere, disko, Determinate Nix, Hjem, Tailscale, and iroh-ssh. Use whenever preparing, testing, auditing, or executing NixOS deployments, VM builds, remote builder setups, or remote nixos-rebuild operations.
---
# nixos-cloud-deploy

## Summary

Provide a zero-lockout pre-flight verification, remote-builder integration, and deployment workflow for `hosts/nixos` (Oracle Cloud ARM A1 `aarch64-linux`) and `hosts/nixos-vm` in `~/Developer/nix-dotfiles`.

## When to Use

- Auditing or modifying `hosts/nixos/configuration.nix`, `hosts/nixos/disk-config.nix`, `hosts/nixos/hardware-configuration.nix`, or `modules/nixos/*.nix`.
- Running pre-flight dry-run evaluations (`toplevel.drvPath`, `hjemConfigurations`) or building `aarch64-linux` derivations from `MacBook-Pro` via the `nixos` remote builder.
- Provisioning or re-provisioning Oracle Cloud ARM A1 instances with `nixos-anywhere` or updating running hosts via `nixos-rebuild`.
- Troubleshooting remote SSH/Tailscale/iroh-ssh connectivity, Determinate Nixd GC/fstrim (`nodiscard`), or cross-platform Hjem user manifests on Linux.

## Steps

### 1. Pre-Flight Cross-Platform Evaluation (From macOS)

Before building or deploying to `aarch64-linux`, evaluate the derivation graph locally on macOS to catch module, option, or secret path errors:

1. Verify `flake.nix` points `red-tape` to `github:leporuid/red-tape` (never a local macOS `path:`).
2. Evaluate the production NixOS system, VM, and standalone Hjem manifest:

```fish
cd ~/Developer/nix-dotfiles
nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.nixos-vm.config.system.build.toplevel.drvPath
nix eval .#hjemConfigurations.leporuid.manifest --json | head -n 30
```

3. Verify the `MacBook-Pro` -> `nixos` remote builder link over Tailscale:

```fish
sudo nix store info --store "ssh-ng://leporuid@nixos?ssh-key=/etc/ssh/ssh_host_ed25519_key"
```

### 2. Zero-Lockout & Determinate Nix Audit

Before running `nixos-rebuild switch` or `nixos-anywhere` on `hosts/nixos`:

- **Dual Remote Access**: Confirm `services.openssh.enable = true` (with `vars.sshKeyFiles` from `nix-secrets`), `services.tailscale.enable = true` (`trustedInterfaces = [ "tailscale0" ]`, Fail2ban `ignoreIP = [ "100.0.0.0/8" ]`), and `iroh-ssh` are active.
- **Determinate Nix Best Practices**:
  - Let `determinate-nixd` handle GC (`garbageCollector.strategy = "automatic"`, telemetry `sentry.endpoint = null` in `/etc/determinate/config.json`) — never add a duplicate `nix.gc` timer.
  - Keep `nodiscard` + `noatime` on ext4 `/` in `disk-config.nix` paired with weekly `services.fstrim` (prefer `--minimum 1M` to reduce block-device discard overhead).
- **Hjem Pure Store Fallback**: Ensure `my.config.useOutOfStoreSymlinks = isDarwin;` is active so Linux hosts resolve pure `/nix/store` paths without needing `~/Developer/nix-dotfiles` cloned locally.
- **Diagnostics**: To profile slow builds or remote builder spans without editing config, set `NIX_DEBUG_OTEL=1` with `OTEL_EXPORTER_OTLP_ENDPOINT`.

### 3. Deployment Execution

- **Initial Provisioning (`nixos-anywhere`)**:

```fish
nix run .#nixos-anywhere -- --flake ~/Developer/nix-dotfiles#nixos root@<TARGET_IP>
```

- **Live System Update (`nixos-rebuild`)**:

```fish
nixos-rebuild test --flake ~/Developer/nix-dotfiles#nixos \
  --target-host leporuid@nixos \
  --build-host leporuid@nixos \
  --use-remote-sudo
```

Once `test` succeeds and SSH/Tailscale remain responsive, promote to `switch`.

## Gotchas

- **Oracle Cloud VNIC MTU**: Only set `MTUBytes = "9000"` on the primary VNIC when Jumbo Frames are supported by the subnet; keep Tailscale tunnel MTU intact.
- **Never Commit Unencrypted Secrets**: Verify `nix-secrets` (`sshKeys`, `authorizedKeys`, `tailscale-oracle.age`) is pushed before updating `nix-dotfiles`.
