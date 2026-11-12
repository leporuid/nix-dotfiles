{ pkgs, ... }:
pkgs.writeShellScriptBin "nixos-rebuild" ''
  exec env TMPDIR=/tmp ${pkgs.nixos-rebuild-ng}/bin/nixos-rebuild "$@"
''
