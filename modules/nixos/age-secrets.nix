{ pkgs, ... }:
{
  age.identityPaths = [ "/etc/nixos/secrets/keys.txt" ];
  age.secrets.tailzero-invite.file = ../../secrets/tailzero-invite.age;
}
