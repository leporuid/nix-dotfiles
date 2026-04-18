{ inputs, pkgs, config, lib, flake, self, ... }:
let
  username = "leporuid";
in
{
  imports = [
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.fish-environment
    inputs.self.darwinModules.homebrew
    inputs.home-manager.darwinModules.home-manager
  ];

  nixpkgs.overlays = [
    (import ../../overlays/default.nix { inherit inputs; })
  ];
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {
      inherit inputs self flake username;
    };
    users.${username} = "${flake}/hosts/MagiHoHo/users/leporuid/home-configuration.nix";
  };

  networking.hostName = "MagiHoHo";
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  users.users.${username} = {
    description = "Yu-Min Peng";
    home = "/Users/${username}";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaZLCaoAppOpXqJmBrB8AOCEc7zffCWU3G0P+9W4tnL"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrcoI6oOTch+FI7XVlJ5eYJaGx4ZO2noO9GcXVFMhn9"
    ];
    openssh.authorizedKeys.keyFiles = [
      ./users/leporuid/id_ed25519.pub
      ./id_ed25519.pub
    ];
  };

  services.tailscale.enable = true;
  services.openssh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  environment.systemPackages = [
    pkgs.fish
  ];

  system.primaryUser = username;
  system.stateVersion = 6;

  nix.enable = !config.determinateNix.enable;

  nix.channel.enable = false;
}