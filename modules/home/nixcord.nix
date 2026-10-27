# Declarative Discord and Vencord configuration via 4evy/nixcord.
{ inputs, ... }:
{ ... }:
{
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];

  programs.nixcord = {
    enable = true;
    discord = {
      enable = true;
      vencord.enable = true;
    };

    config = {
      useQuickCss = true;
      themeLinks = [
        "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css"
      ];
      plugins = {
        callTimer.enable = true;
        copyUserUrls.enable = true;
        fakeNitro.enable = true;
        messageLogger.enable = true;
        openInApp.enable = true;
        pictureInPicture.enable = true;
        previewMessage.enable = true;
        relationshipNotifier.enable = true;
        translate.enable = true;
        volumeBooster.enable = true;
      };
    };
  };
}
