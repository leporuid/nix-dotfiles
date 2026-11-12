# Neovim module in moni-dz style: packpath-based plugin management
{
  config,
  lib,
  pkgs,
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
      ".local/share/nvim/site/pack/${group}/${subdir}/${p.name}".source = p.src;
    };

  links = lib.foldlAttrs (
    acc: group: plugins:
    lib.foldl' (acc2: pl: acc2 // mkPluginLink group pl) acc plugins
  ) { } cfg.packages;

  pluginType = lib.types.submodule (_: {
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
    };
  });
in
{
  options.my.programs.neovim = {
    enable = lib.mkEnableOption "NeoVim plugins via packpath" // {
      default = true;
    };

    packages = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf pluginType);
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [
      pkgs.neovim
      pkgs.tree-sitter
      pkgs.ripgrep
    ];

    files = links;

    my.config.source = {
      ".config/nvim" = "nvim";
    };
  };
}
