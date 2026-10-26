{ ... }:
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 8090 ];
    # Add services later as needed, e.g. 80 443
  };
}
