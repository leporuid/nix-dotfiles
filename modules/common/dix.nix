# Closure diff on activation using dix (Darwin preActivation, NixOS dry-activation aware).
{
  lib,
  pkgs,
  ...
}:
let
  dixScript = ''
    if [ -e /run/current-system ]; then
      ${lib.getExe pkgs.dix} diff --full --color=always /run/current-system "$systemConfig" >&2 || true
    fi
  '';
in
{
  system.activationScripts =
    if pkgs.stdenv.hostPlatform.isDarwin then
      {
        preActivation.text = dixScript;
      }
    else
      {
        dix = {
          supportsDryActivation = true;
          text = dixScript;
        };
      };
}
