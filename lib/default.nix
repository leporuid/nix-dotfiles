# lib/default.nix — Shared functional library for nix-dotfiles
# Exported by red-tape as `flake.lib`
_:
let
  darwin = import ./darwin.nix { };
  nixSettings = import ./nix-settings.nix;
in
{
  inherit
    darwin
    nixSettings
    ;

  # Builds the `perSystem` view (`perSystem.<input>.<pkg>`) matching red-tape's
  # scope and standalone Hjem specialArgs so host and standalone evaluations
  # resolve packages identically.
  mkPerSystem =
    {
      inputs,
      lib,
      system,
    }:
    lib.mapAttrs (
      _: input:
      if builtins.isAttrs input then
        (input.legacyPackages.${system} or { }) // (input.packages.${system} or { })
      else
        input
    ) inputs;
}
