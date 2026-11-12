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
  ];

  # 3. Native Hjem file linking (managed via root config directory)
  files = {
    ".config/welcome.txt".text = ''
      Welcome Yu-Min Peng!
      Your home files and configurations are managed by Hjem + Hjem-Rum + Hjem-Impure on red-tape.
    '';
    # Live editable Fish configuration tree
    ".config/fish".source = configDir + "/fish";
    # Nushell configuration files
    ".config/nushell/config.nu".source = configDir + "/nushell/config.nu";
    ".config/nushell/env.nu".source = configDir + "/nushell/env.nu";
    # Starship prompt configuration
    ".config/starship.toml".source = configDir + "/starship.toml";
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
