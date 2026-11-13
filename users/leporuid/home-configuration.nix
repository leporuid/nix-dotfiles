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

  # 3. Enable domain modules
  my.themes.enable = true;
  my.programs.fish.enable = true;
  my.programs.neovim.enable = true;
  my.programs.ghostty.enable = true;
  my.programs.helix.enable = true;

  # 4. Declarative configuration synthesis engine (my-config)
  my.config = {
    directory = "${config.directory}/Developer/nix-dotfiles/config";
    storeDirectory = ../../config;
    source = {
      # Shells
      ".config/nushell" = "nushell";
      ".config/starship.toml" = "starship.toml";
      ".config/sheldon" = "sheldon";
      ".config/zsh" = "zsh";
      ".zshenv" = "zsh/home_zshenv";

      # Development & Editors
      ".config/zed" = "zed";
      ".config/tmux" = "tmux";
      ".config/zellij" = "zellij";

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
      ".config/raycast" = "raycast";
    };
  };

  # 5. Core developer tools & productivity utilities
  packages = with pkgs; [
    # Shell & prompt
    nushell
    carapace
    starship
    sheldon

    # Editors & multiplexers
    inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.helix
    tmux
    zellij
    vim

    # Modern CLI & search
    ripgrep
    fd
    eza
    fzf
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
  ];

  # 6. Session environment variables (POSIX script via Hjem environment.loadEnv)
  environment.sessionVariables = {
    ATUIN_NOBIND = "true";
    JJ_CONFIG = "${config.directory}/${platformConfig}/jj/config.toml";
    STARSHIP_CONFIG = "$HOME/.config/starship.toml";
    ZDOTDIR = "$HOME/.config/zsh";
    NIX_CONFIG_REV = inputs.self.rev or inputs.self.dirtyRev or "dirty";
    NIX_CONFIG_DIR = config.my.config.directory;
    NIX_CONFIG_LAST_MODIFIED = builtins.toString (inputs.self.lastModified or 0);
  };

  # 7. Native Hjem files (text content & external derivations)
  files = {
    ".local/share/zsh/hm-session-vars.sh".source = config.environment.loadEnv;

    ".config/welcome.txt".text = ''
      Welcome Yu-Min Peng!
      Your home files and configurations are managed by Hjem + Hjem-Rum + my-config on red-tape.
    '';

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
