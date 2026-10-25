{
  pkgs,
  flake,
  inputs,
  ...
}:

let
  vars = import ../../vars.nix;
in
{
  imports = [
    inputs.self.nixosModules.programs
  ];

  users.defaultUserShell = pkgs.bashInteractive;
  users.users.${vars.username}.shell = pkgs.bashInteractive;
}