# Declarative terminal themes, Bat Catppuccin Mocha theme, and styled tool variables.
{
  pkgs,
  flake,
  lib,
  ...
}:
let
  # Precompile bat themes into the Nix store at build time.
  batCache = pkgs.runCommand "bat-cache" {
    nativeBuildInputs = [ pkgs.bat ];
  } ''
    bat cache --build --source "${flake}/config/bat" --target "$out"
  '';
in
{
  # =========================================================================
  # 1. Ghostty Theme (Native Base File + Merging via my.config.source)
  # =========================================================================
  my.config.source = {
    # Uses config/ghostty/themes/Glass as the base file, fully supporting lib.mkMerge and overrides
    ".config/ghostty/themes/Glass" = {
      base = "config/ghostty/themes/Glass";
    };
  };

  # =========================================================================
  # 2. Bat Wrapped via writeShellApplication (Direct package, No programs.bat activation)
  # =========================================================================
  home.packages = [
    (pkgs.writeShellApplication {
      name = "bat";
      runtimeInputs = [ pkgs.bat ];
      text = ''
        export BAT_THEME="Catppuccin Mocha"
        export BAT_CACHE_PATH="${batCache}"
        exec bat "$@"
      '';
    })
    pkgs.bat-extras.batdiff
    pkgs.bat-extras.batman
    pkgs.bat-extras.batgrep
    pkgs.bat-extras.batwatch
  ];

  # =========================================================================
  # 3. Environment Variables
  # =========================================================================
  home.sessionVariables = {
    BAT_THEME = "Catppuccin Mocha";
    BAT_CACHE_PATH = "${batCache}";
    MANPAGER = "batman";
    FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
      "--no-sort"
      "--reverse"
      "--margin=0,1"
      "--exit-0"
      "--select-1"
      "--pointer '▸▹'"
      "--prompt '• '"
      "--color 'bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284,fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf,marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284,selected-bg:#51576d,border:#414559,label:#c6d0f5'"
    ];
  };
}
