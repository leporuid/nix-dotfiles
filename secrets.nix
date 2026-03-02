let
  MacBook-Pro = builtins.readFile ./hosts/MacBook-Pro/id_ed25519.pub;
  leporuid-MacBook-Pro = builtins.readFile ./hosts/MacBook-Pro/users/leporuid/id_ed25519.pub;
  leporuid = [ leporuid-MacBook-Pro
  ];
in
{
  "hosts/MacBook-Pro/users/leporuid/tailscale-authkey.age".publicKeys = [ MacBook-Pro ] ++ leporuid;
}
