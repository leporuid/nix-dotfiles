{ config, pkgs, lib, perSystem, inputs, flake, ... }@args:
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

  my.config.source =
   let
     platformConfig = if pkgs.stdenv.hostPlatform.isDarwin then "Library/Application Support" else ".config";
   in
   {
    ".config/atuin" = "config/atuin";
    ".config/zellij" = "config/zellij";    
    ".config/raycast" = "config/raycast";
    ".config/ghostty/themes" = "config/ghostty/themes";
    ".config/zed" = "config/zed";
    ".config/starship.toml" = "config/starship.toml";
  };

  home.packages = with pkgs; [
    atuin
    bat
    bun
    ffmpeg
    gallery-dl
    mas
    qpdf
    starship
    uv
    zellij
    perSystem.self.kumono
    perSystem.self.age-plugin-se
    megabasterd
    perSystem.self.unxip
    perSystem.ktoolbox.default
  ];
 
  programs.starship.settings = builtins.fromTOML (builtins.readFile "${flake}/config/starship.toml");

  programs.bat = {
    # Just use the exact string name of the theme
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
        rev = "699f60fc8ec434574ca7451b444b880430319941";
        sha256 = "sha256-6fWoCH90IGumAmc4buLRWL0N61op+AuMNN9CAR9/OdI=";
      };
      file = "themes/Catppuccin Mocha.tmTheme";
    };
  };
}