# Fish module in moni-dz style: declarative shell settings, integrations, and packages
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.attrsets) filterAttrs mapAttrs' nameValuePair;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.strings) hasSuffix;
  inherit (lib.trivial) pipe;

  cfg = config.my.programs.fish;

  # Link individual conf.d files so rum-environment-variables.fish is not clobbered
  confDFiles = pipe (builtins.readDir ../../config/fish/conf.d) [
    (filterAttrs (name: type: type == "regular" && hasSuffix ".fish" name))
    (mapAttrs' (name: _: nameValuePair ".config/fish/conf.d/${name}" "fish/conf.d/${name}"))
  ];
in
{
  options.my.programs.fish = {
    enable = mkEnableOption "Fish shell configuration" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
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
