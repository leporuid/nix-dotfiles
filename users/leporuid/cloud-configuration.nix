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
    if pkgs.stdenv.hostPlatform.isDarwin then "Library/Application Support" else ".config";
in
{
  imports = [
    inputs.self.homeModules.my-config
    inputs.self.homeModules.my-programs-fish
    inputs.self.homeModules.my-programs-neovim
    inputs.self.homeModules.my-themes
    inputs.self.modules.common.nixpkgs-unstable
    ../../config/nvim/plugins.nix
  ];

  home.packages = [
    perSystem.helix.helix
    perSystem.self.has-ancestor
    perSystem.self.ccase
    perSystem.self.comview
    neovimWithDependencies

    pkgs.ast-grep
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
    pkgs.nil
    pkgs.nix-direnv
    pkgs.nixfmt
    pkgs.nix-output-monitor
    pkgs.nushell
    pkgs.ripgrep
    pkgs.starship
    pkgs.taplo
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
    ".config/nushell" = "config/nushell";
    ".config/nvim" = "config/nvim";
    ".config/starship.toml" = "config/starship.toml";
    ".config/syntax-highlight" = "config/syntax-highlight";
    ".config/tmux" = "config/tmux";
    ".config/zellij" = "config/zellij";
    ".config/zsh" = "config/zsh";
    ".zshenv" = "config/zsh/home_zshenv";
    ".npmrc" = "config/npm/npmrc";
    "${platformConfig}/jj" = "config/jj";

    # Agent configurations & skill mappings
    ".claude/settings.json" = "config/claude/settings.json";
    ".agents/skills" = ".agents/skills";
    ".claude/skills" = ".agents/skills";
    ".gemini/skills" = ".agents/skills";
  };

  # Ensure session variables are in a known path for both standalone HM and system modules.
  home.file.".local/share/zsh/hm-session-vars.sh".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home.file.".config/direnv/lib/nix-direnv.sh".source =
    "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";

  # Unified agent instructions distribution across harnesses
  home.file.".claude/CLAUDE.md".source = "${flake}/AGENTS.md";
  home.file.".codex/AGENTS.md".source = "${flake}/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source = "${flake}/AGENTS.md";

  # Ghostty cursor shaders (from wave-os / sahaj-b/ghostty-cursor-shaders)
  home.file.".config/ghostty/shaders".source = inputs.ghostty-cursor-shaders;

  home.sessionVariables = {
    ATUIN_NOBIND = "true";
    JJ_CONFIG = "${config.home.homeDirectory}/${platformConfig}/jj/config.toml";
    ZDOTDIR = "$HOME/.config/zsh";
    NIX_CONFIG_REV = flake.rev or flake.dirtyRev;
    NIX_CONFIG_DIR = config.my.config.directory;
    NIX_CONFIG_LAST_MODIFIED = builtins.toString flake.lastModified;
  };
}
