# lib/default.nix — Shared functional library for nix-dotfiles
# Exported by red-tape as `flake.lib`
_:
let
  formats = import ./formats.nix { };
  darwin = import ./darwin.nix { };
  hjem = import ./hjem.nix { };
  nixSettings = import ./nix-settings.nix;
in
{
  inherit
    darwin
    formats
    hjem
    nixSettings
    ;
  inherit (formats)
    mkIni
    mkJson
    mkToml
    mkYaml
    ;
  inherit (darwin) mkAppCloneScript;
  inherit (hjem) mkProgramModule;

  # Builds the `perSystem` view ({ system, packages.<input> }) that host
  # evaluations normally inject as a special argument. Needed where nothing is
  # injected, such as standalone Hjem configurations, so both paths resolve
  # packages identically.
  mkPerSystem =
    {
      inputs,
      lib,
      system,
      packages ? [
        "self"
        "llm-agents"
      ],
    }:
    {
      inherit system;
      packages = lib.genAttrs packages (
        name:
        (lib.attrByPath [ "legacyPackages" system ] { } inputs.${name})
        // (lib.attrByPath [ "packages" system ] { } inputs.${name})
      );
    };

}
