# Fish module in moni-dz style: declarative shell settings, integrations, and packages
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.fish;
in
{
  options.my.programs.fish = {
    enable = lib.mkEnableOption "Fish shell configuration" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    rum.programs.fish.enable = true;

    my.config.source = {
      ".config/fish/completions" = "fish/completions";
      ".config/fish/conf.d" = "fish/conf.d";
      ".config/fish/config.fish" = "fish/config.fish";
      ".config/fish/functions" = "fish/functions";
    };

    packages = with pkgs; [
      fish
      fish-lsp
      eza
      fzf
      ripgrep
    ];
  };
}
