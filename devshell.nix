{
  pkgs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages =
    [
      perSystem.home-manager.default
      perSystem.agenix.default
      perSystem.self.run
      pkgs.nixd
      pkgs.taplo
      pkgs.age
      pkgs.deno
      pkgs.nixos-rebuild
      pkgs.nixos-anywhere
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      perSystem.nix-darwin.default
    ];

  shellHook = ''
    export IN_NIX_CONFIG_DEVSHELL=1
  '';
}
