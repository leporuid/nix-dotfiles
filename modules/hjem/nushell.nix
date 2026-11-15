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
    rum.programs.nushell = {
      enable = true;
      inherit (cfg) package;
      extraConfig = "source ($nu.default-config-dir | path join 'local.nu')";
    };

    packages = [
      pkgs.carapace
    ];

    my.config.source = {
      ".config/nushell/env.nu" = "nushell/env.nu";
      ".config/nushell/local.nu" = "nushell/config.nu";
    };
  };
}
