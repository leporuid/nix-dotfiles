---
name: fast-repo-reader
description: Rapidly analyze and extract architecture, module patterns, and configurations from external GitHub repositories without interactive terminal permission prompts. Use when the user shares a GitHub repository, asks to audit, inspect, or compare an external repo, or wants to extract Nix, Hjem, adios-flake, or red-tape patterns.
---
# Fast Repo Reader

Efficiently retrieve, analyze, and synthesize external Git/GitHub repositories and technical articles without triggering intrusive host terminal permission prompts.

## When to Use

- User provides an external GitHub repository, commit, file URL, or technical blog (e.g., `moni-dz/nix-config`, `Mic92/adios-flake`, `otavio/nix-config`, `paperdev-code/dendritic-nix`, `paperdev-code/hjem`, `snugnug/hjem-rum`, Apribase) and asks to inspect, compare, or adopt its patterns.
- Comparing external Nix architectures (DAG-based `adios-flake`, convention-based `red-tape`, Dendritic aspect patterns, Hjem Manifest v3, `hjr-wrapped` hermetic wrappers) against local repositories in `~/Developer`.
- Extracting configurations (`pedantix.toml`, `statix.toml`, `treefmt.nix`), packaging recipes, or module schemas from upstream repositories.

## Workflow

1. **Check Local Clones First, Then Non-Intrusive Remote Inspection**:
   - First check if the repository is already cloned in connected folders under `~/Developer` (e.g., `nix-dotfiles`, `red-tape`, `cnix`, `mikos-den`).
   - For remote repositories, use web search or targeted read-only inspection without interactive git prompts.

2. **Architecture & Pattern Extraction**:
   - Locate root entrypoints (`flake.nix`, `DESIGN.md`, `README.md`, `CONTRIBUTING.md`, `pedantix.toml`, `statix.toml`).
   - Identify evaluation models:
     - **Explicit DAG (`Mic92/adios-flake` & `leporuid/red-tape`)**: Inspect `outputs`, `inputs`, `impl`, and `contrib/*.nix` extensions.
     - **Hjem & Hjem-Rum (`feel-co/hjem`, `snugnug/hjem-rum`, `paperdev-code/hjem`)**: Inspect Manifest v3 synthesis (`version = 3; files = [ ... ];`), pure option design (`pkgs.formats.<fmt>`), `let ... in` location-aliased `inherit` blocks, and zero-empty-file guards (`mkIf` / `optionalAttrs`).
     - **Hermetic Wrapping (`hjr-wrapped`)**: Inspect `symlinkJoin` + `makeWrapper` patterns that bake generated config files into package derivations without polluting `$HOME`.

3. **Synthesis & Local Alignment**:
   - Map discovered patterns directly to `~/Developer/nix-dotfiles` (`modules/{common,darwin,nixos,hjem}`, `lib/{caches,darwin,default,nix-settings}.nix`) and `~/Developer/red-tape` (`contrib/hjem.nix`).
   - Evaluate cross-platform edge cases (`aarch64-darwin` vs `aarch64-linux`, `systemd` vs `launchd`, APFS app cloning) using the 5-role perspective panel before applying surgical changes.
