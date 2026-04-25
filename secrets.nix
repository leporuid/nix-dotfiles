let
  system = builtins.readFile /etc/ssh/ssh_host_ed25519_key.pub;
  MacBook-Pro = builtins.readFile ./hosts/MacBook-Pro/id_ed25519.pub;
  leporuid-MacBook-Pro  = builtins.readFile ./hosts/MacBook-Pro/users/leporuid/id_ed25519.pub;
  leporuid = [
    leporuid-MacBook-Pro
    MacBook-Pro
  ];
in
{
  "hosts/MagiHoHo/tailscale-authkey.age".publicKeys = [ system ] ++ leporuid;
  "hosts/MacBook-Pro/tailscale-authkey.age".publicKeys = [ system ] ++ leporuid;
 }
