{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  sshKeys = import ../../users/leporuid/ssh-keys.nix;
in
{
  imports = [
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.fish-environment
    inputs.self.darwinModules.homebrew
  ];

  networking.hostName = "MacBook-Pro";

  system.primaryUser = "leporuid";
  system.stateVersion = 1;

  users.users."${config.system.primaryUser}" = {
    description = "Yu-Min Peng";
    home = "/Users/${config.system.primaryUser}";
    openssh.authorizedKeys = {
      keys = sshKeys.authorizedKeys;
      keyFiles = sshKeys.keyFiles;
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  services.openssh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  environment.systemPackages = [
    pkgs.fish
  ];

  nix.enable = !config.determinateNix.enable;
  nix.channel.enable = false;

  nix.nixPath = lib.mkForce [
    "nixpkgs=${inputs.nixpkgs}"
    "home-manager=${inputs.home-manager}"
  ];
}
