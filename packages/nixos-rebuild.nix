{ pkgs, inputs, ... }:
pkgs.writeShellScriptBin "nixos-rebuild" ''
  exec env TMPDIR=/tmp \
    ${
      inputs.determinate.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.nixos-rebuild-ng
    }/bin/nixos-rebuild "$@"
''
