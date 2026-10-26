{
  lib,
  pkgs,
  inputs,
  flake,
  vars,
  ...
}:

let
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
    ./hardware-configuration.nix
    ./disk-config.nix

    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko

    inputs.self.modules.common.vars
    inputs.self.nixosModules.age-secrets
    inputs.self.nixosModules.auto-upgrade
    inputs.self.nixosModules.base
    inputs.self.nixosModules.essentials
    inputs.self.nixosModules.fail2ban
    inputs.self.nixosModules.firewall-base
    inputs.self.nixosModules.observability
    inputs.self.nixosModules.programs
    inputs.self.nixosModules.ssh-hardening
    inputs.self.nixosModules.tailscale
    # inputs.self.nixosModules.tailzero
  ];

  oci.efi = true;
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };

    kernel.sysctl = {
      "net.core.devconf_inherit_init_net" = 1;
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.all.route_localnet" = lib.mkDefault 1;
      "net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
    };
  };

  fileSystems."/".device =
    lib.mkForce "/dev/disk/by-partlabel/disk-main-root";

  fileSystems."/boot".device =
    lib.mkForce "/dev/disk/by-partlabel/disk-main-boot";

  fileSystems."/boot".options = [
    "umask=0077"
  ];

  systemd.targets.multi-user.enable = true;

  networking = {
    hostName = vars.hostname;
    useNetworkd = true;
    useDHCP = true;
    iproute2.enable = true;
    nftables.enable = true;
  };

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
  };

  services.vnstat.enable = true;

  time.timeZone = vars.timezone;
  i18n.defaultLocale = vars.locale;

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.bashInteractive;
    users.${vars.username} = {
      isNormalUser = true;
      shell = pkgs.bashInteractive;
      extraGroups = [
        "wheel"
      ];
      hashedPassword = "!";
      openssh.authorizedKeys = {
        keys = vars.sshKeys;
        keyFiles = vars.sshKeyFiles;
      };
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
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  system.stateVersion = "24.11";
}
