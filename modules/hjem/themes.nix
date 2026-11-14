# Themes module in moni-dz style: Bat precompiled cache, Bat wrapper, and Ghostty themes
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.themes;
  batCache =
    pkgs.runCommand "bat-cache"
      {
        nativeBuildInputs = [ pkgs.bat ];
      }
      ''
        bat cache --build --source "${../../config}/bat" --target "$out"
      '';
in
{
  options.my.themes = {
    enable = lib.mkEnableOption "terminal and editor themes" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [
      (pkgs.writeShellApplication {
        name = "bat";
        runtimeInputs = [ pkgs.bat ];
        text = ''
          export BAT_THEME="Catppuccin Mocha"
          export BAT_CACHE_PATH="${batCache}"
          exec bat "$@"
        '';
      })
      pkgs.bat-extras.batdiff
      pkgs.bat-extras.batman
      pkgs.bat-extras.batgrep
      pkgs.bat-extras.batwatch
    ];

    my.config.source = {
      ".config/ghostty/themes/Glass" = "ghostty/themes/Glass";
    };

    environment.sessionVariables = {
      BAT_THEME = "Catppuccin Mocha";
      BAT_CACHE_PATH = "${batCache}";
      MANPAGER = "batman";
      FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
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
