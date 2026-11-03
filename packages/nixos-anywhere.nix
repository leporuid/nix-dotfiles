{ pkgs, inputs, ... }:
pkgs.writeShellScriptBin "nixos-anywhere" ''
  exec env TMPDIR=/tmp \
    ${inputs.determinate.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.nixos-anywhere}/bin/nixos-anywhere "$@"
''
