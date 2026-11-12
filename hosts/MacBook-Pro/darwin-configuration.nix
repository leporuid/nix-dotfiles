{
  pkgs,
  inputs,
  lib,
  vars,
  ...
}:
{
  imports = [
    inputs.determinate.darwinModules.default
    inputs.hjem.darwinModules.default
    ../../modules/shared/vars.nix
    ../../modules/darwin
    ../../modules/nixos/host-shared.nix
  ];

  # =========================================================================
  # moni-dz style feature modules
  # =========================================================================
  my.darwin.system.enable = true;
  my.darwin.applications.enable = true;

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
  ids.gids.nixbld = 350;

  users.users.${vars.username} = {
    inherit (vars) description;
    home = vars.homeDirectory;
    shell = pkgs.fish;
    openssh.authorizedKeys = {
      keys = vars.sshKeys;
      keyFiles = vars.sshKeyFiles;
    };
  };

  services.openssh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  # Determinate Nix owns the daemon and nix.conf; disable nix-darwin's Nix management
  # completely to prevent both from competing over /etc/nix/nix.conf and launchd.
  nix.enable = false;
  nix.channel.enable = false;
  nix.nixPath = lib.mkForce [ ];

  hjem = {
    clobberByDefault = true;
    extraModules = [
      inputs.hjem-rum.hjemModules.default
      inputs.hjem-impure.hjemModules.default
    ];
  };

  hjem.users.${vars.username} =
    { ... }:
    {
      directory = vars.homeDirectory;
      imports = [ ../../users/leporuid/home-configuration.nix ];
    };
}
