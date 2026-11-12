{ pkgs, ... }:
{
  # 1. Native Hjem file linking (out-of-store symlinks and text generation)
  files = {
    ".config/welcome.txt".text = ''
      Welcome Yu-Min Peng!
      Your home files and configurations are managed by Hjem + Hjem-Rum on red-tape.
    '';
  };

  # 2. Hjem-Rum module ecosystem (replaces Home Manager programs.*)
  programs = {
    git = {
      enable = true;
      userName = "Yu-Min Peng";
      userEmail = "leporuid@icloud.com";
    };
  };
}
