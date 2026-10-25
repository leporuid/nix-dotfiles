{ pkgs, inputs, ... }:
pkgs.yt-dlp.overrideAttrs (_: {
  version = "0.0.0-unstable-${inputs.yt-ai.shortRev or "dirty"}";
  src = inputs.yt-ai;
  patches = [ ];
  doCheck = false;
  doInstallCheck = false;
  dontCheckRuntimeDeps = true;
})
