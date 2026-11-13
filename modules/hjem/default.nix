# Hjem modules aggregator in moni-dz style
{ ... }:
{
  imports = [
    ./my-config.nix
    ./themes.nix
    ./neovim.nix
    ./fish.nix
    ./helix.nix
    ./zellij.nix
    ./tmux.nix
    ./starship.nix
    ./nushell.nix
    ./ghostty.nix
    ./direnv-instant.nix
    ./nixcord.nix
  ];
}
