{ config, pkgs, inputs, self, ... }: 
{
  system.stateVersion = "26.05";
  imports = [
     inputs.determinate.nixosModules.default
    "${inputs.nixpkgs}/nixos/modules/virtualisation/oci-image.nix"
  ];
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.cloud-init.enable = true;
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.buildPlatform = "aarch64-darwin";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaZLCaoAppOpXqJmBrB8AOCEc7zffCWU3G0P+9W4tnL"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrcoI6oOTch+FI7XVlJ5eYJaGx4ZO2noO9GcXVFMhn9"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyz8c5h0/9ejDcYYkUZ568FUw0OAQEPfRnIbbbd4xGe"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAIJNFFaMxFGkxbzGvTtFfu+DPlxtqK0NoaExRVDvCt"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7u84aJ0ObCzO1tbh6VccXpqUMVU+Y5nUzf7/w9Vv8k"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDk311ALajXHKtFUSPfuCiN9i4Spe02kRM1x9VSoBOnL"
    ];
  };
  #boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  security.sudo.wheelNeedsPassword = false;
}