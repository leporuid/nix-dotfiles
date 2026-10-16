{
  flake,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.stateVersion = "26.11";

  imports = [ "${flake}/users/leporuid/home-configuration.nix" ];

  my.config.directory = "${config.home.homeDirectory}/Developer/nix-dotfiles";
}