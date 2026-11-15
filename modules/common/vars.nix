# Shared host and user variables across macOS (nix-darwin) and Oracle (NixOS).
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.lists) optional optionals;
  inherit (lib.modules) mkDefault;

  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  username = "leporuid";
in
{
  _module.args = {
    vars = mkDefault {
      inherit username;
      description = "Yu-Min Peng";
      homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
      locale = "en_US.UTF-8";
      timezone = "Asia/Taipei";

      # Public device keys are provided by the private nix-secrets input
      sshKeyFiles = optionals (inputs ? nix-secrets) (
        [
          "${inputs.nix-secrets}/keys/MacBook-Pro-user.pub"
          "${inputs.nix-secrets}/keys/MacBook-Pro-system.pub"
          "${inputs.nix-secrets}/keys/nixos-system.pub"
        ]
        ++ optional (inputs.nix-secrets ? sshKeys) inputs.nix-secrets.sshKeys
        ++ optional (inputs.nix-secrets ? authorizedKeys) inputs.nix-secrets.authorizedKeys
      );
    };
  };
}
