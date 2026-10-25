{ ... }:
{
  config,
  pkgs,
  ...
}:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
    authKeyFile = config.age.secrets."tailscale-oracle".path;
    authKeyParameters.preauthorized = true;
    extraUpFlags = [
      "--accept-dns=false"
      "--accept-routes"
      "--advertise-exit-node"
      "--advertise-routes=10.0.50.0/24"
      "--operator=leporuid"
      "--advertise-tags=tag:all,tag:border0-managed"
    ];
    extraSetFlags = [
      "--accept-dns=false"
      "--accept-routes"
      "--advertise-exit-node"
      "--advertise-routes=10.0.50.0/24"
      "--operator=leporuid"
    ];
  };

  systemd.services.tailscale-ethtool = {
    description = "Configure UDP GRO forwarding for Tailscale on default network interface";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      iproute2
      ethtool
      gawk
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      IFACE="$(ip -4 route show default | awk '{print $5; exit}')"
      if [ -n "$IFACE" ]; then
        ethtool -K "$IFACE" rx-udp-gro-forwarding on rx-gro-list off || true
      fi
    '';
  };

  environment.systemPackages = with pkgs; [
    ethtool
  ];

  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ];
    trustedInterfaces = [ "tailscale0" ];
  };
}
