---
name: dotfiles-and-hjem-config
description: Engineering guide for raw dotfiles under config/, the my.config synthesis engine, Hjem user modules (modules/hjem/), users/leporuid/home-configuration.nix, and run.fish manifest parity checks. Use when modifying shell configs (zsh, fish, nushell), editor/terminal setups (neovim, helix, ghostty, zed), VCS configs (jj, git), themes, or debugging Hjem symlinks and check-links.
---
# Dotfiles and Hjem Config Engineering

Maintains user-level Hjem configurations (`modules/hjem/*.nix`, `users/leporuid/home-configuration.nix`), raw application configs (`config/`), and `run.fish` verification tools in `~/Developer/nix-dotfiles`.

> For scaffolding a brand-new `modules/hjem/<app>.nix`, synthesize `@hjem-module-scaffolder` alongside this skill.

## When to Use

- Editing `modules/hjem/my-config.nix`, `themes.nix`, `agents.nix`, `fish.nix`, `nushell.nix`, `zsh.nix`, `neovim.nix`, `helix.nix`, `ghostty.nix`, `jujutsu.nix`, `git.nix`, or `users/leporuid/home-configuration.nix`.
- Modifying raw configs under `config/` (`fish/`, `nushell/`, `zsh/`, `nvim/`, `helix/`, `ghostty/`, `jj/`, `git/`, `starship.toml`, `bat/`).
- Debugging Hjem `files` / `xdg.config.files` collisions, Darwin vs. Linux path differences, or `check-links` failures.

## `my.config` Synthesis Engine (`modules/hjem/my-config.nix`)

- **Out-of-Store vs. Pure Store**: `useOutOfStoreSymlinks = isDarwin;` in `users/leporuid/home-configuration.nix` links `config/` directly on macOS for instant live edits, while Linux hosts resolve immutable `/nix/store` copies (`storeDirectory = ../../config`).
- **Base + Override Merging**: Passing an attrset `{ base = "rel/path"; ... }` to `my.config.source` parses `.toml`, `.json`, or key-value files (handling repeated `palette = ...` keys), applies `lib.recursiveUpdate`, and serializes back to TOML/JSON/KV text.
- **Platform Filtering**: Darwin-only GUI/tool configs (`foot`, `kitty`, `zed`, `btt`, `github-copilot`, `raycast`) MUST stay inside `lib.optionalAttrs isDarwin` in `users/leporuid/home-configuration.nix` so headless NixOS hosts never receive them.

## Cross-Shell Architecture & Collision Guards

1. **Zsh (`modules/hjem/zsh.nix`, `config/zsh/.zshrc`)**:
   - Login shell (`UserShell`) on Darwin; initializes `ZDOTDIR`, cached `sheldon`, and hands off interactive sessions to `exec fish -l` guarded by `has-ancestor fish`.
   - Keep `unsetopt nomatch` AFTER the Fish handoff so `.#MacBook-Pro` flake refs pass unquoted in Zsh.
2. **Fish (`modules/hjem/fish.nix`, `config/fish/`, `packages/run.nix`)**:
   - Uses `rum.programs.fish.enable = true`.
   - `modules/hjem/fish.nix` links `config/fish/conf.d/*.fish` individually (`filterAttrs` regular `.fish` files) so `hjem-rum`'s generated `rum-environment-variables.fish` is never clobbered.
   - `packages/run.nix` packages `config/fish/functions/run.fish` and `config/fish/completions/run.fish` via `lib.fileset.toSource` into an executable `run` CLI.
   - Never enable `rum.programs.<tool>.integrations.fish.enable = true` when `config/fish/config.fish` already handles the hook (`starship`, `zoxide`, `direnv`, `fzf`, with `__DIRENV_INSTANT_HOOKED` guard for `direnv-instant`).
3. **Nushell (`modules/hjem/nushell.nix`, `config/nushell/`)**:
   - Uses `rum.programs.nushell` loading `source ($nu.default-config-dir | path join 'local.nu')`.
   - Keep `config/nushell/{config,env}.nu` strictly native Nushell syntax (never add POSIX/Termius shims).
   - On Darwin, `modules/hjem/nushell.nix` mirrors `config.nu`, `env.nu`, and `local.nu` into `Library/Application Support/nushell/` for GUI-launched processes lacking `XDG_CONFIG_HOME`.

## Editors, Terminals, VCS & Agents

- **Neovim (`modules/hjem/neovim.nix`, `config/nvim/plugins.nix`)**: Packpath `start`/`opt` links built via `fromGitHub` helper; wrapped with `symlinkJoin` + `nativeBuildInputs = [ pkgs.makeWrapper ]`.
- **Helix (`modules/hjem/helix.nix`, `config/helix/`)**: Always use nixpkgs `pkgs.helix` (never upstream `helix` flake input due to `tree-sitter-perl` glibc issues). Keybindings integrate `ccase`, `schemat`, `fish-lsp` (`fish_lsp_show_client_popups = "false"`), `nil`, `taplo`, `vtsls`, `rust-analyzer`.
- **Ghostty & Themes (`modules/hjem/ghostty.nix`, `themes.nix`)**: Links `os-config-{darwin,linux}` + `inputs.ghostty-cursor-shaders`; precompiles `config/bat` into `batCache` and wraps `bat` with `Catppuccin Mocha`.
- **Jujutsu & Git (`modules/hjem/jujutsu.nix`, `git.nix`, `config/jj/config.toml`)**: Sets `JJ_CONFIG` and maps `jj` config to `Library/Application Support/jj` on Darwin vs `.config/jj` on Linux (`sign-on-push = true`).
- **Agents (`modules/hjem/agents.nix`)**: Maps `.agents/skills`, `.claude/skills`, and `.gemini/skills` to `llms/skills`, and distributes `AGENTS.md` to `.claude/CLAUDE.md`, `.codex/AGENTS.md`, and `.config/opencode/AGENTS.md`.

## Standalone vs. Host Parity (`check-links` in `run.fish`)

When touching `modules/hjem/`, `users/leporuid/home-configuration.nix`, or `lib/default.nix` (`mkPerSystem`), verify that `hjemConfigurations.leporuid.manifest` matches every host generation:
```fish
check-links --user leporuid --host MacBook-Pro --target-root /Users/leporuid
check-links --user leporuid --host nixos
check-links --user leporuid --host nixos-vm
```
If you add new Darwin-only targets or Darwin/Linux path mappings, keep the `platform_filter` rules in `run.fish` (`check-links`) synchronized.
