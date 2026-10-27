# Shared host, user variables, and binary caches across macOS (nix-darwin) and Oracle (NixOS).
{ flake, ... }:
{ pkgs, ... }:
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
    nixCaches = caches;
    vars = {
      inherit username;
      description = "Yu-Min Peng";
      hostname = if isDarwin then "MacBook-Pro" else "nixos";
      homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
      locale = "en_US.UTF-8";
      timezone = "Asia/Taipei";
      inherit caches;

      sshKeys = [
        # My iPhone, blink terminal
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGr7upNdIAAtGkiQaUkCaj5g6QW843fL3bbsJyP/0tAB"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrcoI6oOTch+FI7XVlJ5eYJaGx4ZO2noO9GcXVFMhn9"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyz8c5h0/9ejDcYYkUZ568FUw0OAQEPfRnIbbbd4xGe"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAIJNFFaMxFGkxbzGvTtFfu+DPlxtqK0NoaExRVDvCt"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBN6rDDWpOzuVy7v8foYFJdjlcNJBZpmZcwZWWhoa3dbprqJGRClVKyg1NYNj1a3D43XvxeA+Vd1AgaAQDrSIbIE= #SSH ID - @leporuid"
      ];

      sshKeyFiles = [
        "${flake}/hosts/MacBook-Pro/users/leporuid/id_ed25519.pub"
        "${flake}/hosts/MacBook-Pro/id_ed25519.pub"
      ];
    };
  };
}
