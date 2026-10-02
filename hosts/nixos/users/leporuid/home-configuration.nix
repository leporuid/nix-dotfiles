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

  imports = [ "${flake}/users/${config.home.username}/home-configuration.nix" ];

  home.sessionVariables = {
    # My fish configuration uses this to check whether it should check if
    # the Touch ID PAM module is enabled. See: config/fish/functions/fish_greeting.fish
    FISH_GREETING_CHECK_SUDO_TOUCHID = "1";
  };
}