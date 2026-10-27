{
  pkgs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages = [
    perSystem.home-manager.default
    perSystem.agenix.default
    perSystem.self.run
    perSystem.self.nixos-rebuild
    perSystem.self.nixos-anywhere
    pkgs.nixd
    pkgs.taplo
    pkgs.age
    pkgs.deno
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    perSystem.nix-darwin.default
  ];

  shellHook = ''
    export IN_NIX_CONFIG_DEVSHELL=1
  '';
}
