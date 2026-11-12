{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # 1. Modular feature imports in moni-dz style
  imports = [
    ../../modules/hjem
  ];

  # 2. Hjem-Impure: out-of-store symlinking for live dotfile editing without rebuilds
  impure = {
    enable = true;
    dotsDir = "${../../config}";
    dotsDirImpure = "/Users/leporuid/Developer/nixos-and-darwin-shared-hjem/config";
  };

  # 3. Enable domain modules
  my.themes.enable = true;
  my.programs.fish.enable = true;
  my.programs.neovim.enable = true;

  # 4. Declarative configuration synthesis engine (my-config)
  my.config = {
    directory = "/Users/leporuid/Developer/nixos-and-darwin-shared-hjem/config";
    storeDirectory = ../../config;
    source = {
      # Shells
      ".config/nushell" = "nushell";
      ".config/starship.toml" = "starship.toml";
      ".config/sheldon" = "sheldon";
      ".config/zsh" = "zsh";
      ".zshenv" = "zsh/home_zshenv";

      # Development & Editors
      ".config/helix" = "helix";
      ".config/zed" = "zed";
      ".config/tmux" = "tmux";
      ".config/zellij" = "zellij";

      # Terminals
      ".config/ghostty" = "ghostty";
      ".config/foot" = "foot";
      ".config/kitty" = "kitty";

      # Version Control & Tools
      ".config/git" = "git";
      ".config/jj" = "jj";
      ".config/direnv" = "direnv";
      ".config/atuin" = "atuin";
      ".config/mise" = "mise";
      ".config/gallery-dl" = "gallery-dl";
      ".config/syntax-highlight" = "syntax-highlight";
      ".npmrc" = "npm/npmrc";

      # macOS Utilities
      ".config/btt" = "btt";
      ".config/raycast" = "raycast";

      # Agents & Skills
      ".claude/settings.json" = "claude/settings.json";
      ".agents/skills" = "agents/skills";
      ".claude/skills" = "agents/skills";
      ".gemini/skills" = "gemini/skills";
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
    helix
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

  # 6. Native Hjem files (text content & external derivations)
  files = {
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
  };

  # 7. Hjem-Rum module ecosystem (under rum.programs.*)
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
