{ inputs, ... }:
{
  imports = [
    ./hjem.nix
    ../common/vars.nix
  ];

  nixpkgs.overlays = import ../../overlays { inherit inputs; };
}
