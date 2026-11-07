# Declarative terminal themes, Bat Catppuccin Mocha theme, and styled tool variables.
{
  pkgs,
  flake,
  lib,
  ...
}:
let
  glass = {
    background = "#181827";
    foreground = "#c9d8f5";
    cursor-color = "#fbe37e";
    cursor-text = "#181827";
    selection-background = "#2f2254";
    selection-foreground = "#c9d8f5";
    palette = [
      "0=#23223a"
      "1=#ec6a88"
      "2=#a6e3a1"
      "3=#fbe37e"
      "4=#8bc1fa"
      "5=#a7b6fc"
      "6=#6ae9eb"
      "7=#c9d8f5"
      "8=#585b70"
      "9=#ec6a88"
      "10=#accea1"
      "11=#fbe37e"
      "12=#a7b6fc"
      "13=#cba6f7"
      "14=#7beff7"
      "15=#ffffff"
    ];
  };
in
{
  # =========================================================================
  # 1. Ghostty Theme (Native AttrSet with Merging via my.config.text)
  # =========================================================================
  my.config.text = {
    ".config/ghostty/themes/Glass" = glass;
  };

  # =========================================================================
  # 2. Bat Theme
  # =========================================================================
  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Mocha";
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batgrep
      batwatch
    ];
    syntaxes = { };
    themes."Catppuccin Mocha" = {
      src = "${flake}/config/bat";
      file = "themes/Catppuccin Mocha.tmTheme";
    };
  };

  # =========================================================================
  # 3. Environment Variables
  # =========================================================================
  home.sessionVariables = {
    BAT_THEME = "Catppuccin Mocha";
    MANPAGER = "batman";
    FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
      "--no-sort"
      "--reverse"
      "--margin=0,1"
      "--exit-0"
      "--select-1"
      "--pointer '▸▹'"
      "--prompt '• '"
      "--color 'bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284,fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf,marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284,selected-bg:#51576d,border:#414559,label:#c6d0f5'"
    ];
  };
}
