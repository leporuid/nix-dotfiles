# Validates that UniFi Tailscale patches apply cleanly without fuzz to the host's nixpkgs Tailscale source.
{ pkgs, ... }:
pkgs.applyPatches {
  name = "check-vpn-pack-tailscale-patches";
  src = pkgs.tailscale.src;
  patches = import ../packages/vpn-pack/patches.nix;
  patchFlags = [
    "-p1"
    "--fuzz=0"
  ];
}
