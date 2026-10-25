{ ... }:
{
  pkgs,
  ...
}:
{
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      Domains = [ "~." ];
      FallbackDNS = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };

  programs.nix-ld.enable = true;
  environment.enableAllTerminfo = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    jq
    yq-go
    htop
    btop
    tmux
    tree
    eza
    fd
    ripgrep
    fzf
    neovim
    vim
    mosh
    lazygit
    nix-output-monitor
  ];
}
