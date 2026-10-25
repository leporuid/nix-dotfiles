{
  pkgs,
  perSystem,
  inputs,
}:
let
   determinateNix = inputs.determinate.inputs.nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
      (pkgs.nixos-rebuild.override {
        nix = determinateNix;
      })
      (pkgs.nixos-anywhere.override {
        nix = determinateNix;
      })
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      perSystem.nix-darwin.default
    ];

  shellHook = ''
    export IN_NIX_CONFIG_DEVSHELL=1
  '';
}
