{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.my.programs.direnv;
in
{
  options.my.programs.direnv = {
    enable = mkEnableOption "direnv and nix-direnv configuration via Hjem";

    package = mkPackageOption pkgs "direnv" { };

    nixDirenvPackage = mkPackageOption pkgs "nix-direnv" { };

    instant = {
      enable = mkEnableOption "direnv-instant non-blocking integration" // {
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
      cfg.nixDirenvPackage
    ];
    my = {
      config.source = {
        ".config/direnv/direnv.toml" = "direnv/direnv.toml";
      };
      programs.direnv-instant.enable = mkDefault cfg.instant.enable;
    };
    files.".config/direnv/lib/nix-direnv.sh".source =
      "${cfg.nixDirenvPackage}/share/nix-direnv/direnvrc";
  };
}
