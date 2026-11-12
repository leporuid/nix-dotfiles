{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.git
    pkgs.ripgrep
  ];
}
