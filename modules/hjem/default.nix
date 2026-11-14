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
    ./atuin.nix
    ./direnv.nix
    ./direnv-instant.nix
    ./jujutsu.nix
    ./nixcord.nix
  ];
}
