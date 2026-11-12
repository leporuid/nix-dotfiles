{ pkgs, inputs, ... }:
{
  imports = [
    inputs.hjem.darwinModules.default
    ../../modules/nixos/host-shared.nix
  ];

  hjem = {
    clobberByDefault = true;
    extraModules = [
      inputs.hjem-rum.hjemModules.default
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.leporuid.home = "/Users/leporuid";

  hjem.users.leporuid =
    { ... }:
    {
      directory = "/Users/leporuid";
      imports = [ ../../users/leporuid/home-configuration.nix ];
    };

  system.stateVersion = 6;
}
