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
  ];

  home.sessionVariables = {
    IS_DARWIN = "";
    SWIFTLY_HOME_DIR = "${config.home.homeDirectory}/.swiftly";
    SWIFTLY_BIN_DIR = "${config.home.homeDirectory}/.swiftly/bin";
    SWIFTLY_TOOLCHAINS_DIR = "${config.home.homeDirectory}/Library/Developer/Toolchains";
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
    ".config/github-copilot/versions.json" = "config/github-copilot/versions.json";
    ".config/github-copilot/xcode/mcp.json" = "config/github-copilot/xcode/mcp.json";
    ".config/kitty" = "config/kitty";
    ".config/raycast" = "config/raycast";
    ".config/zed" = "config/zed";
  };

  home.packages = [
    (pkgs.atuin.overrideAttrs (_: { doCheck = false; }))
    pkgs.ffmpeg
    pkgs.mas
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
