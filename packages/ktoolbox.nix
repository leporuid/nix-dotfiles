{
  inputs,
  pkgs,
  ...
}:
inputs.ktoolbox.packages.${pkgs.stdenv.hostPlatform.system}.default
