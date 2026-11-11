{ ... }:
{
  programs.fish.shellInit = ''
    if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish' && test -n "$SSH_CONNECTION"
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
  '';
}
