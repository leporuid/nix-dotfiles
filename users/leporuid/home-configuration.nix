{ pkgs, ... }:
{
  # 1. Modular feature imports in moni-dz style
  imports = [
    ../../modules/home
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

      # Development & Editors
      ".config/helix" = "helix";
      ".config/zed" = "zed";
      ".config/tmux" = "tmux";
      ".config/zellij" = "zellij";

      # Terminals
      ".config/ghostty" = "ghostty";
      ".config/foot" = "foot";

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

  # 5. Core developer tools & productivity utilities
  packages = with pkgs; [
    nushell
    carapace
    starship
    sheldon
    helix
    tmux
    zellij
    lazygit
    zoxide
    direnv
    jujutsu
    mise
    jq
    curl
    wget
    tree
  ];

  # 6. Native Hjem files (text content)
  files = {
    ".config/welcome.txt".text = ''
      Welcome Yu-Min Peng!
      Your home files and configurations are managed by Hjem + Hjem-Rum + my-config on red-tape.
    '';
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
