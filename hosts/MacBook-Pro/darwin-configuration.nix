{ inputs, pkgs, config, lib, flake, self, perSystem, ... }:
{
  imports = [
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.fish-environment
    inputs.self.darwinModules.homebrew
  ];

  networking.hostName = "MacBook-Pro";

  system.primaryUser = "leporuid";
 
  users.users."${config.system.primaryUser}" = {
    description = "Yu-Min Peng";
    home = "/Users/${config.system.primaryUser}";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaZLCaoAppOpXqJmBrB8AOCEc7zffCWU3G0P+9W4tnL"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrcoI6oOTch+FI7XVlJ5eYJaGx4ZO2noO9GcXVFMhn9"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyz8c5h0/9ejDcYYkUZ568FUw0OAQEPfRnIbbbd4xGe"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAIJNFFaMxFGkxbzGvTtFfu+DPlxtqK0NoaExRVDvCt"
    ];
    openssh.authorizedKeys.keyFiles = [
      "${flake}/hosts/${config.networking.hostName}/users/leporuid/id_ed25519.pub"
      "${flake}/hosts/${config.networking.hostName}/id_ed25519.pub"
    ];
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

  system.stateVersion = 1;
}