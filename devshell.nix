{
  pkgs,
  perSystem,
  inputs,
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  determinatePkgs =
    inputs.determinate.inputs.nixpkgs.legacyPackages.${system};

  systemNix = pkgs.writeShellScriptBin "nix" ''
    exec /nix/var/nix/profiles/default/bin/nix "$@"
  '';

  nixos-rebuild = pkgs.writeShellScriptBin "nixos-rebuild" ''
    exec ${determinatePkgs.nixos-rebuild-ng}/bin/nixos-rebuild "$@"
  '';

  nixos-anywhere = pkgs.writeShellScriptBin "nixos-anywhere" ''
    exec ${determinatePkgs.nixos-anywhere.override {
      nix = systemNix;
    }}/bin/nixos-anywhere "$@"
  '';
in
pkgs.mkShellNoCC {
  packages = [
    perSystem.home-manager.default
    perSystem.agenix.default
    perSystem.self.run
    pkgs.nixd
    pkgs.taplo
    pkgs.age
    pkgs.deno
    nixos-rebuild
    nixos-anywhere
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      perSystem.nix-darwin.default
    ];

  shellHook = ''
    export IN_NIX_CONFIG_DEVSHELL=1
  '';
}
