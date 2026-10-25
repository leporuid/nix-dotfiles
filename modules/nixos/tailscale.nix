{ ... }:
{ pkgs, ... }:
{
  # Disable the native Tailscale daemon so Tailzero (Border0) manages the connection exclusively.
  services.tailscale.enable = false;

  # Retain UDP GRO forwarding and firewall optimizations for Tailzero's underlying WireGuard tunnel.
  services.networkd-dispatcher.enable = false;
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "50-tailscale-ethtool" ''
        #!${pkgs.bash}/bin/bash
        set -euo pipefail
        IFACE="''${1:-}"
        STATE="''${2:-}"
        case "$STATE" in
          up|dhcp4-change|dhcp6-change|connectivity-change) ;;
          *) exit 0 ;;
        esac
        [ -n "$IFACE" ] || exit 0
        ${pkgs.ethtool}/sbin/ethtool -K "$IFACE" rx-udp-gro-forwarding on rx-gro-list off || true
      '';
    }
  ];

  environment.systemPackages = with pkgs; [
    ethtool
  ];

  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ];
    trustedInterfaces = [ "tailscale0" ];
  };
}
