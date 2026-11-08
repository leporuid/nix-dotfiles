{
  pkgs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages = [
    perSystem.llm-agents.antigravity-cli
    perSystem.llm-agents.default
    perSystem.home-manager.default
    # Agenix uses rage by default which lacks age-plugin support; override with age for age-plugin-se
    (perSystem.agenix.default.override {
      ageBin = "${pkgs.age}/bin/age";
    })
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
    perSystem.self.age-plugin-se
  ];

  shellHook = ''
    export IN_NIX_CONFIG_DEVSHELL=1
  '';
}
