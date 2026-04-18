# leporuid's configuration

This is my dead-simple configuration, inspired by [clo4](https://github.com/clo4/nix-dotfiles)

## Structure

```
.
├── flake.nix            # Unified flake: inputs, packages, darwinConfigurations, devShell
├── run.fish             # Task runner (source of truth for all commands)
├── hosts/               # Host-specific configurations
├── modules              # Shared NixOS/nix-darwin/home-manager modules
├── packages/            # Custom package derivations
├── users/               # Per-user home configurations
└── config/              # Dotfiles linked into $HOME
```

