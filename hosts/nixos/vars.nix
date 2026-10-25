let
  sshKeys = import ../../users/leporuid/ssh-keys.nix;
in
{
  hostname = "nixos";
  username = "leporuid";
  sshKeys = sshKeys.authorizedKeys;
  keyFiles = sshKeys.keyFiles;
  locale = "en_US.UTF-8";
  timezone = "Asia/Taipei";
}
