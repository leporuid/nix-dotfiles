---
name: hjem-module-scaffolder
description: Automated Hjem and Hjem-Rum (HJR) module scaffolding generator for Nix configurations. Generates compliant, minimal-option Nix module boilerplate adhering to pedantix.toml argument ordering, RFC 166 nixfmt formatting, Hjem Manifest v3 schema, lib.fileset.toSource packaging, and zero-empty-file guards. Use whenever authoring new Hjem user modules, adding application dotfile configurations, or structuring NixOS/Darwin hjem configurations.
allowed-tools: client
---
# Hjem Module Scaffolder

An automated architecture and scaffolding generator for Nix configurations in `~/Developer/nix-dotfiles` using `feel-co/hjem`, `snugnug/hjem-rum` (HJR), and `leporuid/red-tape` (`adios-flake`).

## Summary

Generate clean, boilerplate-free Hjem modules under `modules/hjem/*.nix` compliant with `pedantix.toml`, RFC 166 `nixfmt`, `deadnix`/`statix`, Manifest v3, and collision-free shell integration rules.

## When to Use

- Creating new user application modules in `modules/hjem/<app>.nix`.
- Generating Hjem Manifest v3 file generation blocks using `pkgs.formats` (`toml`, `yaml`, `json`, `ini`) or `my.config.source`.
- Packaging custom companion derivations with `lib.fileset.toSource` (from `4evy-dotfiles`).
- Structuring live dotfile symlinks via `my.config.useOutOfStoreSymlinks = isDarwin;` (macOS live edits, Linux pure store paths).

## Core Architectural Guardrails

### 1. Module Header & Argument Sorting (`pedantix.toml` Invariant)

Strictly order arguments as: `self`, `inputs`, `config`, `lib`, `pkgs`, domain args alphabetically, `<defaulted>`, `...` — omitting any unused arguments to pass `deadnix` and `statix`.

### 2. Location-Aliased `let ... in` Block

Bind exact `lib` locations at the top:

```nix
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.attrsets) optionalAttrs;

  cfg = config.my.programs.<module-name>;
in
```

### 3. Collision & Zero-Empty-File Guards

- Never reference `config` inside `options`.
- **Zero Empty Files**: Guard file emissions with `mkIf (cfg.settings != { } || cfg.extraConfig != "")`.
- **Shell Integration Collision Guard** (from `hjr-wrapped`): Never enable `rum.programs.<tool>.integrations.<shell>.enable = true` when `my.config.source` already owns that shell's config file (e.g., `fish/config.fish`), or Hjem will fail with duplicate file definitions.
- **Per-File `conf.d` Linking**: When linking `fish/conf.d/*.fish`, filter regular `.fish` files individually (like `modules/hjem/fish.nix`) so `rum-environment-variables.fish` is never clobbered.

### 4. Standard `my.programs.<app>` Module Template

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.my.programs.<app>;
in
{
  options.my.programs.<app> = {
    enable = mkEnableOption "<app> configuration via Hjem";

    package = mkPackageOption pkgs "<app>" {
      default = "<app>";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    my.config.source = {
      ".config/<app>" = "<app>";
    };
  };
}
```

## Guidelines & Tone

- Pre-format generated code to pass `nix fmt` (`treefmt`: `deadnix` -> `statix` -> `nixfmt`) and `pedantix --check`.
- All code comments and commit messages must be in clean English; user explanations in Traditional Chinese (`zh-Hant`).
