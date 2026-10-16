{ pkgs, ... }:
{
  age.identityPaths = [ "/etc/nixos/secrets/keys.txt" ];
  age.secrets.tailzero-invite.file = ../../hosts/nixos/tailzero-invite.age;
}
