# Shared Hjem wiring across Darwin and NixOS powered by red-tape
{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  hjem = {
    clobberByDefault = true;
    specialArgs = inputs.red-tape.lib.mkHjemSpecialArgs {
      inherit inputs;
      inherit (pkgs.stdenv.hostPlatform) system;
    };
    extraModules = [
      inputs.hjem-rum.hjemModules.default
    ];

    # User discovery is owned by red-tape; hosts bind the shared modules directly.
    users = lib.mapAttrs (_: cfg: cfg.module) inputs.self.hjemConfigurations;
  };
}
