# macOS & NixOS Configuration

A lightweight, modular, and convention-based Nix configuration primarily designed for macOS using [**nix-darwin**](https://github.com/nix-darwin/nix-darwin), with additional NixOS configurations for VPS deployments and Linux Builder experimentation.

Built with [**red-tape**](https://github.com/leporuid/red-tape), [**adios-flake**](https://github.com/Mic92/adios-flake), [**Hjem**](https://github.com/feel-co/hjem), and [**Hjem-Rum**](https://github.com/snugnug/hjem-rum).

This project uses a personal fork of red-tape, originally created by [Phaer](https://github.com/phaer/red-tape) and subsequently extended by [Otavio](https://github.com/otavio), with additional host-building improvements.

## Highlights

1. **Convention-Based Flake Architecture**
   - Uses [red-tape](https://github.com/leporuid/red-tape), built on top of [adios-flake](https://github.com/Mic92/adios-flake), to organize and generate flake outputs through filesystem conventions.
   - Keeps the root `flake.nix` focused on inputs and output composition while delegating project structure and configuration generation to red-tape.
   - Supports modular system configurations, development shells, packages, checks, formatters, and reusable modules.

2. **Home Manager-Free User Configuration**
   - Uses [Hjem](https://github.com/feel-co/hjem) as a native NixOS and nix-darwin module for declarative user environment management.
   - Uses [Hjem-Rum](https://github.com/snugnug/hjem-rum) for reusable program configuration modules (`programs.git`, `programs.fish`, etc.).
   - Integrates [Hjem-Impure](https://github.com/Rexcrazy804/hjem-impure) on macOS for out-of-store symlinking and live dotfile editing without rebuilding the system.
   - Eliminates the need for Home Manager while keeping user configurations modular and declarative.

3. **Multi-Platform Configuration**
   - **macOS (Primary):** Main daily-driver environment managed through nix-darwin.
   - **NixOS (VPS):** Server configuration managed through native NixOS modules.
   - **NixOS VM (Experimental):** A virtual machine used for testing and exploring NixOS-based Linux Builder setup.
   - Shares common user configurations through Hjem and Hjem-Rum while keeping platform-specific system configurations independent.

4. **Generic Users (`generic-users`)**
   - `users/leporuid/home-configuration.nix` serves as the central source of shared user configuration.
   - Host-specific user configurations under `hosts/<host>/users/leporuid/` connect shared settings to individual systems.
   - Minimizes duplicated configuration between macOS and Linux.

5. **Development Environment & Code Quality**
   - Uses [treefmt-nix](https://github.com/numtide/treefmt-nix) for declarative and reproducible code formatting.
   - Uses [git-hooks.nix](https://github.com/cachix/git-hooks.nix) for automated pre-commit checks.
   - Includes development tooling such as `nixfmt`, `nixfmt-tree`, and `nix-unit`.
   - Provides a development shell through `devshell.nix`.
   - Exposes formatters, development shells, packages, and checks through flake outputs.

6. **Extended Nix Ecosystem**
   - [Determinate Nix](https://github.com/DeterminateSystems/nix-installer) for an alternative Nix distribution and daemon.
   - [Agenix](https://github.com/ryantm/agenix) for declarative secret management.
   - [Disko](https://github.com/nix-community/disko) for declarative disk partitioning.
   - [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew) for Homebrew integration on macOS.
   - [Helix](https://github.com/helix-editor/helix) and [llm-agents.nix](https://github.com/numtide/llm-agents.nix) for development tooling.

## Hosts

This repository primarily manages my macOS daily-driver environment, with additional NixOS configurations for server infrastructure and experimentation.

| Host | Platform | Role | Status |
| --- | --- | --- | --- |
| MacBook-Pro | macOS | Primary workstation | Active |
| nixos | NixOS | VPS / Server | Configured |
| nixos-vm | NixOS | Linux Builder experimentation | Experimental |

Each host maintains its own system configuration while sharing common user-level settings where applicable.

## Architecture

| Component | Responsibility |
| --- | --- |
| [red-tape](https://github.com/leporuid/red-tape) | Convention-based project builder |
| [adios-flake](https://github.com/Mic92/adios-flake) | Modular flake output composition |
| [Hjem](https://github.com/feel-co/hjem) | User environment management |
| [Hjem-Rum](https://github.com/snugnug/hjem-rum) | Reusable program configuration modules |
| [Hjem-Impure](https://github.com/Rexcrazy804/hjem-impure) | Out-of-store dotfile symlinking (macOS) |
| [nix-darwin](https://github.com/nix-darwin/nix-darwin) | macOS system configuration |
| [NixOS](https://github.com/NixOS/nixpkgs) | Linux system configuration |
| [treefmt-nix](https://github.com/numtide/treefmt-nix) | Code formatting |
| [git-hooks.nix](https://github.com/cachix/git-hooks.nix) | Git pre-commit hooks |

## Directory Structure

```text
.
├── config/                 # Application and user configuration files
├── hosts/
│   ├── MacBook-Pro/        # Primary macOS host
│   ├── nixos/              # NixOS VPS configuration
│   └── nixos-vm/           # NixOS VM for Linux Builder experimentation
├── lib/                    # Shared Nix library functions
├── modules/
│   ├── common/             # Cross-platform modules
│   ├── darwin/             # macOS-specific modules
│   ├── hjem/               # Hjem-related modules
│   └── nixos/              # NixOS-specific modules
├── overlays/               # Nixpkgs overlays
├── packages/               # Custom packages
├── users/
│   └── leporuid/           # Shared user configuration
├── devshell.nix            # Development shell configuration
├── flake.nix               # Flake entry point
├── formatter.nix           # Flake formatter configuration
├── treefmt.nix             # Formatting rules
└── git-hooks.nix           # Git pre-commit hooks
```

The directory structure follows red-tape conventions, separating host-specific configurations, shared modules, user environments, application configurations, and custom packages.

## Development

The development environment provides tools for formatting, testing, and maintaining the configuration.

- `nixfmt` and `nixfmt-tree` for Nix formatting.
- `nix-unit` for Nix unit testing.
- `treefmt-nix` for consistent formatting.
- `git-hooks.nix` for automated pre-commit checks.
- `devshell.nix` for the development environment.

Flake outputs include:

- `formatter` for system-specific formatting.
- `devShells` for development environments.
- `checks` for validation and CI.
- `packages` for custom packages.
- `nixosConfigurations` and `darwinConfigurations` for host configurations.

## Acknowledgements

- [Phaer](https://github.com/phaer) — Original author of [red-tape](https://github.com/phaer/red-tape).
- [Otavio](https://github.com/otavio) — Author of the red-tape fork and host-building improvements in [PR #7](https://github.com/phaer/red-tape/pull/7).
- [Mic92](https://github.com/Mic92) — Author and maintainer of [adios-flake](https://github.com/Mic92/adios-flake).
- [feel-co](https://github.com/feel-co) — Maintainers of [Hjem](https://github.com/feel-co/hjem).
- [snugnug](https://github.com/snugnug) — Maintainer of [Hjem-Rum](https://github.com/snugnug/hjem-rum).

This configuration builds upon the work of the Nix community and the maintainers of these open-source projects.
