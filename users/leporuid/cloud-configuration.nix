{
  pkgs,
  perSystem,
  inputs,
  config,
  lib,
  flake,
  ...
}:
let
  neovimWithDependencies = pkgs.symlinkJoin {
    name = "neovim-with-dependencies";
    paths = [ pkgs.neovim ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/nvim" \
        --prefix PATH : ${
          lib.makeBinPath [
            pkgs.curl
            pkgs.tree-sitter
            pkgs.ripgrep
          ]
        }
    '';
  };

  platformConfig =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support"
    else
      ".config";
in
{
  imports = [
    inputs.self.homeModules.my-config
    inputs.self.homeModules.my-programs-fish
    inputs.self.homeModules.my-programs-neovim
    inputs.self.modules.common.nixpkgs-unstable
    ../../config/nvim/plugins.nix
  ];

  home.packages = [
    (if pkgs.stdenv.hostPlatform.isDarwin then perSystem.helix.helix else pkgs.helix)
    perSystem.self.has-ancestor
    perSystem.self.ccase
    perSystem.self.comview
    neovimWithDependencies

    perSystem.self.atuin
    pkgs.ast-grep
    pkgs.bat
    pkgs.bun
    pkgs.curl
    pkgs.delta
    pkgs.direnv
    pkgs.eza
    pkgs.fd
    pkgs.fish
    pkgs.fish-lsp
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.git-open
    pkgs.gum
    pkgs.home-manager
    pkgs.jq
    pkgs.jujutsu
    pkgs.just
    pkgs.lazygit
    pkgs.mise
    pkgs.nix-direnv
    pkgs.nixfmt
    pkgs.nix-output-monitor
    pkgs.nushell
    pkgs.ripgrep
    pkgs.starship
    pkgs.tealdeer
    pkgs.tmux
    pkgs.tree
    pkgs.uv
    pkgs.vim
    pkgs.wget
    pkgs.zellij
    pkgs.zoxide
    # Fonts
    pkgs.nerd-fonts.roboto-mono
  ];

  fonts.fontconfig.enable = !pkgs.stdenv.hostPlatform.isDarwin;

  programs.starship.settings = builtins.fromTOML (builtins.readFile "${flake}/config/starship.toml");

  programs.bat = {
    config.theme = "Catppuccin Mocha";
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batgrep
      batwatch
    ];
    syntaxes = { };
    themes."Catppuccin Mocha" = {
      src = inputs.catppuccin-bat;
      file = "themes/Catppuccin Mocha.tmTheme";
    };
  };

  my.config.source = {
    ".config/atuin" = "config/atuin";
    ".config/direnv/direnv.toml" = "config/direnv/direnv.toml";
    ".config/fish/completions" = "config/fish/completions";
    ".config/fish/conf.d" = "config/fish/conf.d";
    ".config/fish/config.fish" = "config/fish/config.fish";
    ".config/fish/functions" = "config/fish/functions";
    ".config/git" = "config/git";
    ".config/helix" = "config/helix";
    ".config/mise" = "config/mise";
    ".config/nvim" = "config/nvim";
    ".config/starship.toml" = "config/starship.toml";
    ".config/tmux" = "config/tmux";
    ".config/zellij" = "config/zellij";
    ".config/zsh" = "config/zsh";
    ".zshenv" = "config/zsh/home_zshenv";
    ".npmrc" = "config/npm/npmrc";
    "${platformConfig}/jj" = "config/jj";
  };

  # Ensure session variables are in a known path for both standalone HM and system modules.
  home.file.".local/share/zsh/hm-session-vars.sh".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home.file.".config/direnv/lib/nix-direnv.sh".source =
    "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";

  home.sessionVariables = {
    ATUIN_NOBIND = "true";
    BAT_THEME = "Catppuccin Mocha";
    FZF_DEFAULT_OPTS = "--no-sort --reverse --margin=0,1 --exit-0 --select-1 --pointer ▸▹ --prompt • --color bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284,fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf,marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284,selected-bg:#51576d,border:#414559,label:#c6d0f5";
    JJ_CONFIG = "${config.home.homeDirectory}/.config/jj/config.toml";
    ZDOTDIR = "$HOME/.config/zsh";
    NIX_CONFIG_REV = flake.rev or flake.dirtyRev or "unknown";
    NIX_CONFIG_DIR = config.my.config.directory;
    NIX_CONFIG_LAST_MODIFIED = builtins.toString flake.lastModified;
  };
}
