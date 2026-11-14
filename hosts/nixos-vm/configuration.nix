{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];
  nixpkgs.hostPlatform = "aarch64-linux";
  networking = {
    hostName = "nixos-vm";
    useDHCP = true;
  };
  boot = {
    loader.grub.device = "nodev";
    kernelParams = [
      "console=ttyAMA0,115200n8"
      "console=ttyS0,115200n8"
    ];
  };
  systemd.services."serial-getty@ttyAMA0".enable = false;
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  services.getty.autologinUser = "root";
  virtualisation = {
    cores = 2;
    memorySize = 2048;
    graphics = false;
  };
  system.stateVersion = "25.05";
}
