{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  platformConfig = if isDarwin then "Library/Application Support" else ".config";
in
{
  # 1. Modular feature imports in moni-dz style
  imports = [
    ../../modules/hjem
    ../../config/nvim/plugins.nix
  ];
  # 2. Hjem-Impure: out-of-store symlinking for live dotfile editing without rebuilds
  impure = {
    # Enable out-of-store symlinks on macOS; use pure store paths on headless NixOS
    enable = isDarwin;
    dotsDir = "${../../config}";
    dotsDirImpure = "${config.directory}/Developer/nix-dotfiles/config";
  };
  my = {
    # 3. Enable domain modules
    themes.enable = true;
    programs = {
      fish.enable = true;
      neovim.enable = true;
      ghostty.enable = true;
      helix.enable = true;
      nushell.enable = true;
      starship.enable = true;
      tmux.enable = true;
      zellij.enable = true;
    };
    # 4. Declarative configuration synthesis engine (my-config)
    config = {
      directory = "${config.directory}/Developer/nix-dotfiles/config";
      storeDirectory = ../../config;
      source = {
        # Shells
        ".config/sheldon" = "sheldon";
        ".config/zsh" = "zsh";
        ".zshenv" = "zsh/home_zshenv";

        # Development & Editors
        ".config/zed" = "zed";

        # Terminals
        ".config/foot" = "foot";
        ".config/kitty" = "kitty";

        # Version Control & Tools
        ".config/git" = "git";
        "${platformConfig}/jj" = "jj";
        ".config/direnv/direnv.toml" = "direnv/direnv.toml";
        ".config/atuin" = "atuin";
        ".config/mise" = "mise";
        ".config/gallery-dl" = "gallery-dl";
        ".config/syntax-highlight" = "syntax-highlight";
        ".npmrc" = "npm/npmrc";

        # Agents & Skills
        ".claude/settings.json" = "claude/settings.json";
        ".agents/skills" = "agents/skills";
        ".claude/skills" = "agents/skills";
        ".gemini/skills" = "gemini/skills";
      }
      // lib.optionalAttrs isDarwin {
        # macOS Utilities
        ".config/btt" = "btt";
        ".config/github-copilot/versions.json" = "github-copilot/versions.json";
        ".config/github-copilot/xcode/mcp.json" = "github-copilot/xcode/mcp.json";
        ".config/raycast" = "raycast";
      };
    };
  };
  # 5. Core developer tools & productivity utilities
  packages =
    (with pkgs; [
      # Shell & prompt
      atuin
      sheldon

      # Editors
      vim

      # Modern CLI & search (ripgrep, eza, fzf are provided via modules/hjem/fish.nix)
      fd
      zoxide
      tree
      jq
      curl
      wget

      # Version control
      git
      lazygit
      jujutsu
      delta
      gh
      git-open

      # Build tools, languages & dev environments
      just
      direnv
      nix-direnv
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
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.has-ancestor
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.ccase
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.comview
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.ktoolbox
    ])
    ++ lib.optionals isDarwin [
      pkgs.ffmpeg
      pkgs.gnused
      pkgs.mas
      pkgs.qpdf
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.age-plugin-se
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.gallery-dl
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.kumono
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.megabasterd
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.unxip
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.yt-dlp
    ];
  # 6. Session environment variables (POSIX script via Hjem environment.loadEnv)
  environment.sessionVariables = {
    ATUIN_NOBIND = "true";
    JJ_CONFIG = "${config.directory}/${platformConfig}/jj/config.toml";
    ZDOTDIR = "$HOME/.config/zsh";
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
  # 7. Native Hjem files (text content & external derivations)
  files = {
    ".local/share/zsh/hm-session-vars.sh".source = config.environment.loadEnv;

    ".config/ghostty/shaders" = {
      source = inputs.ghostty-cursor-shaders;
    };

    ".config/direnv/lib/nix-direnv.sh" = {
      source = "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
    };

    # Unified agent instructions distribution across harnesses
    ".claude/CLAUDE.md".source = ../../AGENTS.md;
    ".codex/AGENTS.md".source = ../../AGENTS.md;
    ".config/opencode/AGENTS.md".source = ../../AGENTS.md;
  };
  # 8. Hjem-Rum module ecosystem (under rum.programs.*)
  rum.programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "Yu-Min Peng";
          email = "leporuid@icloud.com";
        };
      };
    };
  };
}
