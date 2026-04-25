{ inputs, self, flake, ... }:
{
_module.args.pkgs' = import inputs.nixpkgs-unstable {
    inherit (self) system;
    allowUnfree = true;
    overlays = [ (import "${flake}/overlays/default.nix")];
   };
}