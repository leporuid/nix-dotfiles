{ pkgs, inputs, ... }:
{
  imports = [
    inputs.hjem.darwinModules.default
    inputs.hjem-rum.darwinModules.default
    ../../modules/nixos/host-shared.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.leporuid.home = "/Users/leporuid";

  hjem.users.leporuid =
    { ... }:
    {
      imports = [ ../../users/leporuid/home-configuration.nix ];
    };

  system.stateVersion = 6;
}
