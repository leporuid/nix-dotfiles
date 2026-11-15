{
  inputs,
  lib,
  vars,
  ...
}:
{
  imports = [
    inputs.self.darwinModules.aggregate
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
    hostName = "MacBook-Pro";
    computerName = "🐰MacBook Pro";
    localHostName = "MacBook-Pro";
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
    openssh.authorizedKeys.keyFiles = vars.sshKeyFiles;
  };
  services.openssh.enable = true;
  determinateNix.customSettings.builders = "ssh-ng://${vars.username}@nixos aarch64-linux /etc/ssh/ssh_host_ed25519_key 4 1 big-parallel,benchmark -";
  programs.ssh.knownHosts = lib.optionalAttrs (inputs ? nix-secrets) {
    nixos.publicKeyFile = "${inputs.nix-secrets}/keys/nixos-system.pub";
  };
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
}
