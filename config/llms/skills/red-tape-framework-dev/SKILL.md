---
name: red-tape-framework-dev
description: Development and testing guide for leporuid/red-tape (~/Developer/red-tape), the convention-based Nix flake framework built on Mic92/adios-flake with Hjem/Hjem-Rum Manifest v3 and flake-schemas support. Use when modifying red-tape modules, lib/internal.nix discovery, contrib/*.nix host builders, hjemSchemas, benchmarks, or nix-unit tests.
---
# Red-Tape Framework Development

Develops and verifies `~/Developer/red-tape` (`leporuid/red-tape`), the `adios-flake`-powered convention framework consumed by `nix-dotfiles`.

> Consult `~/Developer/red-tape/AGENTS.md` and `DESIGN.md` first; never read `flake.lock`.

## When to Use

- Editing `~/Developer/red-tape/flake.nix`, `lib/{default,internal}.nix`, `modules/*.nix`, `contrib/*.nix`, `tests/*.nix`, or `bench/`.
- Extending Hjem Manifest v3 (`contrib/hjem.nix`), `hjemSchemas`, `rumModules`, `perSystem` injection, or custom `hostTypes` / `moduleTypes`.
- Testing downstream `red-tape` changes against `~/Developer/nix-dotfiles`.

## Architecture & DAG Topology

```text
lib/internal.nix       (pure filesystem scanning & callFile/filterPlatforms)
        ↑
modules/*.nix          (adios-flake DAG modules)
  ├── project ──→ scope ──→ { packages, devshells, formatter, checks }
  └── project ──→ { hosts, modules, templates, lib } (+ contrib)
        ↑
contrib/*.nix          (darwin, hjem, home-manager, system-manager)
```

1. **Pure Scanning (`lib/internal.nix`)**:
   - Scanning primitives (`scanDir`, `scanHosts`, `scanEntries`, `scanSubdirs`) MUST rely solely on `builtins.readDir`, `builtins.pathExists`, and path construction — never trigger Nix evaluation during discovery.
   - `scanHosts` scans `(scanHosts (src + "/users") hostTypes) // (scanHosts (src + "/hosts") hostTypes)`, matching ordered `{ type, file }` specs (first match wins).
   - `filterPlatforms system pkgs` filters packages by `meta.platforms`.

2. **Hjem Contrib & Schemas (`contrib/hjem.nix`, `flake.nix`)**:
   - Registers `hjem-configuration.nix` and `home-configuration.nix` -> `hjemConfigurations`.
   - Registers `moduleTypes`: `hjem` -> `hjemModules`, `rum` -> `rumModules`.
   - Evaluates `lib.evalModules` with `class = "hjem"`, `clobberFiles = lib.mkDefault true`, optional `hjem-rum` / `hjem-impure` inputs, `system.nix` sibling override, and `perSystem` injection matching `nix-dotfiles`'s `lib.mkPerSystem`.
   - Emits Manifest v3 (`manifest`, `packages`, `config`, `options`, `build`) and sanitizes file entries via `fileToJson`.
   - `flake.nix` exports `hjemSchemas` (`hjemConfigurations`, `hjemModules`, `rumModules`) compatible with `flake-schemas` (`checks/schemas.nix` in `nix-dotfiles`).

3. **No Global Overlays in Core**: Keep core `red-tape` overlay-free (`callPackage`-style evaluation); consumers apply overlays explicitly at flake level.

## Verification & Cross-Repo Testing

1. **Format & Offline Unit Tests (inside `~/Developer/red-tape`)**:
   ```fish
   nix fmt
   nix develop -c nix-unit tests/default.nix
   ```
   All tests under `tests/` (`scan-dir`, `discover`, `integration`, `hosts`, `hjem`, `modules-export`, `templates`, `lib-export`, `module`, `extensibility`, `prefix`) must pass offline using `tests/fixtures/`.

2. **Downstream `nix-dotfiles` Verification**:
   - Test local `red-tape` edits against `~/Developer/nix-dotfiles` without breaking remote NixOS builds by passing `--override-input red-tape path:/Users/leporuid/Developer/red-tape` on ad-hoc `nix eval` / `nix flake check` runs.
   - **Invariant**: Never commit a local `path:` `red-tape` URL in `nix-dotfiles/flake.nix`; always push `red-tape` first and `nix flake update red-tape` in `nix-dotfiles`.
