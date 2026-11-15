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

    # Starship only selects a profile through `--profile` (STARSHIP_PROFILE is
    # ignored) and Nushell has no transient prompt, so Nushell gets the
    # single-line [profiles.nu] format. The prompt commands are defined here
    # instead of using `starship init nu`: the init's export-env is merged at the
    # end of the config file and would clobber any override.
    rum.programs.nushell.extraConfig = lib.mkAfter ''
      $env.STARSHIP_SHELL = "nu"
      $env.STARSHIP_SESSION_KEY = (random chars --length 16)
      $env.PROMPT_INDICATOR = ""
      $env.PROMPT_MULTILINE_INDICATOR = { ||
          ^${lib.getExe cfg.package} prompt --continuation
      }

      let starship_duration = { ||
          if $env.CMD_DURATION_MS == "0823" { "0" } else { $env.CMD_DURATION_MS }
      }

      $env.PROMPT_COMMAND = { ||
          ^${lib.getExe cfg.package} prompt --profile nu $"--cmd-duration=(do $starship_duration)" $"--status=($env.LAST_EXIT_CODE)" --terminal-width (term size).columns
      }

      $env.PROMPT_COMMAND_RIGHT = { ||
          ^${lib.getExe cfg.package} prompt --right $"--cmd-duration=(do $starship_duration)" $"--status=($env.LAST_EXIT_CODE)" --terminal-width (term size).columns
      }

      $env.config = ($env.config | merge { render_right_prompt_on_last_line: true })
    '';

    my.config.source = {
      ".config/starship.toml" = "starship.toml";
    };
  };
}
