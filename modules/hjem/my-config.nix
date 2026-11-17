# Hjem-native my-config module: Declarative configuration synthesizer
# Supports out-of-store symlinking, base file inheritance, and automatic format serialization (TOML/JSON/Key-Value)
{
  config,
  lib,
  ...
}:
let
  inherit (lib.attrsets)
    filterAttrs
    isDerivation
    mapAttrs
    mapAttrsToList
    recursiveUpdate
    ;
  inherit (lib.generators) toTOML;
  inherit (lib.lists) elemAt optional;
  inherit (lib.options) literalExpression mkOption;
  inherit (lib.strings)
    concatMapStringsSep
    concatStringsSep
    hasPrefix
    hasSuffix
    splitString
    trim
    ;
  inherit (lib.types)
    anything
    attrsOf
    bool
    either
    lines
    nullOr
    path
    str
    ;

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
      rawLines = splitString "\n" text;
      validLines = builtins.filter (
        line:
        let
          trimmed = trim line;
        in
        trimmed != "" && !hasPrefix "#" trimmed && !hasPrefix "//" trimmed
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
            key = trim (elemAt parts 0);
            val = trim (elemAt parts 1);
          in
          if key == "palette" then
            acc // { palette = (acc.palette or [ ]) ++ [ val ]; }
          else
            acc // { ${key} = val; };
    in
    builtins.foldl' parseLine { } validLines;

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
            concatMapStringsSep "\n" (item: "${key} = ${toString item}") v
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
              concatMapStringsSep "\n" (item: "palette = ${toString item}") p
            else
              "palette = ${toString p}"
          else
            null;

        otherAttrs = builtins.removeAttrs val [ "palette" ];
        otherLines = mapAttrsToList renderEntry otherAttrs;
        allLines = optional (paletteLines != null) paletteLines ++ otherLines;
      in
      concatStringsSep "\n" allLines + "\n"
    else
      builtins.toString val;

  # Renders content for a given target path:
  # - If string/path/derivation: symlink directly or via mkConfigSymlink.
  # - If AttrSet:
  #   - If it has `base`, read and parse base file (TOML, JSON, or key-value), then merge overrides.
  #   - Automatically serialize to TOML, JSON, or key-value text based on target file extension.
  renderConfigContent =
    targetPath: val:
    if builtins.isPath val || isDerivation val then
      { source = val; }
    else if builtins.isString val then
      { source = mkConfigSymlink val; }
    else if builtins.isAttrs val then
      let
        hasBase = builtins.hasAttr "base" val;
        baseFile = if hasBase then "${cfg.storeDirectory}/${val.base}" else null;
        overrides = builtins.removeAttrs val [ "base" ];

        baseAttrs =
          if !hasBase then
            { }
          else if hasSuffix ".toml" val.base then
            builtins.fromTOML (builtins.readFile baseFile)
          else if hasSuffix ".json" val.base then
            builtins.fromJSON (builtins.readFile baseFile)
          else
            parseKeyValue (builtins.readFile baseFile);

        merged = recursiveUpdate baseAttrs overrides;
      in
      if hasSuffix ".toml" targetPath then
        { text = toTOML { } merged; }
      else if hasSuffix ".json" targetPath then
        { text = builtins.toJSON merged; }
      else
        { text = renderConfigText merged; }
    else
      throw "my.config.source: unsupported value for ${targetPath}";
in
{
  options.my.config = {
    directory = mkOption {
      default = "${config.directory}/Developer/nix-dotfiles/config";
      defaultText = literalExpression ''
        "''${config.directory}/Developer/nix-dotfiles/config"
      '';
      type = either path str;
      description = ''
        Local absolute path to the configuration directory when useOutOfStoreSymlinks is enabled.
      '';
    };

    storeDirectory = mkOption {
      default = ../../config;
      type = either path str;
      description = ''
        Pure repository path to the configuration directory used for store-backed builds and base files.
      '';
    };

    useOutOfStoreSymlinks = mkOption {
      default = false;
      type = bool;
      description = ''
        Whether to link directly to the local checkout directory instead of the Nix store.
      '';
    };

    source = mkOption {
      default = { };
      type = attrsOf (nullOr (either (either str path) (attrsOf anything)));
      description = ''
        Mapping from target configuration path to:
        - Relative path string: creates symlink to the repo file.
        - Attribute set: supports `{ base = "rel/path"; ...overrides }` or pure attributes,
          with automatic TOML/JSON/key-value serialization and native Nix merging.
      '';
    };

    text = mkOption {
      default = { };
      type = attrsOf (nullOr (either lines (attrsOf anything)));
      description = ''
        Mapping from target configuration path to direct string content or structured attribute set.
        Structured attribute sets natively support Nix merging and are automatically rendered.
      '';
    };

    clobber = mkOption {
      default = config.clobberFiles;
      defaultText = literalExpression "config.clobberFiles";
      type = bool;
      description = "Whether the configuration links should override whatever exists already.";
    };
  };

  config = {
    # Seamlessly map outputs to native Hjem file attributes
    files =
      let
        nonNullSource = filterAttrs (_: v: v != null) cfg.source;
        sourceFiles = mapAttrs (
          targetPath: val: (renderConfigContent targetPath val) // { inherit (cfg) clobber; }
        ) nonNullSource;

        nonNullText = filterAttrs (_: v: v != null && v != "" && v != { }) cfg.text;
        renderedTextFiles = mapAttrs (_: v: {
          text = renderConfigText v;
          inherit (cfg) clobber;
        }) nonNullText;
        textFiles = filterAttrs (_: v: v.text != "") renderedTextFiles;
      in
      sourceFiles // textFiles;
  };
}
