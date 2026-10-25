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
      (pkgs.nixos-rebuild.override {
        nix = pkgs.writeShellScriptBin "nix" ''
        exec /nix/var/nix/profiles/default/bin/$command "$@"
      '';})
      (pkgs.nixos-anywhere.override {
        nix = pkgs.writeShellScriptBin "nix" ''
        exec /nix/var/nix/profiles/default/bin/$command "$@"
      '';})
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      perSystem.nix-darwin.default
    ];

  shellHook = ''
    export IN_NIX_CONFIG_DEVSHELL=1
  '';
}
