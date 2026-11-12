{ pkgs, ... }:
{
  imports = [ ../../modules/nixos/host-shared.nix ];

  nixpkgs.hostPlatform = "x86_64-linux";

  users.users.me.isNormalUser = true;

  # Template host: disable initrd to prevent APFS terminfo case-collision on macOS hosts
  boot.loader.grub.enable = pkgs.lib.mkDefault false;
  boot.initrd.enable = pkgs.lib.mkDefault false;

  fileSystems."/" = {
    device = pkgs.lib.mkDefault "/dev/null";
    fsType = pkgs.lib.mkDefault "ext4";
  };

  system.stateVersion = "25.05";
}
