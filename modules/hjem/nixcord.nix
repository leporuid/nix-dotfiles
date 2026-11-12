{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.my.programs.nixcord;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # Base directory for Vencord on macOS vs Linux
  vencordDir =
    if isDarwin then
      "Library/Application Support/Vencord"
    else
      ".config/Vencord";

  # Base directory for Vesktop on macOS vs Linux
  vesktopDir =
    if isDarwin then
      "Library/Application Support/vesktop"
    else
      ".config/vesktop";

  # Synthesize Vencord settings JSON
  vencordSettings =
    {
      notifyAboutUpdates = false;
      autoUpdate = false;
      autoUpdateNotification = false;
      useQuickCss = cfg.config.useQuickCss;
      themeLinks = cfg.config.themeLinks;
      enabledThemes = cfg.config.enabledThemes;
      enableReactDevtools = false;
      frameless = false;
      transparent = false;
      plugins = cfg.config.plugins;
    }
    // cfg.config.extraConfig;

  settingsJson = (pkgs.formats.json { }).generate "vencord-settings.json" vencordSettings;

  vencordFiles =
    lib.optionalAttrs cfg.discord.vencord.enable {
      "${vencordDir}/settings/settings.json".source = settingsJson;
    }
    // lib.optionalAttrs (cfg.config.useQuickCss && cfg.config.quickCss != "") {
      "${vencordDir}/settings/quickCss.css".text = cfg.config.quickCss;
    };

  vesktopFiles =
    lib.optionalAttrs cfg.vesktop.enable {
      "${vesktopDir}/settings.json".source = settingsJson;
    }
    // lib.optionalAttrs (cfg.config.useQuickCss && cfg.config.quickCss != "") {
      "${vesktopDir}/settings/quickCss.css".text = cfg.config.quickCss;
    };
in
{
  options.my.programs.nixcord = {
    enable = lib.mkEnableOption "nixcord / Vencord declarative Discord configuration";

    package = lib.mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Optional Discord or Vesktop package to install in user profile.";
    };

    discord = {
      enable = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether to configure Discord.";
      };
      vencord.enable = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether to configure Vencord settings for Discord.";
      };
    };

    vesktop = {
      enable = lib.mkOption {
        type = types.bool;
        default = false;
        description = "Whether to configure Vesktop settings.";
      };
    };

    config = {
      useQuickCss = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable QuickCSS.";
      };

      quickCss = lib.mkOption {
        type = types.lines;
        default = "";
        description = "Custom CSS injected into Vencord.";
      };

      themeLinks = lib.mkOption {
        type = types.listOf types.str;
        default = [
          "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css"
        ];
        description = "List of remote theme CSS URLs.";
      };

      enabledThemes = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of local theme names.";
      };

      plugins = lib.mkOption {
        type = types.attrsOf types.anything;
        default = {
          alwaysTrust.enable = true;
          betterFolders.enable = true;
          betterSettings.enable = true;
          callTimer.enable = true;
          copyUserUrls.enable = true;
          directFileDownload.enable = true;
          experiments.enable = true;
          fakeNitro.enable = true;
          messageLogger.enable = true;
          openInApp.enable = true;
          pictureInPicture.enable = true;
          previewMessage.enable = true;
          relationshipNotifier.enable = true;
          translate.enable = true;
          volumeBooster.enable = true;
        };
        description = "Vencord plugins configuration attribute set.";
      };

      extraConfig = lib.mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Extra key-value pairs merged into settings.json.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    packages = lib.optional (cfg.package != null) cfg.package;
    files = vencordFiles // vesktopFiles;
  };
}
