{ ... }:
{
  pkgs,
  ...
}:
{
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      Domains = [ "~." ];
      FallbackDNS = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };

}