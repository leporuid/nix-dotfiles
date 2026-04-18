# This is the shared user configuration applied and customised by each
# host's `leporuid` user.
{
  pkgs,
  config,
  inputs,
  ...
}:
let

  neovimWithDependencies = pkgs.symlinkJoin {
    name = "neovim-with-dependencies";
    paths = [ pkgs.neovim ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix PATH : ${
          pkgs.lib.makeBinPath [
            pkgs.curl
            pkgs.tree-sitter
            pkgs.ripgrep
          ]
        }
    '';
  };
in
{
  imports = [
    inputs.self.homeModules.my-config
    inputs.self.homeModules.my-programs-fish
    inputs.self.homeModules.my-programs-neovim

    ./darwin.nix
    ../../config/nvim/plugins.nix
  ];

  home.packages = [
    pkgs.my.hx
    pkgs.my.has-ancestor
    pkgs.my.schemat
    pkgs.my.ccase

    pkgs.ast-grep
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
    neovimWithDependencies
    pkgs.nix-direnv
    pkgs.nixfmt
    pkgs.nix-output-monitor
    pkgs.nushell
    pkgs.ripgrep
    pkgs.stripe-cli
    pkgs.tealdeer
    pkgs.tmux
    pkgs.tree
    pkgs.vim
    pkgs.wget
    pkgs.zoxide
    pkgs.nerd-fonts.roboto-mono
  ];

  fonts.fontconfig.enable = !pkgs.stdenv.isDarwin;

  my.config.source =
    let
      platformConfig = if pkgs.stdenv.isDarwin then "Library/Application Support" else ".config";
    in
    {
      ".config/ghostty/config" = "config/ghostty/config";
      ".config/ghostty/os-config" =
        if pkgs.stdenv.isDarwin then
          "config/ghostty/os-config-darwin"
        else
          "config/ghostty/os-config-linux";

      ".config/kitty" = "config/kitty";
      ".config/helix" = "config/helix";
      ".config/nvim" = "config/nvim";
      ".config/tmux" = "config/tmux";
      ".config/git" = "config/git";
      "${platformConfig}/jj" = "config/jj";
      ".config/direnv/direnv.toml" = "config/direnv/direnv.toml";
      ".config/mise" = "config/mise";

      ".config/fish/conf.d" = "config/fish/conf.d";
      ".config/fish/functions" = "config/fish/functions";
      ".config/fish/completions" = "config/fish/completions";
      ".config/fish/config.fish" = "config/fish/config.fish";

      ".zshenv" = "config/zsh/home_zshenv";
      ".config/zsh" = "config/zsh";
      ".npmrc" = "config/npm/npmrc";
    };

  home.file.".local/share/zsh/hm-session-vars.sh".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home.sessionVariables.ZDOTDIR = "${config.home.homeDirectory}/.config/zsh";

  home.file.".config/direnv/lib/nix-direnv.sh".source =
    "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";

  my.programs.fish.plugins = [
    (pkgs.fetchFromGitHub {
      owner = "IlanCosman";
      repo = "tide";
      rev = "fcda500d2c2996e25456fb46cd1a5532b3157b16";
      hash = "sha256-dzYEYC1bYP0rWpmz0fmBFwskxWYuKBMTssMELXXz5H0=";
    })
  ];

  home.sessionVariables.NIX_CONFIG_REV = "unknown";
  home.sessionVariables.NIX_CONFIG_DIR = config.my.config.directory;
  home.sessionVariables.NIX_CONFIG_LAST_MODIFIED = "0";
}