{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.my.programs.nushell;
in
{
  options.my.programs.nushell = {
    enable = mkEnableOption "Nushell configuration via Hjem";

    package = mkPackageOption pkgs "nushell" {
      default = "nushell";
    };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
      pkgs.carapace
    ];

    my.config.source = {
      ".config/nushell" = "nushell";
    };
  };
}
