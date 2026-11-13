{
  inputs,
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

    package = mkPackageOption inputs.helix.packages.${pkgs.stdenv.hostPlatform.system} "helix" {
      default = "helix";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    my.config.source = {
      ".config/helix" = "helix";
    };
  };
}
