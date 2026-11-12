{ pkgs, ... }:
{
  # 1. Native Hjem file linking (out-of-store symlinks and text generation)
  files = {
    ".config/welcome.txt".text = ''
      Welcome Yu-Min Peng!
      Your home files and configurations are managed by Hjem + Hjem-Rum on red-tape.
    '';
  };

  # 2. Hjem-Rum module ecosystem (under rum.programs.*)
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
