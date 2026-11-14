# Fish module in moni-dz style: declarative shell settings, integrations, and packages
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.fish;

  # Link individual conf.d files so rum-environment-variables.fish is not clobbered
  confDFiles = lib.pipe (builtins.readDir ../../config/fish/conf.d) [
    (lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".fish" name))
    (lib.mapAttrs' (name: _: lib.nameValuePair ".config/fish/conf.d/${name}" "fish/conf.d/${name}"))
  ];
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
      ".config/fish/config.fish" = "fish/config.fish";
      ".config/fish/functions" = "fish/functions";
    }
    // confDFiles;

    packages = with pkgs; [
      fish
      fish-lsp
      eza
      fzf
      ripgrep
    ];
  };
}
