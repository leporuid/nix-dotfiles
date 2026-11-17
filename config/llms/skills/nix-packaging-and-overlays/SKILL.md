---
name: nix-packaging-and-overlays
description: Development and maintenance guide for custom Nix derivations, overlays, flake schema checks, and CI pipelines in nix-dotfiles. Use when adding, updating, debugging, or refactoring files under packages/, overlays/default.nix, checks/, treefmt.nix, pedantix.toml, git-hooks.nix, or .github/workflows/ci.yml.
---
# Nix Packaging and Overlays

Maintains custom derivations (`packages/`), nixpkgs overrides (`overlays/default.nix`), schema checks (`checks/`), and lint/CI gates in `~/Developer/nix-dotfiles`.

> Consult `AGENTS.md` and `@nix-dotfiles-workflow` first; never read `flake.lock`.

## When to Use

- Creating or updating packages in `packages/*.nix` or `packages/<name>/default.nix`.
- Editing `overlays/default.nix`, `checks/schemas.nix`, `treefmt.nix`, `pedantix.toml`, `git-hooks.nix`, `devshell.nix`, or `.github/workflows/ci.yml`.
- Updating pinned artifacts (`packages/n-m3u8dl-re/pin.json`) or debugging Rust / Go / Python / .NET / Darwin derivation build failures.

## Core Packaging Conventions

1. **Auto-Discovery & Platform Filtering (`red-tape`)**:
   - `red-tape.mkFlake` discovers `packages/*.nix` and `packages/*/default.nix`, calls them with `{ inputs, pkgs, pname, ... }`, and filters `packages.<system>` by `meta.platforms`.
   - Consume local packages via `inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.<name>` or `perSystem.self.<name>`.
   - Set `meta.platforms` accurately (`pkgs.lib.platforms.darwin` for macOS-only tools like `age-plugin-se` and `m3u8dl-protocol`).

2. **Strict Source Whitelisting (`lib.fileset.toSource`)**:
   - Local directory packages MUST whitelist exact build inputs using `pkgs.lib.fileset.toSource` (as in `packages/m3u8dl-protocol/default.nix`, `packages/has-ancestor/default.nix`, `packages/run.nix`, and `modules/hjem/themes.nix`) so `.DS_Store` or editor artifacts never invalidate store hashes.

3. **Language & Ecosystem Patterns in `packages/`**:
   - **Rust (`rustPlatform.buildRustPackage`)**: Pin exact `rev` + `hash` + `cargoHash` (`ccase.nix`, `cktool.nix`, `kumono.nix`, `schemat.nix`).
     - `openssl-sys` on Linux needs `nativeBuildInputs = [ pkgs.pkg-config ]` and `buildInputs = [ pkgs.openssl ]`.
     - `aws-lc-sys >= 0.42` (`AWS_LC_SYS_USE_SYSTEM=1` via cargo-setup-hook) needs `nativeBuildInputs = [ pkgs.pkg-config ]` and `buildInputs = [ pkgs.aws-lc ]`.
     - Avoid unpinned branch refs; use `determinate-nixd fix hashes` or `nix hash` to refresh SRI hashes.
   - **Go (`buildGoModule`)**: Pin `rev`, `hash`, and `vendorHash` (`comview.nix`); see `@darwin-host-and-unifi-dev` for `packages/vpn-pack` cross-compilation.
   - **.NET / Nightly Artifact Pinning (`packages/n-m3u8dl-re/`)**:
     - Reads `pin.json` (`runId`, `artifactId`, `hash`) from GitHub Actions nightly artifacts and injects `m3u8dl-protocol.injectHook` in `postFixup`.
     - Refresh via `run.fish` (`update-m3u8dl` using `gh` + `nix-prefetch-url --unpack` + `nix hash to-sri`).
     - For `buildDotnetModule` `.NET 10` (`NU1201`) regressions, force `dotnetCorePackages.sdk_8_0` and downgrade `<LangVersion>` if needed.
   - **Python (`writers.writePython3Bin` & `uv2nix`)**:
     - Single-script tools use `pkgs.writers.writePython3Bin` (`packages/oci-import-image/default.nix`).
     - Flake-based Python apps delegate directly to input outputs (`packages/ktoolbox.nix` -> `inputs.ktoolbox.packages.${system}.default`).
   - **Input-Backed Overrides**: `gallery-dl.nix` (`inputs.gallery-ai`) and `yt-dlp.nix` (`inputs.yt-ai`) reset `patches = [ ]` and disable flaky upstream checks with `doCheck = false; doInstallCheck = false; dontCheckRuntimeDeps = true;`.
   - **CLI / Wrapper Derivations**: Never put a second `nix` binary on `devshell.nix` `PATH`; wrap `pkgs.nixos-rebuild-ng` / `pkgs.nixos-anywhere` with `env TMPDIR=/tmp` (`packages/nixos-rebuild.nix`, `packages/nixos-anywhere.nix`).

## Overlays (`overlays/default.nix`)

Exposed as `flake.overlays.default` and applied across hosts. Preserve all three overlay layers:
1. **Determinate Nix Alignment**: Override `comma`, `nix-update`, and `nixpkgs-review` with `inputs.determinate` Nix so tools never pull a separate upstream `nix` closure.
2. **Darwin `curl-impersonate` `install_name` Fix**: Rewrite `@rpath/libcurl-impersonate*.dylib` IDs back to absolute store paths via `install_name_tool -id` (skipping symlinks).
3. **Darwin `curl-cffi` Test Filter**: Disable `test_verify` and `test_delete_cookies` on Darwin network sandboxes.

## Lint, Formatting, Schema Checks & CI

- **Code Style**: Follow `pedantix.toml` (`first = ["self", "inputs", "config", "lib", "pkgs"]`, `last = ["<defaulted>", "..."]`, `inherits.sort = true`) and location-aliased `inherit (lib.*) ...;` bindings (`no with pkgs;` / `no with lib;`).
- **Format & Lint**: Run `nix fmt` (`deadnix` -> `statix` -> `nixfmt`, plus `fish_indent`, `shfmt`, `taplo`, `yamlfmt`) and `pedantix --check`.
- **Schema Check (`checks/schemas.nix`)**: Evaluates `schema.inventory self.<key>` across all flake output keys (excluding `checks` to avoid recursion) and enforces `evalChecks`.
- **CI (`.github/workflows/ci.yml`)**: Runs `nix fmt -- --ci`, `pedantix --check`, `deadnix --fail .`, `statix check .`, `actionlint .github/workflows/*.yml`, `nix-eval-jobs` across `{aarch64-darwin,aarch64-linux,x86_64-linux}`, host evaluations, `check-links`, and `nix flake check`.
- Remember: always run `git add` on new/deleted `.nix` files before evaluating or building.
