{
  config,
  lib,
  perSystem,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool int package;

  cfg = config.my.programs.direnv-instant;
in
{
  options.my.programs.direnv-instant = {
    enable = mkEnableOption "direnv-instant non-blocking shell integration" // {
      default = true;
    };
    package = mkOption {
      type = package;
      default = perSystem.direnv-instant.default;
      description = "The direnv-instant package to use.";
    };
    useCache = mkOption {
      type = bool;
      default = true;
      description = "Apply cached env instantly on prompt.";
    };
    muxDelay = mkOption {
      type = int;
      default = 4;
      description = "Seconds before opening multiplexer split.";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    # Fish shell integration: auto-loads from vendor_conf.d
    files.".local/share/fish/vendor_conf.d/direnv-instant.fish".text = ''
      if status is-interactive
        set -gx DIRENV_INSTANT_USE_CACHE ${if cfg.useCache then "1" else "0"}
        set -gx DIRENV_INSTANT_MUX_DELAY ${toString cfg.muxDelay}
        ${getExe cfg.package} hook fish | source
      end
    '';
  };
}
