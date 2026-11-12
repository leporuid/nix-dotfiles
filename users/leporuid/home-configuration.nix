{ pkgs, ... }:
let
  dots = ./dots;
in
{
  # 1. Hjem-Impure: out-of-store symlinking for live dotfile editing without rebuilds
  impure = {
    enable = true;
    dotsDir = "${./dots}";
    dotsDirImpure = "/Users/leporuid/Developer/nixos-and-darwin-shared-hjem/users/leporuid/dots";
  };

  # 2. User packages installed directly to user environment
  packages = with pkgs; [
    nushell
    carapace
    starship
    bat
    fd
    lazygit
    zoxide
    atuin
    direnv
  ];

  # 3. Native Hjem file linking (managed via dots directory)
  files = {
    ".config/welcome.txt".text = ''
      Welcome Yu-Min Peng!
      Your home files and configurations are managed by Hjem + Hjem-Rum + Hjem-Impure on red-tape.
    '';
    ".config/nushell/config.nu".source = dots + "/nushell/config.nu";
    ".config/nushell/env.nu".source = dots + "/nushell/env.nu";
    ".config/starship.toml".source = dots + "/starship.toml";
  };

  # 4. Hjem-Rum module ecosystem (under rum.programs.*)
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
