---
name: darwin-host-and-unifi-dev
description: Development and system engineering guide for macOS (hosts/MacBook-Pro, modules/darwin/, lib/darwin.nix) and UniFi OS cross-compiled packages (packages/vpn-pack/). Use when modifying nix-darwin modules, Determinate Nix daemon config, Darwin app rsync deployment, nix-homebrew, launchd daemons, or UniFi ARM64 vpn-pack builds.
---
# Darwin Host and UniFi Cross-Compile Dev

Maintains macOS system configuration (`hosts/MacBook-Pro`, `modules/darwin/`, `lib/`) and UniFi Dream Router cross-compiled packaging (`packages/vpn-pack/`) in `~/Developer/nix-dotfiles`.

> Consult `AGENTS.md` and `@nix-dotfiles-workflow` before editing `.nix` files.

## When to Use

- Editing `hosts/MacBook-Pro/darwin-configuration.nix`, `modules/darwin/*.nix`, `modules/darwin/determinate/`, `lib/darwin.nix`, `lib/nix-settings.nix`, or `lib/caches.nix`.
- Auditing macOS preferences, `launchd.daemons`, `nixcord`, `nix-homebrew` casks/taps, or `/Applications` sync behavior.
- Developing, patching, cross-compiling, or deploying `packages/vpn-pack/` (`vpn-pack-manager`, `tailscalePatched`, `deploy.nix`).

## macOS (`hosts/MacBook-Pro` & `modules/darwin/`)

1. **Declarative Determinate Nix (`modules/darwin/determinate/`)**:
   - Keep `nix.enable = false;` and `determinateNix.enable = true;`.
   - `determinate-nixd` is managed declaratively via `inputs.determinate` (copied to `/usr/local/libexec/darwin/` for boot-safe APFS `/nix` mounting) with `builder.state = "disabled"` and `garbageCollector.strategy = "automatic"` (sentry telemetry omitted in Determinate >= 3.24.3).
   - Upgrade via `nix flake update determinate` + host rebuild, never `sudo determinate-nixd upgrade`.
   - Shared Nix daemon settings come from `lib/nix-settings.nix` (`determinateNix.customSettings`), and `hosts/MacBook-Pro` builds `aarch64-linux` via the `nixos` remote builder (`ssh-ng://leporuid@nixos aarch64-linux /etc/ssh/ssh_host_ed25519_key 4 1 big-parallel,benchmark -`).

2. **Native `.app` Sync (`lib/darwin.nix` & `modules/darwin/applications.nix`)**:
   - Nix symlinks in `/Applications` break Finder/Spotlight/macOS bundle handling; `applications.nix` clears `/Applications/Nix Apps` and uses `lib.darwin.mkAppSyncScript` (`linkFarm` + `rsync --checksum --copy-unsafe-links --delete-delay --chmod=-w`) to sync real `.app` directories (`M3U8DLProtocol.app`, `Discord.app`).
   - Activation probes write permissions before syncing and removes stale top-level symlinks safely.

3. **Homebrew & `nixcord` Guardrails**:
   - Keep `homebrew.onActivation = { autoUpdate = false; upgrade = false; cleanup = "none"; }`; avoid `--force-cleanup` and `--zap`.
   - Convert `config.nix-homebrew.taps` with `builtins.attrNames` into `{ inherit name; trusted = true; }` objects to prevent set-to-string coercion errors.
   - Keep `nix-homebrew` shell integrations disabled (`enable{Fish,Zsh,Bash}Integration = false`).
   - `programs.nixcord` manages Discord + Vencord and links `~/.config/Vencord` into `~/Library/Application Support/Vencord` if absent.

4. **System Defaults & `launchd` (`modules/darwin/system-defaults.nix`)**:
   - Exports `XDG_CONFIG_HOME = "/Users/<primaryUser>/.config"` so XDG-aware CLI tools (including Nushell) align across Darwin and Linux.
   - Forces `environment.profiles` to exclude `~/.nix-profile`, sets `UserShell` to `pkgs.zsh` (handing off to Fish), enables `programs.fish.useBabelfish = true`, enables Touch ID `sudo_local` (`touchIdAuth = true; reattach = true;`), and declares `launchd.daemons` (`sysctl-ptmx` raising `kern.tty.ptmx_max=999`, weekly `apfs-purge`).
   - Audit live macOS preference drift on demand without adding flake inputs: `nix run github:4evy/ndw#settings-current` or `nix run github:sushydev/nix-plist-manager#current -- --against mac.nix`.

## UniFi OS Cross-Compiled Packaging (`packages/vpn-pack/`)

- **Target**: Cross-compiles `vpn-pack-manager` (Go, static `CGO_ENABLED=0`) and patched `tailscale` for `aarch64-linux` UniFi OS (`packages/vpn-pack/{default,manager,deploy,overlay}.nix`, `0001-unifi-nix-packaging.patch`).
- **Critical Runtime Workarounds (`deploy.nix`)**:
  - Persists under `/persistent/vpn-pack` so UniFi firmware upgrades do not wipe binaries/state.
  - Generates `tailscaled.service` (`StartLimitIntervalSec=0`) and `tailscaled.defaults` with `TS_TUN_DISABLE_TCP_GRO="1"` to prevent UniFi Cloud Gateway LAN TSO stalls on forwarded Tailscale traffic.
- **Build & Test**:
  - Verify cross-build from macOS or Linux via `nix build .#vpn-pack`.
  - Deployment wrapper lives in `run.fish` (`deploy-vpnpack <target>`) and `config/raycast/scripts/deploy-vpnpack-udr.fish`, consuming encrypted `nix-secrets/secrets/tailscale-unifi.age` at deploy time.

## Verification

- Format/lint: `nix fmt` and `pedantix --check`.
- Pure Darwin evaluation: `nix eval --raw .#darwinConfigurations.MacBook-Pro.config.system.build.toplevel.drvPath` + `check-links --host MacBook-Pro`.
- Build `vpn-pack`: `nix build .#vpn-pack --no-link` before committing changes under `packages/vpn-pack/`.
