{ ... }: 
{
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos";
    dates = "04:20";
    randomizedDelaySec = "45min";
    allowReboot = true;
    operation = "switch";
  };
}
