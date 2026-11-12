{ pkgs, ... }:
{
  # 1. Native Hjem file linking (out-of-store symlinks and text generation)
  files = {
    ".config/welcome.txt".text = ''
      Welcome! Your home files and configurations are managed by Hjem + Hjem-Rum.
      Enjoy a lightweight, Home-Manager-free declarative setup!
    '';
  };

  # 2. Hjem-Rum module ecosystem (replaces Home Manager programs.*)
  programs = {
    git = {
      enable = true;
      userName = "Me";
      userEmail = "me@example.com";
    };
  };
}
