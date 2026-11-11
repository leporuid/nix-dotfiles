# treefmt.nix
# Unified code formatter and linter configuration powered by treefmt-nix.
_:
{
  projectRootFile = "flake.nix";

  # Nix formatting and dead-code / anti-pattern linting
  programs.nixfmt.enable = true;
  programs.deadnix.enable = true;
  programs.statix.enable = true;

  # Shell & Fish script formatting
  programs.shfmt.enable = true;
  programs.fish_indent.enable = true;

  # Configuration & Data formats
  programs.taplo.enable = true;
  programs.yamlfmt.enable = true;

  # Global exclusions
  settings.global.excludes = [
    # Encrypted files & secrets
    "*.age"
    "secrets/**"

    # Lockfiles & local caches
    "flake.lock"
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
}
