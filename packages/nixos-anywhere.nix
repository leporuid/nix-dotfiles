{
  pkgs,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  determinatePkgs = inputs.determinate.inputs.nixpkgs.legacyPackages.${system};
in
pkgs.writeShellScriptBin "nixos-anywhere" ''
  exec env TMPDIR=/tmp \
    ${determinatePkgs.nixos-anywhere}/bin/nixos-anywhere "$@"
''
