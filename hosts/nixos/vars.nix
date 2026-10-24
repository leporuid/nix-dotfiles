let
  sshKeys = import ../../users/leporuid/ssh-keys.nix;
in
{
  hostname = "nixos";
  username = "leporuid";
  sshKeys = sshKeys.authorizedKeys ++ (map builtins.readFile sshKeys.keyFiles);
  locale = "en_US.UTF-8";
  timezone = "Asia/Taipei";
}
