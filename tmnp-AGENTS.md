{
  config,
  lib,
  pkgs,
  inputs,
  osConfig ? { },
  ...
}:
let
  cfg = config.my.programs.nixcord;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # Vencord / Vesktop 設定檔的目標相對路徑
  vencordConfigPath =
    if isDarwin then
      "Library/Application Support/Vencord/settings/settings.json"
    else
      ".config/Vencord/settings/settings.json";

  # 預設 settings 結構（亦可藉由 formats.json 序列化）
  settingsJson = (pkgs.formats.json { }).generate "vencord-settings.json" {
    autoUpdate = false;
    autoUpdateNotification = false;
    useQuickCss = cfg.quickCss != "";
    themeLinks = cfg.themeLinks;
    enabledThemes = cfg.enabledThemes;
    plugins = cfg.plugins;
  };
in
{
  options.my.programs.nixcord = {
    enable = lib.mkEnableOption "Declarative Vencord/Discord configuration via Hjem";

    package = lib.mkOption {
      type = lib.types.package;
      default = if isDarwin then pkgs.discord else pkgs.vesktop;
      description = "The Discord or Vesktop package to install.";
    };

    plugins = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Vencord plugins and their individual toggle/options.";
    };

    quickCss = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Direct Custom CSS for Vencord.";
    };

    themeLinks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Remote CSS theme URLs.";
    };

    enabledThemes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Names of local or enabled themes.";
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [ cfg.package ];

    files = {
      "${vencordConfigPath}".source = settingsJson;
    } // lib.optionalAttrs (cfg.quickCss != "") {
      ${if isDarwin then
        "Library/Application Support/Vencord/settings/quickCss.css"
      else
        ".config/Vencord/settings/quickCss.css"}.text = cfg.quickCss;
    };
  };
}