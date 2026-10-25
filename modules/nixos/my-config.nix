{ flake, ... }:
{
  config,
  lib,
  ...
}:

let
  inherit (lib.types) attrsOf either nullOr path str;

  cfg = config.my.system.config;

  sources = lib.filterAttrs (_: value: value != null) cfg.source;

  resolveSource =
    source:
    if builtins.isPath source then
      source
    else if lib.hasPrefix "/" source then
      source
    else
      "${toString cfg.directory}/${source}";
in
{
  options.my.system.config = {
    directory = lib.mkOption {
      type = either path str;
      default = flake;
      description = "Base directory for system configuration sources.";
    };

    source = lib.mkOption {
      type = attrsOf (nullOr (either path str));
      default = { };
      description = "Files and directories installed below /etc.";
    };
  };

  config = lib.mkIf (sources != { }) {
    environment.etc = lib.mapAttrs (_: source: {
      source = resolveSource source;
    }) sources;
  };
}