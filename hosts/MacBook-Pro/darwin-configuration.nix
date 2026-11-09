{
  inputs,
  pkgs,
  config,
  lib,
  vars,
  ...
}:
{
  imports = [
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.fish-environment
    inputs.self.darwinModules.applications
  ];

  networking.hostName = vars.hostname;
  networking.computerName = "🐰MacBook Pro";
  networking.localHostName = vars.hostname;
  networking.knownNetworkServices = [
    "Wi-Fi"
    "Thunderbolt Bridge"
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = vars.username;
  system.stateVersion = 6;

  users.users.${vars.username} = {
    inherit (vars) description;
    home = vars.homeDirectory;
    openssh.authorizedKeys = {
      keys = vars.sshKeys;
      keyFiles = vars.sshKeyFiles;
    };
  };

  services.openssh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  nix.enable = !config.determinateNix.enable;
  nix.channel.enable = false;
  nix.nixPath = lib.mkForce [ ];
}
