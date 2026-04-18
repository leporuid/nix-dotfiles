{ pkgs, home-manager, agenix, run, nix-darwin, flake, ... }:
pkgs.mkShellNoCC {
  packages = [
    home-manager
    agenix
    run
    pkgs.nixd
    pkgs.taplo
    pkgs.age
    pkgs.deno
    nix-darwin
  ]
  ++ pkgs.lib.optional pkgs.stdenv.isLinux pkgs.nixos-rebuild
  ++ pkgs.lib.optional pkgs.stdenv.isLinux pkgs.nixos-anywhere;

  shellHook = ''
    export IN_NIX_CONFIG_DEVSHELL=1
    export NIX_CONFIG_REV=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
    export NIX_CONFIG_LAST_MODIFIED=$(git log -1 --format=%at 2>/dev/null || echo "0")
  '';
}