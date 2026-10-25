{
  pkgs,
  ...
}:

let
  vars = import ../vars.nix;
in
{
  imports = [
    ../../../modules/nixos/programs.nix
  ];

  users.defaultUserShell = pkgs.bashInteractive;
  users.users.${vars.username}.shell = pkgs.bashInteractive;
}