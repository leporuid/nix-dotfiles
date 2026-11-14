{
  inputs,
  lib,
  pkgs,
  perSystem,
  ...
}:
let
  pre-commit-check = import ./git-hooks.nix { inherit inputs pkgs; };
in
pkgs.mkShellNoCC {
  packages =
    pre-commit-check.enabledPackages
    ++ [
      perSystem.self.pre-commit-check.passthru.treefmt
      perSystem.llm-agents.copilot-cli
      perSystem.llm-agents.antigravity-cli
      perSystem.llm-agents.default
      # Agenix uses rage by default which lacks age-plugin support; override with age for age-plugin-se
      (perSystem.agenix.default.override {
        ageBin = "${pkgs.age}/bin/age";
      })
      perSystem.self.run
      perSystem.self.nixos-rebuild
      perSystem.self.nixos-anywhere
      pkgs.actionlint
      pkgs.age
      pkgs.deadnix
      pkgs.deno
      pkgs.just
      pkgs.nil
      pkgs.nixd
      pkgs.nixfmt
      pkgs.pedantix
      pkgs.rage
      pkgs.shellcheck
      pkgs.statix
      pkgs.taplo
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      perSystem.nix-darwin.default
      perSystem.self.age-plugin-se
    ];

  shellHook = ''
    ${pre-commit-check.shellHook}
    export IN_NIX_CONFIG_DEVSHELL=1
  '';
}
