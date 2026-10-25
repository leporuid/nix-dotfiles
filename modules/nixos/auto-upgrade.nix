{ ... }: 
{
  system.autoUpgrade = {
    enable = true;
    flake = "~/Developer/nix-dotfiles";
    dates = "04:20";
    randomizedDelaySec = "45min";
    allowReboot = true;
    operation = "switch";
  };
}
