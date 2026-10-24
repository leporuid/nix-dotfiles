{
  config,
  lib,
  flake,
  ...
}:
let
  inherit (lib) types;
  cfg = config.my.config;

  mkConfigSymlink =
    relativePath:
    if cfg.useOutOfStoreSymlinks then
      config.lib.file.mkOutOfStoreSymlink "${cfg.directory}/${relativePath}"
    else
      "${flake}/${relativePath}";
in
{
  options.my.config = {
    directory = lib.mkOption {
      default = flake;
      type = types.path;
      description = ''
        Path to the directory that the configuration will be linked to when useOutOfStoreSymlinks is enabled.
      '';
    };

    useOutOfStoreSymlinks = lib.mkOption {
      default = false;
      type = types.bool;
      description = ''
        Whether to link directly to the local checkout directory instead of the Nix store.
      '';
    };

    source = lib.mkOption {
      default = { };
      type = with types; attrsOf (nullOr (either str path));
      description = "Mapping from system path to path relative to the source directory.";
    };

    force = lib.mkOption {
      default = true;
      type = types.bool;
      description = "Whether the configuration links should override whatever exists already.";
    };
  };

  config = lib.mkIf (cfg.source != { }) {
    home.file =
      let
        nonNull = lib.filterAttrs (_: v: v != null) cfg.source;
      in
      builtins.mapAttrs (_: v: {
        source = mkConfigSymlink v;
        force = cfg.force;
      }) nonNull;
  };
}
