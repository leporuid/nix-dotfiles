{ config, pkgs, lib, perSystem, inputs, flake, ... }@args:
{
  imports = [
    ./shared.nix
  ];

  home.sessionVariables = {
    BAT_THEME = "Catppuccin Mocha";
    JJ_CONFIG = "${config.home.homeDirectory}/.config/jj/config.toml";
  };

  my.config.source =
   let
     platformConfig = if pkgs.stdenv.hostPlatform.isDarwin then "Library/Application Support" else ".config";
   in
   {
    ".config/starship.toml" = "config/starship.toml";
    ".config/zellij" = "config/zellij";
  };

  home.packages = with pkgs; [
    bat
    bun
    starship
    uv
    zellij
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