# Shared Nix daemon settings for nix-darwin (determinateNix.customSettings) and NixOS (nix.settings).
# Platform-specific differences belong in the host or platform modules, not here.
{ username }:
let
  caches = import ./caches.nix;
in
{
  inherit (caches) extra-substituters extra-trusted-public-keys;

  trusted-users = [
    "root"
    username
  ];
  builders-use-substitutes = true;
  connect-timeout = 10;
  fallback = true;
  keep-going = true;
  log-lines = 25;
  stalled-download-timeout = 20;
  warn-dirty = false;
}
