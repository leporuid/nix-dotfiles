---
name: nix-dotfiles-workflow
description: Token-efficient workflow and architecture guardrails for Nix, nix-darwin, NixOS, hjem/hjem-rum, and red-tape/adios-flake repositories. Use whenever inspecting, editing, debugging, packaging, auditing, or rebuilding Nix configurations, flakes, devshells, or dotfiles.
---
# nix-dotfiles-workflow

## Summary

Enforce a token-minimal, high-precision workflow for maintaining `~/Developer/nix-dotfiles`: a flake built with `red-tape` (on `adios-flake`) and Determinate Nix, managing macOS (`nix-darwin`) and Linux (`NixOS`) with `hjem` + `hjem-rum` instead of Home Manager.

> `AGENTS.md` in the repository root is the source of truth. If this skill and `AGENTS.md` disagree, follow `AGENTS.md`.

## When to Use

- Inspecting, auditing, or tracking progress across Nix files (`flake.nix`, `devshell.nix`, `hosts/`, `modules/`, `packages/`, `users/`, `overlays/`, `lib/`, `config/`).
- Packaging custom derivations (`packages/*.nix`, e.g. `n-m3u8dl-re`, `m3u8dl-protocol/`, `vpn-pack/`).
- Troubleshooting `darwin-rebuild`, `nixos-rebuild`, `nix flake check`, `agenix`, or evaluation failures.
- Modifying dotfiles, shell integrations, hjem modules, or `config/` symlinks.

---

## 1. Strict Token-Limiting Guardrails (Highest Priority)

1. **Absolute ban on reading `flake.lock`**: never read or display it. Use `nix flake metadata` or a targeted `grep` for one input name.
2. **Cap command output**: Nix builds, evals, and checks can be huge. Redirect to a log and show only the tail, while preserving the exit status:
   ```bash
   nix flake check --no-write-lock-file >/tmp/check.log 2>&1; echo "exit=$?"; tail -n 40 /tmp/check.log
   ```
   Never judge success by `tail`/`head`; judge by the exit code.
3. **Search first, read narrowly**: use `rg`/`grep -rn` to locate targets, then read only the needed range (about ±20 lines). Never dump directories or whole files.
4. **In-place patching**: edit with surgical replacement tools; explain with short diffs and never reprint whole files.

---

## 2. Core Architecture Rules

1. **Git staging guardrail**: flakes only see tracked files. Run `git add` (or `git add -N <file>`) for new or deleted files before `nix flake check`, `nix eval`, or rebuilds. Stage only target files, never `git add -A` or `git add .`.
2. **red-tape discovery**: `red-tape.mkFlake` auto-discovers `hosts/`, `packages/`, `modules/`, `devshell.nix`, and `formatter.nix`. Keep `inherit self inputs;` and enable `inputs.red-tape.modules.redTape.darwin` and `.hjem` explicitly.
3. **Module headers follow `pedantix.toml`**: single-tier module functions with sorted arguments:
   - order: `self`, `inputs`, `config`, `lib`, `pkgs`, then alphabetical domain args (e.g. `perSystem`, `vars`), then `<defaulted>` args, then `...`.
   - Do not use curried two-stage headers.
4. **Top-level imports only**: never put `imports = [ ... ];` inside `config = lib.mkIf ... { }`.
5. **hjem, not Home Manager**:
   - Pass inputs with `hjem.specialArgs = { inherit inputs; };`.
   - Keep `hjem.clobberByDefault = true;`; use the `clobber` attribute, never the deprecated `force`.
   - Hjem modules must never generate empty or placeholder files.
   - Custom options live under `my.programs.<name>`; upstream hjem-rum modules under `rum.programs.<name>`.
   - `rum.programs.<name>` writes to `xdg.config.files`, so the tool must read `~/.config`. On Darwin this relies on `environment.variables.XDG_CONFIG_HOME` in `modules/darwin/system-defaults.nix`.
6. **Raw configs stay raw**: keep application configs in `config/` and map them via `my.config.source`. `my.config.useOutOfStoreSymlinks = isDarwin;` gives live edits on macOS without rebuilds; Linux uses pure store paths. Do not rewrite raw files into generated module options unless asked.
7. **Platform-only links**: GUI and macOS-only configs (`zed`, `kitty`, `foot`, `btt`, `raycast`, ...) belong in the `lib.optionalAttrs isDarwin` block of `users/leporuid/home-configuration.nix`, not in the shared set that headless NixOS also receives.
8. **Platform split**:
   - macOS (`hosts/MacBook-Pro`): `nix-darwin` + hjem, Fish login shell, `nix.enable = false;` (Determinate daemon), `directory = "/Users/leporuid";`, `config.system.primaryUser` as the trusted user.
   - NixOS (`hosts/nixos`): `bashInteractive` login shell chaining to Nushell, `mutableUsers = false`, root locked, SSH keys only, `trusted-users` limited to root and the primary user (never broad `@wheel`).
   - `hosts/nixos-vm` is a minimal VM and does not import hjem yet (see `TODO.md`).
9. **Experimental features**: NixOS uses `nix.settings.experimental-features`; Darwin uses `determinateNix.customSettings` where `extra-experimental-features` is allowed. Keep only essentials (`nix-command`, `flakes`, `parallel-eval`).
10. **State versions**: never bump `system.stateVersion` to a future release. Keep the value pinned at host creation.
11. **Modern Nix CLI only**: `nix profile wipe-history`, `nix store gc --verbose`, `nix store optimise --verbose`, `nix top`, `nix ps`. Never `nix-env` or `nix-collect-garbage`.

---

## 3. Secrets & SSH Keys

- Private material lives in the separate `nix-secrets` flake input (`git+ssh://git@github.com/leporuid/nix-secrets.git`). Public repos must not carry device key files.
- `modules/common/vars.nix` builds `sshKeyFiles` from `inputs.nix-secrets` (`keys/*.pub`, `sshKeys`, `authorizedKeys`). Keep `inputs.nix-secrets.sshKeys` (the hardware SK keys from `sshid.io`); it is not a duplicate of `authorized_keys.pub`.
- After changing `nix-secrets`: commit and push it first, then run `nix flake update nix-secrets` here.
- NixOS is key-only: before deploying changes that touch keys, confirm a remaining key can still log in.
- `age-plugin-se` requires `agenix` built with `age`, not `rage` (see `devshell.nix`).

---

## 4. Verification Matrix

| Changed paths | Required before commit or push |
| :--- | :--- |
| `*.nix`, `flake.lock`, `hosts/`, `users/`, `modules/`, `packages/` | `nix fmt`, `nix flake check --no-write-lock-file`, and host evals `darwinConfigurations.MacBook-Pro` and `nixosConfigurations.nixos` |
| only `config/**` | nothing on macOS (live symlinks); no rebuild required |
| new or deleted files referenced by Nix | `git add` first, then evaluate |

Fast host evaluation (derivation only, no build):

```bash
nix eval --raw .#darwinConfigurations.MacBook-Pro.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
```

Or use the devshell `run` wrapper (`run.fish`): `check-host`, `build-host`, `switch-host` for the current host, and `check-nixos`, `check-MacBook-Pro` per host. `nix flake check` only covers the current system by default (`--all-systems` for the rest).

Lint and format tools: `nix fmt` (treefmt: nixfmt, deadnix, statix, fish_indent, shfmt, taplo, yamlfmt) and `pedantix --check`.

---

## 5. Tooling, Packaging & Hardening Gotchas

1. **Custom packages**: put derivations in `packages/<name>.nix` and consume them via `inputs.self.packages.<system>.<name>` or `perSystem.self.<name>`. Keep the native Objective-C implementation of `packages/m3u8dl-protocol/main.m`. When skipping failing upstream tests, use `.overrideAttrs (_: { doCheck = false; doInstallCheck = false; })` with an English comment.
2. **Homebrew** (`modules/darwin/applications.nix`): keep `homebrew.onActivation.autoUpdate = false; upgrade = false; cleanup = "none";`, avoid `--force-cleanup` and `--zap`, and handle `config.homebrew.taps` entries as sets (`builtins.attrNames` or `.name`) to avoid `cannot coerce a set to a string`.
3. **Oracle NixOS hardening**: UDP `41641` open for Tailscale, SSH `ClientAliveInterval = 60`, Fail2ban `ignoreIP = [ "100.0.0.0/8" ]`, and never advertise `169.254.169.254` over Tailscale.
4. **Determinate Nix**: Darwin has `nix.enable = false;`. NixOS must not define its own `nix.gc` (Determinate manages GC); only `nix.optimise.automatic` is kept. `determinate-nixd` telemetry stays disabled.
5. **Devshell**: never add a second `nix` binary to `PATH` (wrap `nixos-rebuild-ng` via `perSystem.self.nixos-rebuild`, not `pkgs.nixos-rebuild`).
6. **Disks**: ext4 root uses `noatime` and `nodiscard` with a weekly `fstrim`.

---

## 6. Communication & Code Standards

- All code comments, terminal messages, and commit messages: clean English.
- Explanations to the user: concise Traditional Chinese (Taiwan usage).
- Verify locally before declaring success; trust only exit codes.
- Ambient authorization: once the user grants permission in a session, routine in-folder operations (reads, in-place patches, git staging, local evaluation, commits) need no repeat confirmation. Pushes, force operations, deletions outside the repo, and `switch` on the user's machine need an explicit request.
- Git: stage specific files, review `git status --short`, write Conventional Commits, and split unrelated changes into separate commits.
