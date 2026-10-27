{
  pkgs,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  determinatePkgs = inputs.determinate.inputs.nixpkgs.legacyPackages.${system};
in
pkgs.writeShellScriptBin "nixos-rebuild" ''
  exec env TMPDIR=/tmp \
    ${determinatePkgs.nixos-rebuild-ng}/bin/nixos-rebuild "$@"
''
