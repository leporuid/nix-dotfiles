{ pkgs, inputs, ... }:
pkgs.gallery-dl.overrideAttrs (_: {
  version = "0.0.0-unstable-${inputs.gallery-ai.shortRev or "dirty"}";
  src = inputs.gallery-ai;
  patches = [ ];
  doCheck = false;
  doInstallCheck = false;
  dontCheckRuntimeDeps = true;
})
