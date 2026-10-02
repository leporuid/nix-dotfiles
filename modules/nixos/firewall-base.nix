{ ... }:
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    # Add services later as needed, e.g. 80 443
  };
}