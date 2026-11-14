# Shared host, user variables, and binary caches across macOS (nix-darwin) and Oracle (NixOS).
{
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  username = "leporuid";

  caches = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
      "https://crane.cachix.org"
    ];

    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
    ];
  };
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
        keep-derivations = true;
        keep-outputs = true;
        log-lines = 25;
        max-free = 3221225472;
        min-free = 1073741824;
        stalled-download-timeout = 20;
        warn-dirty = false;
      };

      sshKeys = [
        # SSH ID - @leporuid
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBC/CoiKLL0z+HwqsGgfaBzt2wxuXbf/qBzldpIrPj7n7G8v2VXJPbATbSgZBRZV0Ss+peT2hkMNKvdnHC95XWfo="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDjpuPuSa1+ds+Nd34aF38YgU5E8QIGDAyP3NpIlODxCMS4/BgWtUORoQJiTqW1yWAnyomN/g4eqVt6XczCm6Sk="
        # My iPhone, blink terminal
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGr7upNdIAAtGkiQaUkCaj5g6QW843fL3bbsJyP/0tAB"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrcoI6oOTch+FI7XVlJ5eYJaGx4ZO2noO9GcXVFMhn9"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyz8c5h0/9ejDcYYkUZ568FUw0OAQEPfRnIbbbd4xGe"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAIJNFFaMxFGkxbzGvTtFfu+DPlxtqK0NoaExRVDvCt"
      ];

      sshKeyFiles = [
        ../../hosts/MacBook-Pro/users/leporuid/id_ed25519.pub
        ../../hosts/MacBook-Pro/id_ed25519.pub
        ../../hosts/nixos/id_ed25519.pub
      ];
    };
  };
}
