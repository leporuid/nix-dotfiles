{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.my.programs.zellij;
in
{
  options.my.programs.zellij = {
    enable = mkEnableOption "Zellij terminal workspace configuration via Hjem";

    package = mkPackageOption pkgs "zellij" {
      default = "zellij";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    my.config.source = {
      ".config/zellij" = "zellij";
    };
  };
}
