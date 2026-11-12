# Hjem modules aggregator in moni-dz style
{ ... }:
{
  imports = [
    ./my-config.nix
    ./themes.nix
    ./neovim.nix
    ./fish.nix
    ./direnv-instant.nix
    ./nixcord.nix
  ];
}
