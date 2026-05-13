{
  pkgs,
  inputs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages =
    [
      perSystem.home-manager.default
      perSystem.agenix.default
      perSystem.nix-darwin.default
      perSystem.self.run
      pkgs.nixd
      pkgs.taplo
      pkgs.age
      pkgs.deno
    ]
    ++ pkgs.lib.optional pkgs.stdenv.isLinux pkgs.nixos-rebuild
    ++ pkgs.lib.optional pkgs.stdenv.isLinux pkgs.nixos-anywhere;

  shellHook = ''
    export IN_NIX_CONFIG_DEVSHELL=1
  '';
}