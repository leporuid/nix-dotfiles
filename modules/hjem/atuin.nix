{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.my.programs.atuin;
in
{
  options.my.programs.atuin = {
    enable = mkEnableOption "Atuin shell history configuration via Hjem";

    package = mkPackageOption pkgs "atuin" {
      default = "atuin";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    environment.sessionVariables = {
      ATUIN_NOBIND = "true";
    };

    my.config.source = {
      ".config/atuin" = "atuin";
    };
  };
}
