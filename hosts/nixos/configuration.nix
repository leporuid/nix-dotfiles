{
  pkgs,
  inputs,
  flake,
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
    ./hardware-configuration.nix
    ./disk-config.nix
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko

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

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    #initrd.systemd.enable = true;
  };

  fileSystems."/boot".options = [ "umask=0077" ];
  systemd.targets.multi-user.enable = true;

  networking.hostName = vars.hostname;
  networking.networkmanager.enable = true;
  time.timeZone = vars.timezone;
  i18n.defaultLocale = vars.locale;

  users.mutableUsers = false;
  users.users.${vars.username} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = vars.sshKeys;
    shell = pkgs.bashInteractive;
  };

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

  environment.etc."configuration-revision".text = flake.rev or flake.dirtyRev;

  environment.sessionVariables = {
    TERM = "linux";
  };

  services.getty.autologinUser = null;
  documentation.enable = false;

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.registry.self.flake = flake;
  age.secrets.tailscale-oracle.file = ./tailscale-oracle.age;
  system.stateVersion = "26.11";
}
