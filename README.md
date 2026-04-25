# leporuid's configuration

This is my dead-simple configuration, inspired by [clo4](https://github.com/clo4/nix-dotfiles) and [nome](https://github.com/the-nix-way/nome).

## Structure

```
.
├── flake.nix            # Unified flake: inputs, packages, darwinConfigurations, devShell
├── run.fish             # Task runner (source of truth for all commands)
├── bootstrap.sh         # First-time setup
├── nix-darwin/          # Darwin system modules
├── home-manager/        # Home Manager modules
├── hosts/               # Host-specific configurations
├── modules/common/      # Shared NixOS/nix-darwin/home-manager modules
├── packages/            # Custom package derivations
├── users/               # Per-user home configurations
└── config/              # Dotfiles linked into $HOME
```

## Usage

### Bootstrap a new machine

```bash
./bootstrap.sh
```

### Enter development shell

```bash
nix develop
```

### Apply the configuration

```bash
run switch-host
```

Or directly:

```bash
darwin-rebuild switch --flake .#MagiHoHo
```

### Update flake inputs

```bash
nix flake update
```
