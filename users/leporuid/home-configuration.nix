{
  pkgs,
  perSystem,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./cloud-configuration.nix
    inputs.self.homeModules.nixcord
  ];

  home.sessionVariables = {
    IS_DARWIN = "";
  };

  # Suppress the default macOS terminal login welcome message.
  home.file.".hushlogin".source = pkgs.emptyFile;
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.bun/bin"
    "${config.home.homeDirectory}/.swiftly/bin"
  ];
  my.config.source = {
    ".config/ghostty/config" = "config/ghostty/config";
    ".config/ghostty/os-config" = "config/ghostty/os-config-darwin";
    ".config/ghostty/themes" = "config/ghostty/themes";
    ".config/kitty" = "config/kitty";
    ".config/raycast" = "config/raycast";
    ".config/zed" = "config/zed";
  };

  home.packages = [
    pkgs.atuin
    pkgs.ffmpeg
    pkgs.mas
    pkgs.qpdf
    perSystem.ktoolbox.default
    perSystem.self.age-plugin-se
    perSystem.self.gallery-dl
    perSystem.self.kumono
    perSystem.self.megabasterd
    perSystem.self.n-m3u8dl-re
    perSystem.self.unxip
    perSystem.self.yt-dlp
  ];
}
