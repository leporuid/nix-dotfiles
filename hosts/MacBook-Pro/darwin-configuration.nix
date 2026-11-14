{
  lib,
  vars,
  ...
}:
{
  imports = [
    ../../modules/darwin
  ];
  my = {
    darwin = {
      # =========================================================================
      # moni-dz style feature modules
      # =========================================================================
      system.enable = true;
      applications.enable = true;
    };
  };
  networking = {
    hostName = vars.hostname;
    computerName = "🐰MacBook Pro";
    localHostName = vars.hostname;
    knownNetworkServices = [
      "Wi-Fi"
      "Thunderbolt Bridge"
    ];
  };
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };
  system = {
    primaryUser = vars.username;
    stateVersion = 6;
  };
  ids.gids.nixbld = 350;
  users.users.${vars.username} = {
    inherit (vars) description;
    home = vars.homeDirectory;
    openssh.authorizedKeys = {
      keys = vars.sshKeys;
      keyFiles = vars.sshKeyFiles;
    };
  };
  services.openssh.enable = true;
  security = {
    pam = {
      services = {
        sudo_local = {
          touchIdAuth = true;
          reattach = true;
        };
      };
    };
  };
  nix = {
    # Determinate Nix owns the daemon and nix.conf; disable nix-darwin's Nix management
    # completely to prevent both from competing over /etc/nix/nix.conf and launchd.
    enable = false;
    channel.enable = false;
    nixPath = lib.mkForce [ ];
  };
}
