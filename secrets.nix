let
  system = builtins.readFile hosts/MacBook-Pro/id_ed25519.pub;
  leporuid-MacBook-Pro = builtins.readFile hosts/MacBook-Pro/users/leporuid/id_ed25519.pub;
  nixos = builtins.readFile hosts/nixos/ssh_host_ed25519_key.pub;

  leporuid = [
    leporuid-MacBook-Pro
  ];
in
{
  "hosts/MacBook-Pro/tailscale-authkey.age".publicKeys = [ system ] ++ leporuid;
  "secrets/tailscale-unifi.age".publicKeys = [ system ] ++ leporuid;
  "hosts/MacBook-Pro/tailscale-ios.age".publicKeys = [ system ] ++ leporuid;
  "hosts/MacBook-Pro/flakehub.age".publicKeys = [ system ] ++ leporuid;

  "hosts/nixos/tailzero-invite.age".publicKeys = [ nixos ] ++ leporuid;
  "hosts/nixos/tailzero-token.age".publicKeys = [ nixos ] ++ leporuid;
  "hosts/nixos/tailscale-oracle.age".publicKeys = [ nixos ] ++ leporuid;
}
