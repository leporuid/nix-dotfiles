{ pkgs, inputs, ... }:
inputs.age-plugin-se.packages.${pkgs.stdenv.hostPlatform.system}.default
