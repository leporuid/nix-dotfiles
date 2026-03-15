{ inputs, flake, config, pkgs, lib, ...}:
with lib;
{
  imports = [
  inputs.determinate.darwinModules.default
  inputs.nix-homebrew.darwinModules.nix-homebrew
  ];
  environment.systemPackages = with pkgs; [
    coreutils
    mosh  # system-level so non-interactive SSH can find mosh-server
    tmux  # better than zellij for iOS terminals (scroll mode works with touch)
    atuin
    aria2
    bun
    starship
    mise
    ffmpeg
    yt-dlp
    gallery-dl
    qpdf
    zellij
  ];
  system.configurationRevision = flake.rev or flake.dirtyRev or null;
  # ============================================================================
  # Determinate Nix Integration
  # ============================================================================
  # Official module — automatically sets nix.enable = false and manages
  # /etc/nix/nix.custom.conf + /etc/determinate/config.json declaratively.
  determinateNix = {
    enable = true;

    # ============================================================================
    # Nix Store Settings (written to /etc/nix/nix.custom.conf)
    # ============================================================================
    customSettings = {
      # Hard-link identical files in the store to save disk space
      # Runs during every build — slight build-time cost for ongoing savings
      # Default: false
      auto-optimise-store = true;
      trusted-users = [
      "@admin"
      "root"
      "${config.system.primaryUser}"
     ];
      accept-flake-config = true;
      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      extra-experimental-features = [
      "build-time-fetch-tree" # Enables build-time flake inputs
      "parallel-eval" # Enables parallel evaluation
      ];
      builders-use-substitutes = true;
      fallback = true;
      warn-dirty = false;
      # Minimum free disk space (bytes) before Nix triggers GC during builds
      # 1 GiB — if free space drops below this mid-build, Nix GCs until max-free
      # Default: 0 (disabled)
      min-free = 1073741824;

      # Target free disk space (bytes) after min-free triggers GC
      # 5 GiB — Nix collects garbage until this much space is free
      # Default: unlimited
      max-free = 5368709120;

      # -- Defaults left commented for awareness --
      # max-jobs = "auto";           # Parallel build jobs (set by Determinate Nix)
      # keep-build-log = true;       # Retain build logs for debugging
      # keep-derivations = true;     # Keep .drv files (needed for nix log)
      # keep-outputs = true;         # Keep outputs reachable from installed packages
    };

    # ============================================================================
    # Determinate Nixd Garbage Collector
    # ============================================================================
    # Built-in to determinate-nixd — no launchd daemon needed.
    # Automatic mode targets: 30GB minimum free, 5-20% steady-state free,
    # urgent cleanup below 5% free.
    determinateNixd = {
      garbageCollector = {
        # "automatic" — determinate-nixd manages GC in the background
        # "disabled" — no automatic GC (manual only: nix-collect-garbage -d)
        strategy = "automatic";
      };
    };
  };

  # ============================================================================
  # Home-manager compatibility workaround
  # ============================================================================
  # home-manager's darwin module accesses nix.package even when nix is disabled
  # See: https://github.com/nix-community/home-manager/issues/4026
  nix.package = lib.mkForce pkgs.nix;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
 launchd.daemons.nix-daemon.serviceConfig = {
      SoftResourceLimits.NumberOfFiles = 40960;
      HardResourceLimits.NumberOfFiles = 40960;
    };
}