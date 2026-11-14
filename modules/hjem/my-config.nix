# Hjem-native my-config module: Declarative configuration synthesizer
# Supports out-of-store symlinking, base file inheritance, and automatic format serialization (TOML/JSON/Key-Value)
{
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
      "${cfg.directory}/${relativePath}"
    else
      "${cfg.storeDirectory}/${relativePath}";

  # Parses key-value formatted text (such as Ghostty themes) into a structured AttrSet.
  # Handles repeated keys like `palette = 0=...` as lists.
  parseKeyValue =
    text:
    let
      rawLines = lib.splitString "\n" text;
      validLines = lib.filter (
        line:
        let
          trimmed = lib.trim line;
        in
        trimmed != "" && !lib.hasPrefix "#" trimmed && !lib.hasPrefix "//" trimmed
      ) rawLines;

      parseLine =
        acc: line:
        let
          parts = builtins.match "([^=]+)=(.*)" line;
        in
        if parts == null then
          acc
        else
          let
            key = lib.trim (builtins.elemAt parts 0);
            val = lib.trim (builtins.elemAt parts 1);
          in
          if key == "palette" then
            acc // { palette = (acc.palette or [ ]) ++ [ val ]; }
          else
            acc // { ${key} = val; };
    in
    lib.foldl parseLine { } validLines;

  # Serializes an AttrSet into key-value configuration text (Ghostty/INI).
  # Lists are expanded into repeated `key = item` lines.
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

  # Renders content for a given target path:
  # - If string/path: symlink via mkConfigSymlink.
  # - If AttrSet:
  #   - If it has `base`, read and parse base file (TOML, JSON, or key-value), then merge overrides.
  #   - Automatically serialize to TOML, JSON, or key-value text based on target file extension.
  renderConfigContent =
    targetPath: val:
    if builtins.isString val || lib.isDerivation val then
      { source = mkConfigSymlink val; }
    else if builtins.isAttrs val then
      let
        hasBase = builtins.hasAttr "base" val;
        baseFile = if hasBase then "${cfg.storeDirectory}/${val.base}" else null;
        overrides = builtins.removeAttrs val [ "base" ];

        baseAttrs =
          if !hasBase then
            { }
          else if lib.hasSuffix ".toml" val.base then
            builtins.fromTOML (builtins.readFile baseFile)
          else if lib.hasSuffix ".json" val.base then
            builtins.fromJSON (builtins.readFile baseFile)
          else
            parseKeyValue (builtins.readFile baseFile);

        merged = lib.recursiveUpdate baseAttrs overrides;
      in
      if lib.hasSuffix ".toml" targetPath then
        { text = lib.generators.toTOML { } merged; }
      else if lib.hasSuffix ".json" targetPath then
        { text = builtins.toJSON merged; }
      else
        { text = renderConfigText merged; }
    else
      throw "my.config.source: unsupported value for ${targetPath}";
in
{
  options.my.config = {
    directory = lib.mkOption {
      default = "/Users/leporuid/Developer/nix-dotfiles/config";
      type = types.either types.path types.str;
      description = ''
        Local absolute path to the configuration directory when useOutOfStoreSymlinks is enabled.
      '';
    };

    storeDirectory = lib.mkOption {
      default = ../../config;
      type = types.either types.path types.str;
      description = ''
        Pure repository path to the configuration directory used for store-backed builds and base files.
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
      type = with types; attrsOf (nullOr (either (either str path) (attrsOf anything)));
      description = ''
        Mapping from target configuration path to:
        - Relative path string: creates symlink to the repo file.
        - Attribute set: supports `{ base = "rel/path"; ...overrides }` or pure attributes,
          with automatic TOML/JSON/key-value serialization and native Nix merging.
      '';
    };

    text = lib.mkOption {
      default = { };
      type = with types; attrsOf (nullOr (either lines (attrsOf anything)));
      description = ''
        Mapping from target configuration path to direct string content or structured attribute set.
        Structured attribute sets natively support Nix merging and are automatically rendered.
      '';
    };

    force = lib.mkOption {
      default = true;
      type = types.bool;
      description = "Deprecated alias for clobber.";
    };

    clobber = lib.mkOption {
      default = cfg.force;
      defaultText = lib.literalExpression "config.my.config.force";
      type = types.bool;
      description = "Whether the configuration links should override whatever exists already.";
    };
  };

  config = {
    # Seamlessly map outputs to native Hjem file attributes
    files =
      let
        nonNullSource = lib.filterAttrs (_: v: v != null) cfg.source;
        sourceFiles = lib.mapAttrs (
          path: val: (renderConfigContent path val) // { inherit (cfg) clobber; }
        ) nonNullSource;

        nonNullText = lib.filterAttrs (_: v: v != null) cfg.text;
        textFiles = builtins.mapAttrs (_: v: {
          text = renderConfigText v;
          inherit (cfg) clobber;
        }) nonNullText;
      in
      sourceFiles // textFiles;
  };
}
