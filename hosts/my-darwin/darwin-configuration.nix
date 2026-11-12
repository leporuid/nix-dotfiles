{ pkgs, ... }:
{
  imports = [ ../../modules/nixos/host-shared.nix ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.me.home = "/Users/me";

  system.stateVersion = 6;
}
