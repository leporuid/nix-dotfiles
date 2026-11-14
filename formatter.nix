{
  inputs,
  pkgs,
  ...
}:
((inputs.treefmt or inputs.treefmt-nix).lib.evalModule pkgs ./treefmt.nix).config.build.wrapper
