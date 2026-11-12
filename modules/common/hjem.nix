# Shared Hjem wiring across Darwin and NixOS (moni-dz style + blueprint auto-users)
{
  inputs,
  config,
  lib,
  ...
}:
let
  isDarwin = config.nixpkgs.hostPlatform.isDarwin or false;
  hostName = config.networking.hostName or "";

  hostUsersDir = ../../hosts + "/${hostName}/users";
  hasHostUsers = hostName != "" && builtins.pathExists hostUsersDir;
  hostUserEntries = if hasHostUsers then builtins.readDir hostUsersDir else { };

  genericUsersDir = ../../users;
  hasGenericUsers = builtins.pathExists genericUsersDir;
  genericUserEntries = if hasGenericUsers then builtins.readDir genericUsersDir else { };

  getUserConfig =
    username:
    let
      hostUserConfig = hostUsersDir + "/${username}/home-configuration.nix";
      genericUserConfig = genericUsersDir + "/${username}/home-configuration.nix";
    in
    if hasHostUsers && builtins.pathExists hostUserConfig then
      hostUserConfig
    else if hasGenericUsers && builtins.pathExists genericUserConfig then
      genericUserConfig
    else
      null;

  allUserNames = lib.unique ((lib.attrNames hostUserEntries) ++ (lib.attrNames genericUserEntries));

  validUsers = lib.filterAttrs (_name: path: path != null) (lib.genAttrs allUserNames getUserConfig);
in
{
  hjem = {
    clobberByDefault = true;
    extraModules = [
      inputs.hjem-rum.hjemModules.default
      inputs.hjem-impure.hjemModules.default
      ../hjem
    ];

    # Automatically attach user configurations found in hosts/<hostname>/users/ or users/
    users = lib.mapAttrs (
      username: configPath:
      { ... }:
      {
        directory = lib.mkDefault (if isDarwin then "/Users/${username}" else "/home/${username}");
        imports = [ configPath ];
      }
    ) validUsers;
  };
}
