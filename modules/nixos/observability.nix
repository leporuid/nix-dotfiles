{ pkgs, ... }:
{
  services.journald.settings.Journal = {
    SystemMaxUse = "500M";
    MaxRetentionSec = "2week";
  };
  environment.systemPackages = with pkgs; [
    lsof
    inetutils
    dig
    traceroute
    tcpdump
  ];
}
