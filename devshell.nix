{ pkgs, inputs, perSystem, ... }:
pkgs.mkShellNoCC {
  name = "nix-dotfiles";
  packages = [
    perSystem.home-manager.default
    perSystem.agenix.default
    perSystem.self.run
    pkgs.nixos-rebuild
    pkgs.nixos-anywhere
    pkgs.nixd
    pkgs.taplo
    pkgs.age
    pkgs.deno
    perSystem.nix-darwin.darwin-rebuild
  ];
  shellHook = ''
    export IN_NIX_CONFIG_DEVSHELL=1
    export NIX_CONFIG_REV=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
    export NIX_CONFIG_LAST_MODIFIED=$(git log -1 --format=%at 2>/dev/null || echo "0")
  '';
}
