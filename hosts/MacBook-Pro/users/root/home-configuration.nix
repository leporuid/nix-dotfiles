{
  flake,
  config,
  pkgs,
  lib,
  inputs,
  perSystem,
  ...
}: {
  home.stateVersion = "26.05";

  imports = [
    "${flake}/users/leporuid/shared.nix"
  ];

  home.sessionVariables = {
    FISH_GREETING_CHECK_SUDO_TOUCHID = "1";
  };

  my.config.directory = "/Users/leporuid/Developer/nix-dotfiles";
}