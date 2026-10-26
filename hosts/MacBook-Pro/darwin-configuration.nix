{
  inputs,
  config,
  vars,
  ...
}:
{
  imports = [
    inputs.self.modules.common.vars
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.fish-environment
    inputs.self.darwinModules.homebrew
  ];

  networking.hostName = vars.hostname;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = vars.username;
  system.stateVersion = 6;

  users.users.${vars.username} = {
    description = vars.description;
    home = vars.homeDirectory;
    openssh.authorizedKeys = {
      keys = vars.sshKeys;
      keyFiles = vars.sshKeyFiles;
    };
  };

  services.openssh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.watchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  nix.enable = !config.determinateNix.enable;
  nix.channel.enable = false;
}
