{
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
