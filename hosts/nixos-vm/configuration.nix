{
  pkgs,
  modulesPath,
  vars,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ../../modules/nixos
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
  # Throwaway test VM without sshd: passwordless login is acceptable here.
  users.users.${vars.username} = {
    isNormalUser = true;
    shell = pkgs.bashInteractive;
    extraGroups = [ "wheel" ];
    hashedPassword = "";
  };
  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = vars.username;
  virtualisation = {
    cores = 2;
    memorySize = 2048;
    graphics = false;
  };
  system.stateVersion = "25.05";
}
