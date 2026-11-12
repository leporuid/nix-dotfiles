{ pkgs, ... }:
{
  imports = [
    ../../modules/home/my-config.nix
  ];

  # 1. Hjem-Impure: out-of-store symlinking for live dotfile editing without rebuilds
  impure = {
    enable = true;
    dotsDir = "${../../config}";
    dotsDirImpure = "/Users/leporuid/Developer/nixos-and-darwin-shared-hjem/config";
  };

  # 2. Declarative configuration synthesis engine (my-config)
  my.config = {
    directory = "/Users/leporuid/Developer/nixos-and-darwin-shared-hjem/config";
    storeDirectory = ../../config;
    source = {
      # Shells
      ".config/fish" = "fish";
      ".config/nushell" = "nushell";
      ".config/starship.toml" = "starship.toml";
      ".config/sheldon" = "sheldon";

      # Development & Editors
      ".config/nvim" = "nvim";
      ".config/helix" = "helix";
      ".config/zed" = "zed";
      ".config/tmux" = "tmux";
      ".config/zellij" = "zellij";

      # Terminals & Themes
      ".config/ghostty" = "ghostty";
      ".config/foot" = "foot";
      ".config/bat" = "bat";

      # Version Control & Tools
      ".config/git" = "git";
      ".config/jj" = "jj";
      ".config/direnv" = "direnv";
      ".config/atuin" = "atuin";
      ".config/mise" = "mise";
      ".config/gallery-dl" = "gallery-dl";

      # Agents & Skills
      ".claude/settings.json" = "claude/settings.json";
      ".agents/skills" = "agents/skills";
    };
  };

  # 3. User packages installed directly to user environment
  packages = with pkgs; [
    # Shells and Integrations
    fish
    fish-lsp
    nushell
    carapace
    starship
    sheldon

    # Editors & Multiplexers
    neovim
    helix
    tmux
    zellij

    # CLI Productivity Tools
    bat
    eza
    fd
    fzf
    ripgrep
    lazygit
    zoxide
    atuin
    direnv
    jujutsu
    mise
    jq
    curl
    wget
    tree
  ];

  # 4. Native Hjem files (text content)
  files = {
    ".config/welcome.txt".text = ''
      Welcome Yu-Min Peng!
      Your home files and configurations are managed by Hjem + Hjem-Rum + my-config on red-tape.
    '';
  };

  # 5. Hjem-Rum module ecosystem (under rum.programs.*)
  rum.programs = {
    fish = {
      enable = true;
    };
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
