{ pkgs, inputs, ... }:
{
  imports = [
    inputs.hjem.nixosModules.default
    inputs.hjem-rum.nixosModules.default
    ../../modules/nixos/host-shared.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  users.users.leporuid.isNormalUser = true;

  # Template host: disable initrd to prevent APFS terminfo case-collision on macOS hosts
  boot.loader.grub.enable = pkgs.lib.mkDefault false;
  boot.initrd.enable = pkgs.lib.mkDefault false;

  fileSystems."/" = {
    device = pkgs.lib.mkDefault "/dev/null";
    fsType = pkgs.lib.mkDefault "ext4";
  };

  hjem.users.leporuid =
    { ... }:
    {
      imports = [ ../../users/leporuid/home-configuration.nix ];
    };

  system.stateVersion = "25.05";
}
