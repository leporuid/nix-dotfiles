# GitHub Copilot Instructions (`nix-dotfiles`)

Always follow all rules defined in the repository root [`AGENTS.md`](../AGENTS.md).

Key Highlights:
1. **Minimal Token Output**: Apply edits directly or show minimal diffs. Never dump full unedited files or multi-step verbose explanations.
2. **Strict File Reading Limits**: Never read `flake.lock`. Always truncate command logs (`| tail -n 40`).
3. **Git Staging**: Ensure modified/new files are staged (`git add`) before verifying with `nix flake check`.
4. **Blueprint Architecture**: All modules in `modules/*` must use two-stage headers: `{ inputs, flake, ... }: { config, pkgs, lib, ... }:`.
5. **Raw Configs**: Preserve raw config files in `config/` via `my.config.source` instead of rewriting to Nix options.
6. **Language**: Keep all code comments (`#`) in English; reply in concise Traditional Chinese (Taiwan usage).