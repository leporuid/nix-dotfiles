{ config, pkgs, lib, perSystem, ... }@args:
{
  imports = [
    ./shared.nix
  ];

  home.sessionVariables = {
    ATUIN_NOBIND = "true";
    BAT_THEME = "Catppuccin Mocha";
    FZF_DEFAULT_OPTS = "--no-sort --reverse --margin=0,1 --exit-0 --select-1 --pointer ▸▹ --prompt • --color bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284,fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf,marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284,selected-bg:#51576d,border:#414559,label:#c6d0f5";
    JJ_CONFIG = "${config.home.homeDirectory}/.config/jj/config.toml";
  };

  my.config.source = {
    ".config/atuin" = "config/atuin";
    ".config/zellij" = "config/zellij";
    ".config/raycast" = "config/raycast";
    ".config/starship.toml" = "config/starship.toml";
    ".config/lla" = "config/lla";
    ".config/zed" = "config/zed";
  };

  home.packages = [
    pkgs.atuin
    pkgs.bun
    pkgs.bat
    pkgs.lla
    pkgs.starship
    pkgs.uv
    pkgs.ffmpeg
    pkgs.qpdf
    pkgs.zellij
    perSystem.self.kumono
    perSystem.ktoolbox.ktoolbox
    perSystem.self.age-plugin-se
  ];

  programs.bat = {
    config.theme = pkgs.themes.bat;
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batgrep
      batwatch
    ];
    syntaxes = { };
    themes.${pkgs.themes.bat} = {
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "699f60fc8ec434574ca7451b444b880430319941";
        sha256 = "sha256-6fWoCH90IGumAmc4buLRWL0N61op+AuMNN9CAR9/OdI=";
      };
      file = "themes/${pkgs.themes.bat}.tmTheme";
    };
  };
}