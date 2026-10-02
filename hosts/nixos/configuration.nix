{ config, lib, pkgs, inputs, flake, ... }:
let
  vars = import ./vars.nix;
  agenixPkg = (inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
     ageBin = "${pkgs.rage}/bin/rage";
   }).overrideAttrs (old: {
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
    
    ../../modules/nixos/age-secrets.nix
    ../../modules/nixos/auto-upgrade.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/essentials.nix
    ../../modules/nixos/fail2ban.nix
    ../../modules/nixos/firewall-base.nix
    ../../modules/nixos/observability.nix
    ../../modules/nixos/ssh-hardening.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/tailzero.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    initrd.systemd.enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  fileSystems."/boot".options = [ "umask=0077" ];
  systemd.targets.multi-user.enable = true;

  networking.hostName = vars.hostname;
  networking.networkmanager.enable = true;
  time.timeZone = vars.timezone;
  i18n.defaultLocale = vars.locale;

  users.mutableUsers = false;
  users.users.${vars.username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = vars.sshKeys;
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

  environment.etc."configuration-revision".text = toString (flake.shortRev or flake.dirtyShortRev or flake.lastModified or "unknown");

  environment.sessionVariables = {
    TERM = "linux";
  };

  services.getty.autologinUser = null;
  documentation.enable = false;

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  
  nix.registry.self.flake = flake;

  system.stateVersion = "26.11";
}