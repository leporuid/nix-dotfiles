# lib/default.nix — Shared functional library for nix-dotfiles
# Exported by red-tape as `flake.lib`
{
  inputs ? { },
  lib ? inputs.nixpkgs.lib or null,
  ...
}:
let
  formats = import ./formats.nix { };
  darwin = import ./darwin.nix { };
  hjem = import ./hjem.nix { };
  hosts = import ./hosts.nix { inherit inputs lib; };
  nixSettings = import ./nix-settings.nix;
in
{
  inherit
    darwin
    formats
    hjem
    hosts
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
  inherit (hosts) mkDarwinSystem mkNixosSystem;

  # Blueprint compatibility aliases
  loadNixDarwin = hosts.mkDarwinSystem;
  loadNixOS = hosts.mkNixosSystem;
}
