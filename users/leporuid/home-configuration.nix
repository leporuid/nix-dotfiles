{ pkgs, ... }:
let
  configDir = ../../config;
in
{
  # 1. Hjem-Impure: out-of-store symlinking for live dotfile editing without rebuilds
  impure = {
    enable = true;
    dotsDir = "${configDir}";
    dotsDirImpure = "/Users/leporuid/Developer/nixos-and-darwin-shared-hjem/config";
  };

  # 2. User packages installed directly to user environment
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

  # 3. Native Hjem file linking (managed via root config directory)
  files = {
    ".config/welcome.txt".text = ''
      Welcome Yu-Min Peng!
      Your home files and configurations are managed by Hjem + Hjem-Rum + Hjem-Impure on red-tape.
    '';

    # Shell configurations
    ".config/fish".source = configDir + "/fish";
    ".config/nushell/config.nu".source = configDir + "/nushell/config.nu";
    ".config/nushell/env.nu".source = configDir + "/nushell/env.nu";
    ".config/starship.toml".source = configDir + "/starship.toml";
    ".config/sheldon".source = configDir + "/sheldon";

    # Development & Editor configurations
    ".config/nvim".source = configDir + "/nvim";
    ".config/helix".source = configDir + "/helix";
    ".config/zed".source = configDir + "/zed";
    ".config/tmux".source = configDir + "/tmux";
    ".config/zellij".source = configDir + "/zellij";

    # Terminals & Themes
    ".config/ghostty".source = configDir + "/ghostty";
    ".config/foot".source = configDir + "/foot";
    ".config/bat".source = configDir + "/bat";

    # Version Control & Tools
    ".config/git".source = configDir + "/git";
    ".config/jj".source = configDir + "/jj";
    ".config/direnv".source = configDir + "/direnv";
    ".config/atuin".source = configDir + "/atuin";
    ".config/mise".source = configDir + "/mise";
    ".config/gallery-dl".source = configDir + "/gallery-dl";

    # Agent & Skill configurations
    ".claude/settings.json".source = configDir + "/claude/settings.json";
    ".agents/skills".source = configDir + "/agents/skills";
  };

  # 4. Hjem-Rum module ecosystem (under rum.programs.*)
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
