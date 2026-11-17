# lib/default.nix — Shared functional library for nix-dotfiles
# Exported by red-tape as `flake.lib`
_:
let
  credentialGuard = import ./credential-guard.nix;
  darwin = import ./darwin.nix { };
  nixSettings = import ./nix-settings.nix;
in
{
  inherit
    credentialGuard
    darwin
    nixSettings
    ;
}
