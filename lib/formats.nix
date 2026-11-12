# lib/formats.nix — Config format generators inspired by Apribase
# Generates native configuration files directly from pure Nix attrsets without intermediate bloat.
{ lib ? null, ... }:
{
  # Generate TOML file from Nix attrset
  mkToml = pkgs: name: value:
    (pkgs.formats.toml { }).generate name value;

  # Generate JSON file from Nix attrset
  mkJson = pkgs: name: value:
    (pkgs.formats.json { }).generate name value;

  # Generate INI file from Nix attrset
  mkIni = pkgs: name: value:
    (pkgs.formats.ini { }).generate name value;

  # Generate YAML file from Nix attrset
  mkYaml = pkgs: name: value:
    (pkgs.formats.yaml { }).generate name value;
}
