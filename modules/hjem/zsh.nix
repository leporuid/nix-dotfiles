{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.my.programs.zsh;
in
{
  options.my.programs.zsh = {
    enable = mkEnableOption "Zsh login handoff and Sheldon plugin manager via Hjem";
  };

  config = mkIf cfg.enable {
    packages = [ pkgs.sheldon ];

    my.config.source = {
      ".config/sheldon" = "sheldon";
      ".config/zsh" = "zsh";
      ".zshenv" = "zsh/home_zshenv";
    };

    environment.sessionVariables = {
      ZDOTDIR = "${config.directory}/.config/zsh";
    };

    files = {
      ".local/share/zsh/hm-session-vars.sh".source = config.environment.loadEnv;
    };
  };
}
