{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.direnv-instant;
  pkg = inputs.direnv-instant.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options.my.programs.direnv-instant = {
    enable = lib.mkEnableOption "direnv-instant non-blocking shell integration" // {
      default = true;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkg;
      description = "The direnv-instant package to use.";
    };
    useCache = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply cached env instantly on prompt.";
    };
    muxDelay = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Seconds before opening multiplexer split.";
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [ cfg.package ];

    # Fish shell integration: auto-loads from vendor_conf.d
    files.".local/share/fish/vendor_conf.d/direnv-instant.fish".text = ''
      if status is-interactive
        set -gx DIRENV_INSTANT_USE_CACHE ${if cfg.useCache then "1" else "0"}
        set -gx DIRENV_INSTANT_MUX_DELAY ${toString cfg.muxDelay}
        ${cfg.package}/bin/direnv-instant hook fish | source
      end
    '';
  };
}
