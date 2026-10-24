{ pkgs, ... }:
pkgs.atuin.overrideAttrs (_: {
  doCheck = false;
  doInstallCheck = false;
})
