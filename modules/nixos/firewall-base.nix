{ ... }:
{
  networking.firewall = {
    enable = true;
     trustedIpv4 = [
    "100.64.0.0/10" # tailscale
  ];

  trustedIpv6 = [
    "fd7a:115c:a1e0::/48" # tailscale
  ];
    allowedTCPPorts = [ 22 ];
    # Add services later as needed, e.g. 80 443
  };
}