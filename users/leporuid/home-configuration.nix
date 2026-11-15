{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  # Host evaluations receive perSystem as a special arg, standalone Hjem
  # configurations do not; derive it here so both evaluate identically.
  perSystem = inputs.self.lib.mkPerSystem {
    inherit inputs lib;
    system = pkgs.stdenv.hostPlatform.system;
  };
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
      atuin.enable = true;
      direnv.enable = true;
      fish.enable = true;
      ghostty.enable = true;
      helix.enable = isDarwin;
      jujutsu.enable = true;
      neovim.enable = true;
      nushell.enable = true;
      starship.enable = true;
      tmux.enable = true;
      zellij.enable = true;
    };
    # 4. Declarative configuration synthesis engine (my-config)
    config = {
      directory = "${config.directory}/Developer/nix-dotfiles/config";
      storeDirectory = ../../config;
      useOutOfStoreSymlinks = isDarwin;
      source = {
        # Shells
        ".config/sheldon" = "sheldon";
        ".config/zsh" = "zsh";
        ".zshenv" = "zsh/home_zshenv";

        # Version Control & Tools
        ".config/git" = "git";
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
        # macOS GUI & Utilities
        ".config/foot" = "foot";
        ".config/kitty" = "kitty";
        ".config/zed" = "zed";
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
      delta
      gh
      git-open

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
      perSystem.packages.self.has-ancestor
      perSystem.packages.self.ccase
      perSystem.packages.self.ktoolbox
      perSystem.packages.llm-agents.copilot-cli
      perSystem.packages.llm-agents.antigravity-cli
    ])
    ++ lib.optionals isDarwin [
      pkgs.ffmpeg
      pkgs.gnused
      pkgs.mas
      pkgs.qpdf
      perSystem.packages.self.age-plugin-se
      perSystem.packages.self.gallery-dl
      perSystem.packages.self.kumono
      perSystem.packages.self.megabasterd
      perSystem.packages.self.unxip
      perSystem.packages.self.yt-dlp
    ];
  # 6. Session environment variables (POSIX script via Hjem environment.loadEnv)
  environment.sessionVariables = {
    ZDOTDIR = "${config.directory}/.config/zsh";
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

    # Unified agent instructions distribution across harnesses
    ".claude/CLAUDE.md".source = ../../AGENTS.md;
    ".codex/AGENTS.md".source = ../../AGENTS.md;
    ".config/opencode/AGENTS.md".source = ../../AGENTS.md;
  };
  # 8. Hjem-Rum module ecosystem (under rum.programs.*)
}
