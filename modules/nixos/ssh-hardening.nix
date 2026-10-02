{ ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      ClientAliveInterval = 60;
      ClientAliveCountMax = 3;
      X11Forwarding = false;
      AcceptEnv = [
        "COLORTERM"
        "TERM_PROGRAM"
        "TERM_PROGRAM_VERSION"
      ];
    };
  };
}