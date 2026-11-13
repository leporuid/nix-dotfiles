{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.my.programs.tmux;
in
{
  options.my.programs.tmux = {
    enable = mkEnableOption "tmux terminal multiplexer configuration via Hjem";

    package = mkPackageOption pkgs "tmux" {
      default = "tmux";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    my.config.source = {
      ".config/tmux" = "tmux";
    };
  };
}
