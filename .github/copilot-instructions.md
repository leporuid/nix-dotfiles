# GitHub Copilot Instructions (`nix-dotfiles`)

Follow all rules in [`AGENTS.md`](../AGENTS.md):

1. **Minimal Token Output**: Apply edits directly or show minimal diffs. Do not output multi-step copy-paste tutorials or full unedited files unless asked.
2. **Language**: Use English for internal reasoning and all code comments (`#`). Reply to the user in concise Traditional Chinese (Taiwan usage).
3. **Blueprint Modules**: Always use two-stage headers (`{ inputs, flake, ... }: { config, pkgs, lib, ... }:`) in `modules/{darwin,nixos,home,common}/*.nix` and import them via `inputs.self.<type>Modules.<name>`.
4. **Config Files**: Keep raw dotfiles in `config/` and link them via `my.config.source`; do not convert them into Nix module options.
5. **Platform Boundaries**: macOS (`hosts/MacBook-Pro`) uses `nix-darwin` + Home Manager (`zsh` -> `fish`); Oracle (`hosts/nixos`) uses system-level `modules/nixos/*` (`bashInteractive` -> `fish` with TTY guard).
6. **Determinate Nix PATH**: Never introduce a second `nix` store path into `devshell.nix` `PATH`; keep `nixos-rebuild` wrapped via `writeShellScriptBin`.
