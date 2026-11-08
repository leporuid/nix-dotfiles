# GitHub Copilot Instructions (`nix-dotfiles`)

Always follow the repository-wide guidance in [`AGENTS.md`](../AGENTS.md). Keep changes
surgical, avoid dumping large files or build logs, and keep code comments in English.

## Development commands

Enter the development environment with `nix develop` (or let direnv activate it).
The shell provides the repository's `run` helper, Nix tooling, and validation tools.

### Nix configurations

```sh
nix flake check
nix eval --raw .#darwinConfigurations.MacBook-Pro.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
nix fmt
nix develop --command fish -c "run check-MacBook-Pro"
```

`run check-MacBook-Pro` builds the Darwin toplevel without activation. Use
`run build-host` for a linked build, `run switch-MacBook-Pro` to activate macOS,
and `run switch-nixos` to deploy the remote Oracle NixOS host. For changes under
`hosts/nixos` or the cloud profile, also run the NixOS evaluation above. Stage new
files with `git add` before any flake evaluation because Blueprint only sees tracked
files.

The CI-equivalent checks are `nix flake check` plus the two `nix eval` commands.
The formatter is configured in `treefmt.nix` and covers Nix, deadnix, statix, TOML,
Fish, and YAML. Individual checks available in the devshell include:

```sh
nix develop -c statix check
nix develop -c deadnix
nix develop -c actionlint
nix develop -c shellcheck path/to/script.sh
```

### VPN Pack manager

The Go backend is a separate module with a local `tailscale.com` replacement:

```sh
cd packages/vpn-pack/manager
go test ./...
go test ./service -run '^TestName$'
go build ./...
```

The Svelte/Vite UI has its own Node package:

```sh
cd packages/vpn-pack/manager/ui
npm ci
npm test
npm test -- src/lib/api.test.js
npm run build
```

## Architecture

- `flake.nix` delegates outputs to the repository's Blueprint fork. Shared values
  such as the user, host, paths, caches, and Nix settings are centralized in
  `modules/common/vars.nix`.
- macOS is composed from `hosts/MacBook-Pro`, nix-darwin, and Home Manager.
  `users/leporuid/home-configuration.nix` imports the shared cloud profile and
  applies both system and user configuration through the Darwin build.
- Oracle NixOS is a native, self-contained host under `hosts/nixos`; it does not
  use Home Manager. Its networking, Tailscale, SSH hardening, disko, and agenix
  setup are configured in the host module.
- `modules/darwin`, `modules/home`, and `modules/common` provide reusable modules.
  Cross-module imports use `inputs.self.*` Blueprint outputs. Custom derivations
  live under `packages/` and are exposed through per-system outputs.
- `config/` contains raw application configuration. Home Manager maps it through
  `my.config.source`; macOS uses out-of-store symlinks so edits affect the checkout
  directly. Preserve this model instead of duplicating settings as Nix options.
- `packages/vpn-pack` cross-compiles patched Tailscale and its Go manager for the
  target ARM platform. `packages/vpn-pack/manager.nix` builds the UI first and
  embeds `ui/dist` into the manager; if a verified `dist/index.html` exists, it
  is reused instead of rebuilding.

## Repository-specific conventions

- Modules in `modules/*` use the single-stage header pattern
  `{ inputs, pkgs, config, lib, vars, ... }: { ... }`; do not introduce the
  older curried/two-stage form.
- Keep the modern Nix 3 command style (`nix profile`, `nix store`, `nix flake`).
  Do not add a second Nix binary to the devshell; wrapper packages are used for
  `nixos-rebuild` and related commands.
- Keep encrypted age files and secret decryption outside derivations and the
  Nix store. macOS secrets rely on `age-plugin-se`; the private `nix-secrets`
  repository is referenced as an input.
- Do not generate Fish completions by scanning all of `home.packages`; use the
  explicit `completionPackages` option when generated completions are needed.
- Do not read or display `flake.lock`; use `nix flake metadata` for input details.
- On Linux CI, evaluate Darwin outputs only; do not attempt to build Darwin
  closures on an Ubuntu runner.