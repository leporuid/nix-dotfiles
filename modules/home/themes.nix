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
  };
}
