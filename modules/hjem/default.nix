# Hjem modules aggregator in moni-dz style
{ ... }:
{
  imports = [
    ./my-config.nix
    ./themes.nix
    ./neovim.nix
    ./fish.nix
    ./helix.nix
    ./ghostty.nix
    ./direnv-instant.nix
    ./nixcord.nix
  ];
}
