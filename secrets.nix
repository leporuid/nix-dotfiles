let
  system-MacBook-Pro = builtins.readFile /etc/ssh/ssh_host_ed25519_key.pub;
  MagiHoHo = builtins.readFile ./hosts/MagiHoHo/id_ed25519.pub;
  
  leporuid-MagiHoHo = builtins.readFile ./hosts/MagiHoHo/users/leporuid/id_ed25519.pub;
  leporuid = [
    MagiHoHo
    leporuid-MagiHoHo
  ];
in
{
  "hosts/MagiHoHo/tailscale-authkey.age".publicKeys = [ system-MacBook-Pro ] ++ leporuid;
 }
