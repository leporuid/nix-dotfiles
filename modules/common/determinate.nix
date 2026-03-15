{ config, lib, pkgs, inputs, ... }@args:
let
  # Get the Determinate Nix package
  determinate-Nix = inputs.determinate.inputs.nix.packages.${pkgs.stdenv.system}.default;

  # Ensure it has the pname attribute for NixOS 25.11+ compatibility
  determinateNix = determinate-Nix.overrideAttrs (oldAttrs: {
    pname = oldAttrs.pname or "nix";
  });
in
{
# Workaround: Disable HM manual to suppress Determinate Nix warning
# about options.json referencing store paths without proper 
# Upstream issue: https://github.com/nix-community/home-manager/issues/7935
nix.package = lib.mkForce determinateNix;
manual.manpages.enable = false;
}