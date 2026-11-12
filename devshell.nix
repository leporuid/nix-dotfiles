{ inputs, pkgs, ... }:
let
  pre-commit-check = import ./git-hooks.nix { inherit inputs pkgs; };
in
pkgs.mkShell {
  packages = [ ];

  shellHook = ''
    ${pre-commit-check.shellHook}
  '';
}
