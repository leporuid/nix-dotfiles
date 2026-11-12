# NixOS & Darwin Shared Configuration (Hjem + Hjem-Rum)

This template demonstrates a modern, ultra-lightweight Blueprint workspace that completely replaces Home Manager with **[feel-co/hjem](https://github.com/feel-co/hjem)** and **[snugnug/hjem-rum](https://github.com/snugnug/hjem-rum)**.

## Highlights

1. **No Home Manager Dependency**:
   - Uses `hjem` as native NixOS and nix-darwin system modules.
   - Uses `hjem-rum` for high-level program modules (`programs.git`, `programs.fish`, etc.) without the heavy evaluation footprint of Home Manager.
2. **Dual Platform Support**:
   - macOS (`hosts/my-darwin/darwin-configuration.nix`) via `nix-darwin`.
   - Linux (`hosts/my-nixos/configuration.nix`) via native NixOS.
3. **Generic Users (`generic-users`)**:
   - `users/me/home-configuration.nix` defines the single source of truth for user files and programs.
   - Host user bridges in `hosts/<host>/users/me/home-configuration.nix` inherit the shared configuration.
4. **Native Code Formatting & Pre-commit Hooks**:
   - Root `treefmt.nix` is natively evaluated by Blueprint as `formatter.<system>` and `checks.<system>.formatting`.
   - Root `git-hooks.nix` is automatically wired into `checks.<system>.pre-commit-check` and activated via `devshell.nix`.
