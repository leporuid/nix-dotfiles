{ config, pkgs, lib, perSystem, inputs, flake, ... }@args:
{
  imports = [
    ./cloud-configuration.nix
  ];

  home.sessionVariables = {
    ATUIN_NOBIND = "true";
    FZF_DEFAULT_OPTS = "--no-sort --reverse --margin=0,1 --exit-0 --select-1 --pointer ▸▹ --prompt • --color bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284,fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf,marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284,selected-bg:#51576d,border:#414559,label:#c6d0f5";
  };

  my.config.source =
   let
     platformConfig = if pkgs.stdenv.hostPlatform.isDarwin then "Library/Application Support" else ".config";
   in
   {
    ".config/atuin" = "config/atuin";
    ".config/raycast" = "config/raycast";
    ".config/ghostty/themes" = "config/ghostty/themes";
    ".config/zed" = "config/zed";
  };

  home.packages = with pkgs; [
    atuin
    ffmpeg
    n-m3u8dl-re
    yt-dlp
    gallery-dl
    qpdf
    perSystem.self.kumono
    perSystem.self.age-plugin-se
    megabasterd
    perSystem.self.unxip
    perSystem.ktoolbox.default
    mas
   ];
  
}