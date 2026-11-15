---
name: nix-dotfiles-workflow
description: Token-efficient workflow and architecture guardrails for Nix, nix-darwin, NixOS, hjem/hjem-rum, and red-tape/adios-flake repositories. Use whenever inspecting, editing, debugging, packaging, auditing, or rebuilding Nix configurations, flakes, devshells, or dotfiles.
---
# nix-dotfiles-workflow

## Summary

Enforce a token-minimal, high-precision workflow for maintaining `~/Developer/nix-dotfiles`: a flake built with `leporuid/red-tape` (on `adios-flake`), `flake-schemas`, and Determinate Nix, managing macOS (`nix-darwin`), Linux (`NixOS`), and UniFi OS (`system-manager`) with `hjem` + `hjem-rum` instead of Home Manager.

> `AGENTS.md` in the repository root is the source of truth. If this skill and `AGENTS.md` disagree, follow `AGENTS.md`.

## When to Use

  - Inspecting, auditing, or tracking progress across Nix files (`flake.nix`, `devshell.nix`, `formatter.nix`, `treefmt.nix`, `hosts/`, `modules/`, `packages/`, `users/`, `overlays/`, `lib/`, `config/`).
  - Packaging custom derivations (`packages/*.nix`, e.g. `n-m3u8dl-re`, `m3u8dl-protocol/`, `vpn-pack/`).
  - Troubleshooting `darwin-rebuild`, `nixos-rebuild`, `nix flake check`, `agenix`, or evaluation failures.
  - Modifying dotfiles, shell integrations, hjem modules, or `config/` symlinks.

## 1. Strict Token-Limiting Guardrails (Highest Priority)

1.  **Absolute ban on reading `flake.lock`**: never read or display it. Use `nix flake metadata` or a targeted `grep` for one input name.
2.  **Cap command output**: Nix builds, evals, and checks can be huge. Redirect to a log and show only the tail, while preserving the exit status: `nix flake check --no-write-lock-file >/tmp/check.log 2>&1; echo "exit=$?"; tail -n 40 /tmp/check.log` Never judge success by `tail`/`head`; judge by the exit code.
3.  **Search first, read narrowly**: use `rg`/`grep_search` to locate targets, then read only the needed range (+/- 20 lines). Never dump directories or whole files.
4.  **In-place patching**: edit with surgical replacement tools; explain with short diffs and never reprint whole files.

## 2. Core Architecture Rules

1.  **Git staging guardrail**: flakes only see tracked files. Run `git add` (or `git add -N <file>`) for new or deleted files before `nix flake check`, `nix eval`, or rebuilds. Stage only target files, never `git add -A` or `git add .`.
2.  **red-tape discovery**: `red-tape.mkFlake` auto-discovers `hosts/`, `users/`, `packages/`, `modules/`, `devshell.nix`, and `formatter.nix`. Keep `inherit inputs self;` and enable `inputs.red-tape.modules.redTape.darwin` and `.hjem` explicitly. `red-tape` natively provides `hjemConfigurations`, `hjemModules`, `rumModules`, `schemas`, and `hjemSchemas`.
3.  **Host Module Imports**: Custom modules (e.g., `modules/nixos/*.nix`) are not automatically applied by `red-tape` host discovery; they must be explicitly added to the `imports = [ ... ]` list in the host's `configuration.nix`.
4.  **Module headers follow `pedantix.toml`**: single-tier module functions with sorted arguments:
      - order: `self`, `inputs`, `config`, `lib`, `pkgs`, then alphabetical domain args (e.g. `perSystem`, `vars`), then `<defaulted>` args, then `...`.
      - Do not use curried two-stage headers.
5.  **Top-level imports only**: never put `imports = [ ... ];` inside `config = lib.mkIf ... { }`.
6.  **hjem, not Home Manager**:
      - Pass inputs with `hjem.specialArgs = { inherit inputs; };`.
      - Keep `hjem.clobberByDefault = true;`; use the `clobber` attribute, never the deprecated `force`.
      - Hjem modules must never generate empty or placeholder files.
      - Custom options live under `my.programs.<name>`; upstream hjem-rum modules under `rum.programs.<name>`.
      - `rum.programs.<name>` writes to `xdg.config.files`, so the tool must read `~/.config`. On Darwin this relies on `environment.variables.XDG_CONFIG_HOME` in `modules/darwin/system-defaults.nix`.
7.  **Raw configs stay raw**: keep application configs in `config/` and map them via `my.config.source`. `my.config.useOutOfStoreSymlinks = isDarwin;` gives live edits on macOS without rebuilds; Linux uses pure store paths. Do not rewrite raw files into generated module options unless asked.
8.  **Platform-only links**: GUI and macOS-only configs (`zed`, `kitty`, `foot`, `btt`, `raycast`, ...) belong in the `lib.optionalAttrs isDarwin` block of `users/leporuid/home-configuration.nix`, not in the shared set that headless NixOS also receives.
9.  **Platform split**:
      - macOS (`hosts/MacBook-Pro`): `nix-darwin` + hjem, `zsh` login shell (`UserShell`) bootstrapping Fish via `config/zsh/.zshrc` (`unsetopt nomatch` after handoff), `nix.enable = false;` (Determinate daemon), `directory = "/Users/leporuid";`, `config.system.primaryUser` as the trusted user, `nixos` remote builder.
      - NixOS (`hosts/nixos`): `bashInteractive` login shell chaining to Nushell, `mutableUsers = false`, root locked, SSH keys only, `trusted-users` limited to root and the primary user (never broad `@wheel`).
      - `hosts/nixos-vm`: imports `../../modules/nixos` and tests the full Hjem environment in VM.
      - Debian/UniFi OS (`hosts/unifi`): Managed via `numtide/system-manager` (`system-configuration.nix`), keeping `/nix` symlinked to `/data/nix` for firmware upgrade persistence.
10. **Experimental features**: NixOS uses `nix.settings.experimental-features = [ ... ]` (never `extra-`). Darwin uses `determinateNix.customSettings` where `extra-experimental-features` is allowed. Keep only essentials (`nix-command`, `flakes`, `parallel-eval`).
11. **State versions**: never bump `system.stateVersion` to a future release. Keep the value pinned at the stable version from host creation (e.g. `24.05` or `25.11`, never `26.11`).
12. **Modern Nix CLI only**: `nix profile wipe-history`, `nix store gc --verbose`, `nix store optimise --verbose`, `nix top`, `nix ps`. Never `nix-env` or `nix-collect-garbage`.

## 3. Secrets & SSH Keys

  - Private material lives in the separate `nix-secrets` flake input (`git+ssh://git@github.com/leporuid/nix-secrets.git`). Public repos must not carry device key files.
  - **Pure Evaluation**: Never use `curl` or `fetchurl` without hashes inside `.nix` files. To fetch remote plain text (like SSH keys from `sshid.io`), use a `flake = false` input in `flake.nix` or keep them in the private `nix-secrets` repository.
  - `modules/common/vars.nix` builds `sshKeyFiles` from `inputs.nix-secrets` (`keys/*.pub`, `sshKeys`, `authorizedKeys`). Keep `inputs.nix-secrets.sshKeys` (the hardware SK keys from `sshid.io`); it is not a duplicate of `authorized_keys.pub`.
  - After changing `nix-secrets`: commit and push it first, then run `nix flake update nix-secrets` here.
  - NixOS is key-only: before deploying changes that touch keys, confirm a remaining key can still log in.
  - `age-plugin-se` requires `agenix` built with `age`, not `rage` (see `devshell.nix`).

## 4. Verification Matrix

| Changed paths | Required before commit or push |
| :--- | :--- |
| `*.nix`, `flake.lock`, `hosts/`, `users/`, `modules/`, `packages/` | `nix fmt`, `nix flake check --no-write-lock-file`, and host evals `darwinConfigurations.MacBook-Pro` and `nixosConfigurations.nixos` |
| only `config/**` | nothing on macOS (live symlinks); no rebuild required |
| new or deleted files referenced by Nix | `git add` first, then evaluate |

Fast host evaluation (derivation only, no build):
`nix eval --raw .#darwinConfigurations.MacBook-Pro.config.system.build.toplevel.drvPath`
`nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath`

Or use the devshell `run` wrapper (`run.fish`): `check-host`, `build-host`, `switch-host` for the current host, and `check-nixos`, `check-MacBook-Pro` per host, plus `check-links --host {MacBook-Pro,nixos,nixos-vm}`. `nix flake check` only covers the current system by default (`--all-systems` for the rest).

Lint and format tools: `nix fmt` (treefmt: nixfmt, deadnix, statix, fish_indent, shfmt, taplo, yamlfmt) and `pedantix --check`.

## 5. Tooling, Packaging & Hardening Gotchas

1.  **Custom packages**: put derivations in `packages/<name>.nix` and consume them via `inputs.self.packages.<system>.<name>` or `perSystem.self.<name>`. Use `pkgs.lib.fileset.toSource` for local source whitelisting (`m3u8dl-protocol`, `has-ancestor`). Keep the native Objective-C implementation of `packages/m3u8dl-protocol/main.m`. When skipping failing upstream tests, use `.overrideAttrs (_: { doCheck = false; doInstallCheck = false; })` with an English comment.
2.  **.NET Builds**: If `buildDotnetModule` fails due to `.NET 10` incompatibilities (e.g. `error NU1201`), force `.NET 8` SDK/Runtime (`dotnet-sdk = dotnetCorePackages.sdk_8_0;`). If needed, use `sed` in `postPatch` to downgrade `<LangVersion>13.0</LangVersion>` to `12.0`.
3.  **Homebrew** (`modules/darwin/applications.nix`): keep `homebrew.onActivation.autoUpdate = false; upgrade = false; cleanup = "none";`, avoid `--force-cleanup` and `--zap`, and handle `config.homebrew.taps` entries as sets (`builtins.attrNames` or `.name`) to avoid `cannot coerce a set to a string`. Avoid `greedy = true` for everything to prevent unnecessary activation delays.
4.  **Oracle NixOS hardening**: UDP `41641` open for Tailscale, SSH `ClientAliveInterval = 60`, Fail2ban `ignoreIP = [ "100.0.0.0/8" ]`, and never advertise `169.254.169.254` over Tailscale.
5.  **Determinate Nix**: Darwin has `nix.enable = false;` with `modules/darwin/determinate/` (`determinateNix.enable = true;`). NixOS must not define its own `nix.gc` (Determinate manages GC); only `nix.optimise.automatic` is kept. `determinate-nixd` telemetry stays disabled (`determinateNixd.builder.state = "disabled"`). Use `nix run github:4evy/ndw#settings-current` to audit live macOS preferences for `modules/darwin/system-defaults.nix`.
6.  **Devshell**: never add a second `nix` binary to `PATH` (wrap `nixos-rebuild-ng` via `perSystem.self.nixos-rebuild`, not `pkgs.nixos-rebuild`).
7.  **Disks**: ext4 root uses `noatime` and `nodiscard` with a weekly `fstrim`.
8.  **SymlinkJoin Wrappers**: When wrapping packages (e.g., Neovim), use `nativeBuildInputs = [ pkgs.makeWrapper ]` instead of `buildInputs`.
9.  **Fish Completions**: Avoid massive derivation rebuilds by generating completions only for an explicit list of packages (e.g., `completionPackages = [ ... ]`), rather than mapping over all `home.packages`.
10. **Helix glibc collision**: Always use standard `pkgs.helix` from nixpkgs instead of the `helix` flake input to avoid `tree-sitter-perl` glibc compilation collisions.
11. **Home Manager Git Settings**: Use the modern `programs.git.settings` structure instead of deprecated root-level options (e.g., `userName`, `userEmail`).
12. **Fork Upstream Synchronization**: Use a `rebase` workflow to sync forks (e.g., `uv-pawchive`) with the upstream `master`/`devel` branch to prevent manual file copying and keep a clean commit history.

## 6. Communication & Code Standards

  - All code comments, terminal messages, and commit messages: clean English.
  - Explanations to the user: concise Traditional Chinese (Taiwan usage).
  - Verify locally before declaring success; trust only exit codes.
  - Ambient authorization: once the user grants permission in a session, routine in-folder operations (reads, in-place patches, git staging, local evaluation, commits) need no repeat confirmation. Pushes, force operations, deletions outside the repo, and `switch` on the user's machine need an explicit request.
  - Git: stage specific files, review `git status --short`, write Conventional Commits, and split unrelated changes into separate commits.
