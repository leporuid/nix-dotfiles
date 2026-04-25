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
    "${flake}/users/leporuid/home-configuration.nix"
  ];

  home.sessionVariables = {
    FISH_GREETING_CHECK_SUDO_TOUCHID = "1";
  };

  my.config.directory = "${config.home.homeDirectory}/Developer/nix-dotfiles";
}