# Themes module in moni-dz style: Bat precompiled cache, Bat wrapper, and Ghostty themes
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.fileset) toSource;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.strings) concatStringsSep;

  cfg = config.my.themes;
  batSrc = toSource {
    root = ../../config/bat;
    fileset = ../../config/bat;
  };
  batCache =
    pkgs.runCommand "bat-cache"
      {
        nativeBuildInputs = [ pkgs.bat ];
      }
      ''
        bat cache --build --source "${batSrc}" --target "$out"
      '';
in
{
  options.my.themes = {
    enable = mkEnableOption "terminal and editor themes" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    packages = [
      (pkgs.writeShellApplication {
        name = "bat";
        runtimeInputs = [ pkgs.bat ];
        text = ''
          export BAT_THEME="Catppuccin Mocha"
          export BAT_CACHE_PATH="${batCache}"
          exec ${getExe pkgs.bat} "$@"
        '';
      })
      pkgs.bat-extras.batdiff
      pkgs.bat-extras.batman
      pkgs.bat-extras.batgrep
      pkgs.bat-extras.batwatch
    ];

    my.config.source = {
      ".config/eza" = "eza";
      ".config/ghostty/themes/Glass" = "ghostty/themes/Glass";
      ".config/ghostty/themes/Glass-Day" = "ghostty/themes/Glass-Day";
      ".config/ghostty/themes/Glass-Light" = "ghostty/themes/Glass-Light";
    };

    environment.sessionVariables = {
      BAT_THEME = "Catppuccin Mocha";
      BAT_CACHE_PATH = "${batCache}";
      MANPAGER = "batman";
      FZF_DEFAULT_OPTS = concatStringsSep " " [
        "--no-sort"
        "--reverse"
        "--margin=0,1"
        "--exit-0"
        "--select-1"
        "--pointer '▸▹'"
        "--prompt '• '"
        "--color 'bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284,fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf,marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284,selected-bg:#51576d,border:#414559,label:#c6d0f5'"
      ];
    };
  };
}
