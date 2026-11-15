# Neovim module in moni-dz style: packpath-based plugin management
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.attrsets) foldlAttrs;
  inherit (lib.lists) foldl';
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) makeBinPath;
  inherit (lib.types)
    attrsOf
    bool
    listOf
    path
    str
    submodule
    ;

  cfg = config.my.programs.neovim;

  neovimWithDependencies = pkgs.symlinkJoin {
    name = "neovim-with-dependencies";
    paths = [ pkgs.neovim ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/nvim" \
        --prefix PATH : ${
          makeBinPath [
            pkgs.curl
            pkgs.tree-sitter
            pkgs.ripgrep
          ]
        }
    '';
  };

  mkPluginLink =
    group: p:
    let
      subdir = if p.start or false then "start" else "opt";
    in
    {
      ".local/share/nvim/site/pack/${group}/${subdir}/${p.name}".source = p.src;
    };

  links = foldlAttrs (
    acc: group: plugins:
    foldl' (acc2: pl: acc2 // mkPluginLink group pl) acc plugins
  ) { } cfg.packages;

  pluginType = submodule (_: {
    options = {
      name = mkOption {
        type = str;
      };
      src = mkOption {
        type = path;
      };
      start = mkOption {
        type = bool;
        default = false;
      };
    };
  });
in
{
  options.my.programs.neovim = {
    enable = mkEnableOption "NeoVim plugins via packpath" // {
      default = true;
    };

    packages = mkOption {
      type = attrsOf (listOf pluginType);
      default = { };
    };
  };

  config = mkIf cfg.enable {
    packages = [
      neovimWithDependencies
      pkgs.tree-sitter
    ];

    files = links;

    my.config.source = {
      ".config/nvim" = "nvim";
    };
  };
}
