# Declarative Discord and Vencord system configuration via nixcord darwinModules.
{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.nixcord.darwinModules.nixcord
  ];

  programs.nixcord = {
    enable = true;
    user = config.system.primaryUser;
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
        alwaysTrust.enable = true;
        betterFolders.enable = true;
        betterSettings.enable = true;
        callTimer.enable = true;
        copyUserUrls.enable = true;
        directFileDownload.enable = true;
        experiments.enable = true;
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
