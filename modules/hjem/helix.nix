{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.my.programs.helix;
in
{
  options.my.programs.helix = {
    enable = mkEnableOption "Helix editor configuration via Hjem";

    package = mkPackageOption pkgs "helix" { };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    my.config.source = {
      ".config/helix" = "helix";
    };
  };
}
