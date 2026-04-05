let
  root-MagiHoHo = builtins.readFile ./hosts/MagiHoHo/id_ed25519.pub;
  
  leporuid-MagiHoHo = builtins.readFile ./hosts/MagiHoHo/users/leporuid/id_ed25519.pub;
in
{
  "hosts/MagiHoHo/tailscale-authkey.age".publicKeys = [ root-MagiHoHo leporuid-MagiHoHo ];
 }
