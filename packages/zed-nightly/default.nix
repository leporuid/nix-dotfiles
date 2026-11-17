# Zed Nightly (HaukurPall/zed ghostty-stable-haukurpj) packaged for Darwin with libghostty-vt.
{
  inputs,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  zedPkgs = inputs.zed.inputs.nixpkgs.legacyPackages.${system};
  rustBin = inputs.zed.inputs.rust-overlay.lib.mkRustBin { } zedPkgs;
in
zedPkgs.callPackage ./build.nix {
  crane = inputs.zed.inputs.crane.mkLib zedPkgs;
  rustToolchain = rustBin.fromRustupToolchainFile "${inputs.zed}/rust-toolchain.toml";
  srcRoot = inputs.zed;
  commitSha = inputs.zed.rev or null;
}
