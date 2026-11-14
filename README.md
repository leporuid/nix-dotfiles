# NixOS & macOS Configuration

A lightweight, modular, and convention-based Nix configuration for NixOS and macOS, built with [**red-tape**](<https://github.com/leporuid/red-tape>), **adios-flake**, **Hjem**, and **Hjem-Rum**.

This project uses a personal fork of red-tape, originally created by [Phaer](<https://github.com/phaer>) and subsequently extended by [Otavio](<https://github.com/otavio>), with additional host-building improvements.

## Highlights

1. **Convention-Based Flake Architecture**
   - Uses [red-tape](<https://github.com/leporuid/red-tape>), built on top of adios-flake, to organize and generate flake outputs through filesystem conventions.
   - Keeps the root `flake.nix` minimal while delegating project structure and output generation to red-tape.
   - Supports modular system configurations, development shells, packages, checks, formatters, and reusable modules.
2. **Home Manager-Free User Configuration**
   - Uses Hjem as a native NixOS and nix-darwin module for declarative user environment management.
   - Uses Hjem-Rum for reusable program configuration modules (`programs.git`, `programs.fish`, etc.).
   - Uses Hjem-Impure for out-of-store symlinking and live dotfile editing without rebuilding the system.
   - Eliminates the need for Home Manager while keeping user configurations modular and declarative.
3. **Cross-Platform Configuration**
   - **NixOS:** Native system configuration through NixOS modules.
   - **macOS:** System configuration through nix-darwin.
   - Shares common user configurations across platforms while keeping host-specific settings independent.
4. **Generic Users (****`generic-users`****)**
   - `users/me/home-configuration.nix` serves as the single source of truth for shared user configuration.
   - Host-specific user configurations under `hosts/<host>/users/me/` bridge shared settings into individual systems.
   - Minimizes duplicated configuration between Linux and macOS.
5. **Development Environment & Code Quality**
   - Uses treefmt-nix for declarative and reproducible code formatting.
   - Uses git-hooks.nix for automated pre-commit checks.
   - Includes development tooling such as `nixfmt-tree` and `nix-unit`.
   - Uses convention-based development shells and checks to maintain a consistent workflow.
6. **Extended Nix Ecosystem**
   - Determinate Nix for an alternative Nix distribution and daemon.
   - Agenix for declarative secret management.
   - Disko for declarative disk partitioning.
   - nix-homebrew for Homebrew integration on macOS.
   - Helix and llm-agents.nix for development tooling.

## Architecture

| Component | Responsibility |
| --- | --- |
| [red-tape](<https://github.com/leporuid/red-tape>) | Convention-based project builder |
| [adios-flake](<https://github.com/Mic92/adios-flake>) | Modular flake output composition |
| [Hjem](<https://github.com/feel-co/hjem>) | User environment management |
| [Hjem-Rum](<https://github.com/snugnug/hjem-rum>) | Reusable program configuration modules |
| [Hjem-Impure](<https://github.com/Rexcrazy804/hjem-impure>) | Out-of-store dotfile symlinking |
| [NixOS](<https://github.com/NixOS/nixpkgs>) | Linux system configuration |
| [nix-darwin](<https://github.com/nix-darwin/nix-darwin>) | macOS system configuration |
| [treefmt-nix](<https://github.com/numtide/treefmt-nix>) | Code formatting |
| [git-hooks.nix](<https://github.com/cachix/git-hooks.nix>) | Git pre-commit hooks |

## Acknowledgements

- [Phaer](<https://github.com/phaer>) — Original author of red-tape.
- [Otavio](<https://github.com/otavio>) — Author of the red-tape fork and host-building improvements in [PR #7](<https://github.com/phaer/red-tape/pull/7>).
- [Mic92](<https://github.com/Mic92>) — Author and maintainer of [adios-flake](<https://github.com/Mic92/adios-flake>).
- [feel-co](<https://github.com/feel-co>) — Maintainers of [Hjem](<https://github.com/feel-co/hjem>).
- [snugnug](<https://github.com/snugnug>) — Maintainer of [Hjem-Rum](<https://github.com/snugnug/hjem-rum>).

This configuration builds upon the work of the Nix community and the maintainers of these open-source projects.