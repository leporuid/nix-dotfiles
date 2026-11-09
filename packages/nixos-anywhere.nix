{ pkgs, ... }:
pkgs.writeShellScriptBin "nixos-anywhere" ''
  exec env TMPDIR=/tmp ${pkgs.nixos-anywhere}/bin/nixos-anywhere "$@"
''
