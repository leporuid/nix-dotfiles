{
  config,
  lib,
  pkgs,
  perSystem,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.my.programs.git;
in
{
  options.my.programs.git = {
    enable = mkEnableOption "Git and companion CLI tools configuration via Hjem";

    package = mkPackageOption pkgs "git" { };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
      pkgs.lazygit
      pkgs.delta
      pkgs.gh
      pkgs.git-open
      perSystem.self.comview
    ];

    my.config.source = {
      ".config/git" = "git";
    };
  };
}
