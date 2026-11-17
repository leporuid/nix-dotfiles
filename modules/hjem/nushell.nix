{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  cfg = config.my.programs.nushell;
in
{
  options.my.programs.nushell = {
    enable = mkEnableOption "Nushell configuration via Hjem";

    package = mkPackageOption pkgs "nushell" { };
  };

  config = mkIf cfg.enable (mkMerge [
    {
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
    }
    # Mirror Nushell files into Application Support on macOS so GUI-launched
    # sessions without XDG_CONFIG_HOME inherit the exact same configuration.
    (mkIf isDarwin {
      my.config.source = {
        "Library/Application Support/nushell/env.nu" = "nushell/env.nu";
        "Library/Application Support/nushell/local.nu" = "nushell/config.nu";
      };

      files."Library/Application Support/nushell/config.nu" = {
        inherit (config.xdg.config.files."nushell/config.nu") source;
      };
    })
  ]);
}
