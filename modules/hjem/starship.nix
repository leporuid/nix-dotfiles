{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.my.programs.starship;
in
{
  options.my.programs.starship = {
    enable = mkEnableOption "Starship prompt configuration via Hjem";

    package = mkPackageOption pkgs "starship" {
      default = "starship";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    environment.sessionVariables = {
      STARSHIP_CONFIG = "${config.directory}/.config/starship.toml";
    };

    my.config.source = {
      ".config/starship.toml" = "starship.toml";
    };
  };
}
