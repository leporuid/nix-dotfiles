# lib/hosts.nix — Programmatic host system builders inspired by blueprint's loadNixDarwin / loadNixOS
# Automatically bundles Determinate Nix, Hjem, common/hjem, common/vars, and platform modules.
{
  inputs ? { },
  lib ? inputs.nixpkgs.lib or null,
  ...
}:
{
  # Build a nix-darwin host system with complete platform wiring
  mkDarwinSystem =
    {
      hostName,
      system ? "aarch64-darwin",
      modules ? [ ],
      specialArgs ? { },
    }:
    inputs.nix-darwin.lib.darwinSystem {
      modules = [
        inputs.determinate.darwinModules.default
        ../modules/darwin
        {
          networking.hostName = lib.mkDefault hostName;
          nixpkgs.hostPlatform = lib.mkDefault system;
        }
      ] ++ modules;
      specialArgs = {
        inherit inputs hostName;
        isDarwin = true;
        isNixOS = false;
        class = "nix-darwin";
      } // specialArgs;
    };

  # Build a NixOS host system with complete platform wiring
  mkNixosSystem =
    {
      hostName,
      system ? "x86_64-linux",
      modules ? [ ],
      specialArgs ? { },
    }:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.determinate.nixosModules.default
        ../modules/nixos
        {
          networking.hostName = lib.mkDefault hostName;
          nixpkgs.hostPlatform = lib.mkDefault system;
        }
      ] ++ modules;
      specialArgs = {
        inherit inputs hostName;
        isDarwin = false;
        isNixOS = true;
        class = "nixos";
      } // specialArgs;
    };
}
