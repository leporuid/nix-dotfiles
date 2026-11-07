{
  flake,
  config,
  lib,
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

  # Serializes a string or structured AttrSet into configuration text.
  # - Strings are passed through as-is.
  # - AttrSets are automatically serialized to `key = value` lines.
  #   Lists (e.g. `palette = [ "0=..." "1=..." ]`) are expanded to repeated key lines.
  # This enables native Nix attribute set merging (//, lib.mkMerge, lib.mkForce) directly on themes.
  renderConfigText =
    val:
    if builtins.isString val then
      val
    else if builtins.isAttrs val then
      let
        renderEntry =
          key: v:
          if builtins.isList v then
            lib.concatMapStringsSep "\n" (item: "${key} = ${toString item}") v
          else if builtins.isBool v then
            "${key} = ${if v then "true" else "false"}"
          else
            "${key} = ${toString v}";

        # Keep palette entries grouped first if present, followed by remaining keys
        hasPalette = builtins.hasAttr "palette" val;
        paletteLines =
          if hasPalette then
            let
              p = val.palette;
            in
            if builtins.isList p then
              lib.concatMapStringsSep "\n" (item: "palette = ${toString item}") p
            else
              "palette = ${toString p}"
          else
            null;

        otherAttrs = builtins.removeAttrs val [ "palette" ];
        otherLines = lib.mapAttrsToList renderEntry otherAttrs;
        allLines = lib.optional (paletteLines != null) paletteLines ++ otherLines;
      in
      lib.concatStringsSep "\n" allLines + "\n"
    else
      builtins.toString val;
in
{
  options.my.config = {
    directory = lib.mkOption {
      default = flake;
      type = types.either types.path types.str;
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

    text = lib.mkOption {
      default = { };
      type =
        with types;
        attrsOf (
          nullOr (
            either lines (attrsOf anything)
          )
        );
      description = ''
        Mapping from system path to direct string content or structured attribute set.
        Structured attribute sets natively support Nix merging (lib.mkMerge, //, lib.mkForce)
        and are automatically rendered into key-value configuration format.
      '';
    };

    force = lib.mkOption {
      default = true;
      type = types.bool;
      description = "Whether the configuration links should override whatever exists already.";
    };
  };

  config = {
    home.file =
      let
        nonNullSource = lib.filterAttrs (_: v: v != null) cfg.source;
        sourceFiles = builtins.mapAttrs (_: v: {
          source = mkConfigSymlink v;
          force = cfg.force;
        }) nonNullSource;

        nonNullText = lib.filterAttrs (_: v: v != null) cfg.text;
        textFiles = builtins.mapAttrs (_: v: {
          text = renderConfigText v;
          force = cfg.force;
        }) nonNullText;
      in
      sourceFiles // textFiles;
  };
}
