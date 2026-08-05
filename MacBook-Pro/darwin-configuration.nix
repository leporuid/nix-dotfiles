{ inputs, pkgs, config, lib, flake, self, perSystem, ... }:
{
  imports = [
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.fish-environment
    inputs.self.darwinModules.homebrew
  ];

  

  networking.hostName = "MacBook-Pro";
   
   
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  services.openssh.enable = true;

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true; # Enable sudo authentication with Touch ID
    reattach = true; # This fixes Touch ID for sudo not working inside tmux and screen.
  };

  environment.systemPackages = [
    pkgs.fish
   ];

  system.primaryUser = "leporuid";  
  nix.enable = !config.determinateNix.enable;

  nix.channel.enable = false;
  nix.nixPath = lib.mkForce [
      "nixpkgs=${inputs.nixpkgs}"
      "home-manager=${inputs.home-manager}"
    ];
  system.stateVersion = 6;
}