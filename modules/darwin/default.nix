{ inputs, ... }:
{
  imports = [
    ./hjem.nix
    ../common/vars.nix
    ./system-defaults.nix
    ./applications.nix
  ];

  nixpkgs.overlays = import ../../overlays { inherit inputs; };
}
