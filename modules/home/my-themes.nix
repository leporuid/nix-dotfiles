# Declarative terminal themes, Bat Catppuccin Mocha theme, and styled tool variables.
{
  pkgs,
  flake,
  lib,
  ...
}:
{
  # =========================================================================
  # 1. Ghostty Theme (Native Base File + Merging via my.config.source)
  # =========================================================================
  my.config.source = {
    # Uses config/ghostty/themes/Glass as the base file, fully supporting lib.mkMerge and overrides
    ".config/ghostty/themes/Glass" = {
      base = "config/ghostty/themes/Glass";
    };
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
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "main";
        hash = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
      };
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
