{ ... }: 
{
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment.enable = true;
    ignoreIP = [
      "100.0.0.0/8"  # Don't ban Tailscale IPs
    ];
  };
}