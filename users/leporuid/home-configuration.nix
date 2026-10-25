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
    pkgs.gallery-dl
    pkgs.mas
    pkgs.n-m3u8dl-re
    pkgs.qpdf
    pkgs.yt-dlp
    perSystem.ktoolbox.default
    perSystem.self.age-plugin-se
    perSystem.self.kumono
    perSystem.self.megabasterd
    perSystem.self.unxip
  ];
}
