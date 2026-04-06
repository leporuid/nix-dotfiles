# leporuid's configuration

This is my dead-simple configuration, based on [clo4](https://github.com/clo4/nix-dotfiles)'s configuration and powered by [red-tape](https://github.com/phaer/red-tape).

## Usage

### Apply the configuration

```bash
darwin-rebuild switch --flake .#MagiHoHo
```

### Update flake inputs

```bash
nix flake update
```

### Enter development shell

```bash
nix develop
```

## Migration notes (blueprint → red-tape)

This flake was migrated from [blueprint](https://github.com/leporuid/blueprint/tree/generic-users) to [red-tape](https://github.com/phaer/red-tape).

After cloning or pulling new changes that update `flake.nix` inputs, run:

```bash
nix flake update
darwin-rebuild switch --flake .#MagiHoHo
```
