{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  cfg = config.my.programs.ghostty;
in
{
  options.my.programs.ghostty = {
    enable = mkEnableOption "Ghostty terminal configuration via Hjem";
  };

  config = mkIf cfg.enable {
    my.config.source = {
      ".config/ghostty/config" = "ghostty/config";
      ".config/ghostty/os-config" =
        if isDarwin then "ghostty/os-config-darwin" else "ghostty/os-config-linux";
    };
  };
}
