{
  flake,
  inputs,
  ...
}:
{
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.my-config
    inputs.self.modules.common.fish-environment
  ];

  programs.bash = {
    completion.enable = true;

    interactiveShellInit = ''
      export HISTFILE="$HOME/.local/share/bash/.bash_history"
      export HISTSIZE=10000
      export HISTFILESIZE=20000
      export HISTCONTROL="ignoreboth:erasedups"

      shopt -s histappend
      shopt -s cmdhist
      shopt -s lithist

      add_to_path() {
        case ":$PATH:" in
          *":$1:"*)
            ;;
          *)
            PATH="$1:$PATH"
            ;;
        esac
      }

      add_to_path "$HOME/.local/bin"
      export PATH

      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING:-} ]] && tty -s; then
        if command -v fish >/dev/null 2>&1; then
          shopt -q login_shell && LOGIN_OPTION="--login" || LOGIN_OPTION=""
          exec "${pkgs.fish}/bin/fish" $LOGIN_OPTION
        fi
      fi
    '';
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile "${flake}/config/fish/config.fish";
  };

  environment.systemPackages = with pkgs; [
    bashInteractive
    fish
    starship
    direnv
    nix-direnv
    zoxide
    fzf
    tmux
    zellij
    git
    gh
    lazygit
    bat
    eza
    fd
    ripgrep
    curl
    wget
    jq
    yq-go
    htop
    btop
    mosh
    jujutsu
    just
    gum
    tree
    uv
    bun
    nushell
    helix
    vim
    neovim
    tealdeer
    nixfmt
    nix-output-monitor
    ast-grep
    delta
  ];

  my.system.config.source = {
    "direnv/direnv.toml" = "config/direnv/direnv.toml";
    "fish/completions" = "config/fish/completions";
    "fish/conf.d" = "config/fish/conf.d";
    "fish/functions" = "config/fish/functions";
    "jj/config.toml" = "config/jj/config.toml";
    "starship.toml" = "config/starship.toml";
  };

  environment.sessionVariables = {
    ATUIN_NOBIND = "true";
    BAT_THEME = "Catppuccin Mocha";
    DIRENV_CONFIG = "/etc/direnv/direnv.toml";
    JJ_CONFIG = "/etc/jj/config.toml";
    STARSHIP_CONFIG = "/etc/starship.toml";
  };
}
