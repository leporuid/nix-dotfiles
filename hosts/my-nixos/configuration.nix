{ pkgs, inputs, ... }:
{
  imports = [ inputs.self.nixosModules.host-shared ];

  nixpkgs.hostPlatform = "x86_64-linux";

  users.users.me.isNormalUser = true;

  boot.loader.grub.enable = pkgs.lib.mkDefault false;
  fileSystems."/" = {
    device = pkgs.lib.mkDefault "/dev/null";
    fsType = pkgs.lib.mkDefault "ext4";
  };

  system.stateVersion = "25.05";
}
