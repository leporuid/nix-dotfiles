{
  inputs,
  config,
  lib,
  pkgs,
  perSystem,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  # 1. Modular feature imports in moni-dz style
  imports = [
    inputs.self.hjemModules.aggregate
    ../../config/nvim/plugins.nix
  ];
  my = {
    # 2. Enable domain modules
    themes.enable = true;
    programs = {
      agents.enable = true;
      atuin.enable = true;
      direnv.enable = true;
      fish.enable = true;
      ghostty.enable = true;
      git.enable = true;
      helix.enable = isDarwin;
      jujutsu.enable = true;
      neovim.enable = true;
      nushell.enable = true;
      starship.enable = true;
      tmux.enable = true;
      zellij.enable = true;
      zsh.enable = true;
    };
    # 4. Declarative configuration synthesis engine (my-config)
    config = {
      directory = "${config.directory}/Developer/nix-dotfiles/config";
      storeDirectory = ../../config;
      useOutOfStoreSymlinks = isDarwin;
      source = {
        ".config/mise" = "mise";
        ".config/gallery-dl" = "gallery-dl";
        ".npmrc" = "npm/npmrc";
      }
      // lib.optionalAttrs isDarwin {
        # macOS GUI & Utilities
        ".config/foot" = "foot";
        ".config/kitty" = "kitty";
        ".config/zed" = "zed";
        ".config/github-copilot/versions.json" = "github-copilot/versions.json";
        ".config/github-copilot/xcode/mcp.json" = "github-copilot/xcode/mcp.json";
        ".config/raycast" = "raycast";
      };
    };
  };
  files = lib.optionalAttrs isDarwin {
    ".config/btt/Default.bttpreset".source =
      "${config.directory}/Library/Mobile Documents/com~apple~CloudDocs/Default.bttpreset";
  };
  # 5. Core developer tools & productivity utilities
  packages =
    (with pkgs; [
      # Editors
      vim

      # Modern CLI & search (ripgrep, eza, fzf are provided via modules/hjem/fish.nix)
      fd
      zoxide
      tree
      jq
      curl
      wget

      # Build tools, languages & dev environments
      just
      mise
      bun
      uv
      gum
      tealdeer

      # Nix & formatting tools
      nil
      nixfmt
      nix-output-monitor
      taplo
      ast-grep

      # Fonts
      nerd-fonts.roboto-mono

      # Custom / specialized derivations from flake
      perSystem.self.has-ancestor
      perSystem.self.ccase
      perSystem.self.ktoolbox
    ])
    ++ lib.optionals isDarwin [
      pkgs.ffmpeg
      pkgs.gnused
      pkgs.mas
      pkgs.qpdf
      perSystem.self.age-plugin-se
      perSystem.self.gallery-dl
      perSystem.self.kumono
      perSystem.self.megabasterd
      perSystem.self.unxip
      perSystem.self.yt-dlp
    ];
  # 6. Session environment variables (POSIX script via Hjem environment.loadEnv)
  environment.sessionVariables = {
    NIX_CONFIG_REV = inputs.self.rev or inputs.self.dirtyRev or "dirty";
    NIX_CONFIG_DIR = config.my.config.directory;
    NIX_CONFIG_LAST_MODIFIED = builtins.toString (inputs.self.lastModified or 0);
  }
  // lib.optionalAttrs isDarwin {
    IS_DARWIN = "";
    FISH_GREETING_CHECK_SUDO_TOUCHID = "1";
    SWIFTLY_HOME_DIR = "${config.directory}/.swiftly";
    SWIFTLY_BIN_DIR = "${config.directory}/.swiftly/bin";
    SWIFTLY_TOOLCHAINS_DIR = "${config.directory}/Library/Developer/Toolchains";
  };
}
