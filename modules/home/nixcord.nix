# Declarative Discord and Vencord/Equicord configuration via 4evy/nixcord.
{ inputs, ... }:
{ ... }:
{
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];

  programs.nixcord = {
    enable = true;
    discord.vencord.enable = true;
  };
}
