{ inputs, self, flake, config, ... }:
{
_module.args.pkgs' = import inputs.nixpkgs-unstable {
    inherit (self) system;
    allowUnfree = true;
    overlays = [];
   };
}