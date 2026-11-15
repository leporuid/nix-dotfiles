{ inputs, ... }:
{
  imports = [
    inputs.self.hjemModules.my-config
    inputs.self.hjemModules.themes
    inputs.self.hjemModules.agents
    inputs.self.hjemModules.neovim
    inputs.self.hjemModules.fish
    inputs.self.hjemModules.git
    inputs.self.hjemModules.helix
    inputs.self.hjemModules.zellij
    inputs.self.hjemModules.tmux
    inputs.self.hjemModules.starship
    inputs.self.hjemModules.nushell
    inputs.self.hjemModules.ghostty
    inputs.self.hjemModules.atuin
    inputs.self.hjemModules.direnv
    inputs.self.hjemModules.direnv-instant
    inputs.self.hjemModules.jujutsu
    inputs.self.hjemModules.zsh
  ];
}
