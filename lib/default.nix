# lib/default.nix — Shared functional library for nixos-and-darwin-shared-hjem
# Exported by red-tape as `flake.lib`
{
  inputs ? { },
  lib ? inputs.nixpkgs.lib or null,
  ...
}:
let
  formats = import ./formats.nix { inherit lib; };
  darwin = import ./darwin.nix { inherit lib; };
  hjem = import ./hjem.nix { inherit lib; };
in
{
  inherit formats darwin hjem;
  inherit (formats) mkToml mkJson mkIni mkYaml;
  inherit (darwin) mkAppCloneScript;
  inherit (hjem) mkProgramModule;
}
