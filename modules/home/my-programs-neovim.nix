{
  lib,
  config,
  ...
}:
let
  cfg = config.my.programs.neovim;

  mkPluginLink =
    group: p:
    let
      subdir = if p.start or false then "start" else "opt";
    in
    {
      "${config.xdg.dataHome}/nvim/site/pack/${group}/${subdir}/${p.name}" = {
        source = p.src;
        recursive = p.recursive or false;
      };
    };

  links = lib.foldlAttrs (
    acc: group: plugins:
    lib.foldl' (acc2: pl: acc2 // mkPluginLink group pl) acc plugins
  ) { } cfg.packages;

  pluginType = lib.types.submodule (
    { ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
        };
        src = lib.mkOption {
          type = lib.types.path;
        };
        start = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        recursive = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };
    }
  );
in
{
  options.my.programs.neovim = with lib; {
    enable = mkEnableOption "Install NeoVim plugins via packpath" // {
      default = true;
    };

    packages = mkOption {
      type = types.attrsOf (types.listOf pluginType);
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = links;
  };
}