{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  cfg = config.my.programs.jujutsu;
  configSubdir = if isDarwin then "Library/Application Support/jj" else ".config/jj";
in
{
  options.my.programs.jujutsu = {
    enable = mkEnableOption "Jujutsu VCS configuration via Hjem";

    package = mkPackageOption pkgs "jujutsu" {
      default = "jujutsu";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    environment.sessionVariables = {
      JJ_CONFIG = "${config.directory}/${configSubdir}/config.toml";
    };

    my.config.source = {
      "${configSubdir}" = "jj";
    };
  };
}
