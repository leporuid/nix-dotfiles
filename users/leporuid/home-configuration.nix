# Full macOS desktop and media configuration extending the shared cloud configuration.
{
  pkgs,
  perSystem,
  ...
}:
{
  imports = [
    ./cloud-configuration.nix
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
    pkgs.ffmpeg
    pkgs.mas
    pkgs.n-m3u8dl-re
    pkgs.nerd-fonts.roboto-mono
    pkgs.qpdf
    perSystem.ktoolbox.default
    perSystem.self.age-plugin-se
    perSystem.self.gallery-dl
    perSystem.self.kumono
    perSystem.self.megabasterd
    perSystem.self.unxip
    perSystem.self.yt-dlp
  ];
}
