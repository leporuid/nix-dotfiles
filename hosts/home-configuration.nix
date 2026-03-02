{
  flake,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.stateVersion = "26.05";

  imports = [ 
    "${flake}/users/leporuid/shared-configuration.nix" 
    inputs.agenix.homeManagerModules.default
 ];

  home.sessionVariables = {
    # My fish configuration uses this to check whether it should check if
    # the Touch ID PAM module is enabled. See: config/fish/functions/fish_greeting.fish
    FISH_GREETING_CHECK_SUDO_TOUCHID = "1";
  };

  my.config.directory = "${config.home.homeDirectory}/Developer/nix-dotfiles";
  age = {
    identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" "/etc/ssh/ssh_host_ed25519_key"];
    secrets.tailscale-authkey.file = ./tailscale-authkey.age;
  };
}