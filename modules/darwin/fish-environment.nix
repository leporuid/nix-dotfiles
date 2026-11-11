{
  pkgs,
  config,
  ...
}:
let
  babelfishTranslate =
    path: name:
    pkgs.runCommand "${name}.fish" { } ''
      ${pkgs.babelfish}/bin/babelfish < ${path} > $out
    '';
in
{
  # Fish from Nix has a built-in preinit hook looking for /etc/fish/nixos-env-preinit.fish.
  # We preserve terminal-provided PATH entries (the d12frosted technique from seruman/nix.d)
  # while sourcing nix-darwin's setEnvironment.fish translated by babelfish (clo4/nix-dotfiles).
  environment.etc."fish/nixos-env-preinit.fish".text = ''
    if test -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE"
      set -l __inherited_path $PATH

      if test -f /etc/fish/setEnvironment.fish
        source /etc/fish/setEnvironment.fish
      end

      # Ensure Determinate / Nix daemon environment is reliably sourced in preinit
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end

      # Restore inherited terminal PATH entries at the tail to preserve parent tools
      for entry in $__inherited_path
        if test -n "$entry"; and test "$entry" != .; and not contains -- "$entry" $PATH
          set -gx --append PATH "$entry"
        end
      end
      set -e __inherited_path

      set -gx __NIX_DARWIN_SET_ENVIRONMENT_DONE 1
    end
  '';

  environment.etc."fish/setEnvironment.fish".source =
    babelfishTranslate config.system.build.setEnvironment "setEnvironment";
}
