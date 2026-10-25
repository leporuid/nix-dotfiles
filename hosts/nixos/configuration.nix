{
  pkgs,
  lib,
  inputs,
  flake,
  modulesPath,
  ...
}:

let
  vars = import ./vars.nix;

  agenixPkg =
    (inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      ageBin = "${pkgs.rage}/bin/rage";
    }).overrideAttrs
      (_: {
        # agenix's upstream checks currently fail with the rage backend used here.
        doCheck = false;
        doInstallCheck = false;
      });
in
{
  imports = [
    (modulesPath + "/virtualisation/oci-common.nix")
    ./hardware-configuration.nix
    ./disk-config.nix

    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko

    inputs.self.nixosModules.programs
    inputs.self.nixosModules.age-secrets
    inputs.self.nixosModules.auto-upgrade
    inputs.self.nixosModules.base
    inputs.self.nixosModules.essentials
    inputs.self.nixosModules.fail2ban
    inputs.self.nixosModules.firewall-base
    inputs.self.nixosModules.observability
    inputs.self.nixosModules.ssh-hardening
    inputs.self.nixosModules.tailscale
    inputs.self.nixosModules.tailzero
  ];
  
   fileSystems."/".device =
    lib.mkForce "/dev/disk/by-partlabel/disk-main-root";

  fileSystems."/boot".device =
    lib.mkForce "/dev/disk/by-partlabel/disk-main-boot";

  fileSystems."/boot".options = [
    "umask=0077"
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };

  networking = {
    hostName = vars.hostname;
    useNetworkd = true;
    useDHCP = true;
  };

  systemd.network.wait-online.anyInterface = true;
  services.resolved.enable = true;

  time.timeZone = vars.timezone;
  i18n.defaultLocale = vars.locale;
   users.
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.bashInteractive;

    users.${vars.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = "!";
      openssh.authorizedKeys.keys = vars.sshKeys;
      shell = pkgs.bashInteractive;
      openssh.authorizedKeys.keyFiles = [
      "${flake}/hosts/MacBook-Pro/users/leporuid/id_ed25519.pub"
       "${flake}/hosts/MacBook-Pro/id_ed25519.pub"
       "${flake}/hosts/nixos/id_ed25519.pub"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  security.sudo.extraRules = [
    {
      users = [ vars.username ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.systemPackages = with pkgs; [
    age
    rage
    agenixPkg
  ];

  environment.etc."configuration-revision".text = flake.rev or flake.dirtyRev or "unknown";

  services.getty.autologinUser = null;

  documentation.enable = false;

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.registry.self.flake = flake;

  age.secrets.tailscale-oracle.file = ./tailscale-oracle.age;
  # networking.interfaces.enp0s6.useDHCP = lib.mkDefault true;
  oci.efi = true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  system.stateVersion = "24.11";
}
