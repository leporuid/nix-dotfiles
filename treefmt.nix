# treefmt.nix
# Unified code formatter and linter configuration powered by treefmt-nix.
_: {
  projectRootFile = "flake.nix";
  # Nix formatting and dead-code / anti-pattern linting
  programs = {
    deadnix.enable = true;
    fish_indent.enable = true;
    nixfmt.enable = true;
    shfmt.enable = true;
    statix.enable = true;
    taplo.enable = true;
    yamlfmt.enable = true;
  };
  settings = {
    # Run linters/fixers before nixfmt so formatting settles in a single pass
    formatter = {
      deadnix.priority = 1;
      statix.priority = 2;
      nixfmt.priority = 3;
    };
    # Global exclusions
    global.excludes = [
      # Encrypted files & secrets
      "*.age"
      "secrets/**"

      # Lockfiles, generated hooks & local caches
      "flake.lock"
      ".pre-commit-config.yaml"
      ".direnv/**"
      "result/**"

      # Patches and binaries
      "*.patch"
      "*.tar.gz"
      "*.bttpreset"
      "*.pub"

      # Machine-generated configurations
      "hosts/nixos/hardware-configuration.nix"
      "hosts/nixos/facter.json"
    ];
  };
}
