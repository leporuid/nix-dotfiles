{
  inputs,
  pkgs,
  config,
  lib,
  flake,
  ...
}:
{
  imports = [
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.fish-environment
    inputs.self.darwinModules.homebrew
  ];

  networking.hostName = "MacBook-Pro";
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "leporuid";
  system.stateVersion = 6;

  users.users."${config.system.primaryUser}" = {
    description = "Yu-Min Peng";
    home = "/Users/${config.system.primaryUser}";
    openssh.authorizedKeys = {
      keys = [
        # My iPhone, blink terminal
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGr7upNdIAAtGkiQaUkCaj5g6QW843fL3bbsJyP/0tAB"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrcoI6oOTch+FI7XVlJ5eYJaGx4ZO2noO9GcXVFMhn9"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyz8c5h0/9ejDcYYkUZ568FUw0OAQEPfRnIbbbd4xGe"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAIJNFFaMxFGkxbzGvTtFfu+DPlxtqK0NoaExRVDvCt"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBN6rDDWpOzuVy7v8foYFJdjlcNJBZpmZcwZWWhoa3dbprqJGRClVKyg1NYNj1a3D43XvxeA+Vd1AgaAQDrSIbIE= #SSH ID - @leporuid"
      ];
      keyFiles = [
        "${flake}/hosts/MacBook-Pro/users/leporuid/id_ed25519.pub"
        "${flake}/hosts/MacBook-Pro/id_ed25519.pub"
        "${flake}/hosts/nixos/id_ed25519.pub"
      ];
    };
  };

  services.openssh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  nix.enable = !config.determinateNix.enable;
  nix.channel.enable = false;
}
