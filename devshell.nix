{
  pkgs,
  perSystem,
  inputs,
}:
let
   nixos-rebuild = pkgs.writeShellScriptBin "nixos-rebuild" ''
    exec ${inputs.determinate.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.nixos-rebuild-ng}/bin/nixos-rebuild "$@"
  '';
in
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
      nixos-rebuild
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      perSystem.nix-darwin.default
    ];

  shellHook = ''
    export IN_NIX_CONFIG_DEVSHELL=1
  '';
}
