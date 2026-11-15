# Shared host, user variables, and binary caches across macOS (nix-darwin) and Oracle (NixOS).
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  username = "leporuid";

  caches = import ../../lib/caches.nix;
in
{
  _module.args = {
    vars = lib.mkDefault {
      inherit username;
      description = "Yu-Min Peng";
      hostname = if isDarwin then "MacBook-Pro" else "nixos";
      homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
      locale = "en_US.UTF-8";
      timezone = "Asia/Taipei";
      inherit caches;

      # Centralized Determinate Nix core performance, daemon, and cache settings
      customSettings = {
        inherit (caches) extra-substituters extra-trusted-public-keys;

        trusted-users = [
          "root"
          username
        ];
        accept-flake-config = true;
        auto-optimise-store = !isDarwin;
        builders-use-substitutes = true;
        connect-timeout = 10;
        fallback = true;
        keep-going = true;
        log-lines = 25;
        stalled-download-timeout = 20;
        warn-dirty = false;
      };

      sshKeys = [ ];

      # Public device keys are provided by the private nix-secrets input
      sshKeyFiles = lib.optionals (inputs ? nix-secrets) (
        [
          "${inputs.nix-secrets}/keys/MacBook-Pro-user.pub"
          "${inputs.nix-secrets}/keys/MacBook-Pro-system.pub"
          "${inputs.nix-secrets}/keys/nixos-system.pub"
        ]
        ++ lib.optional (inputs.nix-secrets ? sshKeys) inputs.nix-secrets.sshKeys
        ++ lib.optional (inputs.nix-secrets ? authorizedKeys) inputs.nix-secrets.authorizedKeys
      );
    };
  };
}
