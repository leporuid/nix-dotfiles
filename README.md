# macOS & NixOS Configuration

A lightweight, modular, and convention-based Nix configuration primarily designed for macOS using [**nix-darwin**](https://github.com/nix-darwin/nix-darwin), with additional NixOS configurations for VPS deployments and Linux Builder experimentation.

Built with [**red-tape**](https://github.com/leporuid/red-tape), [**adios-flake**](https://github.com/Mic92/adios-flake), [**Hjem**](https://github.com/feel-co/hjem), and [**Hjem-Rum**](https://github.com/snugnug/hjem-rum).

This project uses a personal fork of red-tape, originally created by [Phaer](https://github.com/phaer/red-tape) and subsequently extended by [Otavio](https://github.com/otavio), with additional host-building and standalone Hjem improvements.

## Highlights

1. **Convention-Based Flake Architecture**
   - Uses [red-tape](https://github.com/leporuid/red-tape), built on top of [adios-flake](https://github.com/Mic92/adios-flake), to organize and generate flake outputs through filesystem conventions.
   - Keeps the root `flake.nix` focused on inputs and output composition while delegating project structure and configuration generation to red-tape.
   - Supports modular system configurations, standalone Hjem manifests, development shells, overlays, packages, checks, formatters, and reusable modules.

2. **Home Manager-Free User Configuration**
   - Uses [Hjem](https://github.com/feel-co/hjem) as a native NixOS and nix-darwin module for declarative user environment management.
   - Uses [Hjem-Rum](https://github.com/snugnug/hjem-rum) (`rum.programs.*`) alongside custom Hjem modules (`my.programs.*`) for reusable program configurations.
   - Integrates [Hjem-Impure](https://github.com/Rexcrazy804/hjem-impure) on macOS for out-of-store symlinking and live dotfile editing without rebuilding the system, while keeping Linux hosts on pure Nix store paths.
   - Eliminates the need for Home Manager while keeping user configurations modular and declarative.

3. **Multi-Platform Configuration**
   - **macOS (Primary):** Main daily-driver environment managed through nix-darwin.
   - **NixOS (VPS):** Server configuration managed through native NixOS modules.
   - **NixOS VM (Experimental):** A virtual machine used for testing and exploring NixOS-based Linux Builder setups.
   - Shares common user configurations through Hjem and Hjem-Rum while keeping platform-specific system configurations independent.

4. **Shared User Configuration**
   - `users/leporuid/home-configuration.nix` serves as the central source of shared user configuration and standalone `hjemConfigurations.leporuid`.
   - Host-specific user bridges under `hosts/<host>/users/leporuid/` connect shared settings to individual systems.
   - Minimizes duplicated configuration between macOS and Linux.

5. **Development Environment & Code Quality**
   - Uses [treefmt-nix](https://github.com/numtide/treefmt-nix) (`formatter.nix` / `treefmt.nix`) for declarative and reproducible formatting across Nix, Fish, Shell, TOML, and YAML.
   - Uses [git-hooks.nix](https://github.com/cachix/git-hooks.nix) for automated pre-commit checks.
   - Enforces Nix code quality with `deadnix`, `statix`, `pedantix`, `nixfmt`, `nil`, and `nixd`.
   - Provides a full development shell through `devshell.nix`.

6. **Extended Nix Ecosystem**
   - [Determinate Nix](https://github.com/DeterminateSystems/nix-installer) for an alternative Nix distribution and daemon.
   - [Agenix](https://github.com/ryantm/agenix) (`rage` / `age-plugin-se`) for declarative secret management.
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

## Development

The development environment provides tools for formatting, linting, secret management, and maintaining the configuration:

- `treefmt-nix` (`deadnix`, `statix`, `nixfmt`, `fish_indent`, `shfmt`, `taplo`, `yamlfmt`) for consistent formatting.
- `pedantix` for strict Nix argument ordering and style checks.
- `nil` and `nixd` for Nix language server diagnostics.
- `git-hooks.nix` for automated pre-commit checks.
- `devshell.nix` for the development shell (`llm-agents`, `agenix`, `rage`, `just`).

Flake outputs include:

- `darwinConfigurations` and `nixosConfigurations` for host configurations.
- `hjemConfigurations` for standalone Hjem Manifest v3 evaluation.
- `darwinModules`, `nixosModules`, and `hjemModules` for reusable system and user modules.
- `overlays` for custom Nixpkgs overrides.
- `packages` for custom derivations.
- `devShells`, `formatter`, and `checks` for development environments, formatting, and CI validation.

## Acknowledgements

- [Phaer](https://github.com/phaer) — Original author of [red-tape](https://github.com/phaer/red-tape).
- [Otavio](https://github.com/otavio) — Author of the red-tape fork and host-building improvements in [PR #7](https://github.com/phaer/red-tape/pull/7).
- [Mic92](https://github.com/Mic92) — Author and maintainer of [adios-flake](https://github.com/Mic92/adios-flake).
- [feel-co](https://github.com/feel-co) — Maintainers of [Hjem](https://github.com/feel-co/hjem).
- [snugnug](https://github.com/snugnug/hjem-rum) — Maintainer of [Hjem-Rum](https://github.com/snugnug/hjem-rum).

This configuration builds upon the work of the Nix community and the maintainers of these open-source projects.
