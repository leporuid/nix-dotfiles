{
  flake,
  config,
  pkgs,
  perSystem,
  inputs,
  pkgs',
  ...
}:
{
  imports = [
    ./home-configuration.nix
  ];

  # The work setups are managed much more imperatively than any of my personal
  # machines, mainly because it isn't worth my time while I'm working to set
  # up Nix correctly (without buy-in from anyone else on the team), and it
  # isn't worth my time when I'm not working because there are other things I'd
  # rather be doing. Instead, I can do as much as is reasonable in Nix, but
  # fall back to plugins and homebrew when stuff doesn't work right.
  home.sessionVariables = {
    ATUIN_NOBIND = "true";
    SWIFTLY_HOME_DIR="$HOME/.swiftly";
    SWIFTLY_BIN_DIR="$HOME/.swiftly/bin";
    SWIFTLY_TOOLCHAINS_DIR="$HOME/Library/Developer/Toolchains";
    FZF_DEFAULT_OPTS = "--no-sort --reverse --margin=0,1 --exit-0 --select-1 --pointer ▸▹ --prompt • --color bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284,fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf,marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284,selected-bg:#51576d,border:#414559,label:#c6d0f5";
  };

  my.config.source =
    let
      # Some tools prefer to place their configuration in the correct directory
      # for the platform. On Linux, that's XDG_CONFIG_HOME, which defaults to
      # ~/.config if unset. On macOS, the configuration directory is
      # '~/Library/Application Support'.
      # Unfortunately, this isn't common - most tools simply use ~/.config
      # regardless of platform conventions.
      platformConfig = if pkgs.stdenv.hostPlatform.isDarwin then "Library/Application Support" else ".config";
    in
    {
      "${platformConfig}/nushell" = "config/nushell";
      ".config/atuin/config.toml" = "config/atuin/config.toml";
      ".config/mise/config.toml" = "config/mise/config.toml";
      ".config/zellij" = "config/zellij";
      ".config/raycast" = "config/raycast";
      ".config/starship.toml" = "config/starship.toml";
      ".swiftly/env.fish" = "config/swiftly/env.fish";
    };

  home.packages = [
    perSystem.self.kumono
    perSystem.self.age-plugin-se
    pkgs.atuin
    pkgs.aria2
    pkgs.bun
    pkgs.passage
    pkgs.starship
    pkgs.uv
    pkgs.mise
    pkgs.ffmpeg
    #pkgs.yt-dlp
    #pkgs.gallery-dl
    #pkgs.hydrus
    pkgs.zellij
  ];


  my.programs.fish.plugins = [
    (pkgs.fetchFromGitHub {
      owner = "martonperei";
      repo = "starship.fish";
      rev = "master";
      hash = "sha256-3KaIUXNqatvkd8YPjsPNIxcNFh6IZnEQp7b2rxGQhhg=";
    })
  ];
}
