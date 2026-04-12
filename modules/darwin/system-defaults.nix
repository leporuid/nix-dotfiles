{ inputs, flake, config, pkgs, lib, ...}:
with lib;
{
  imports = [
  inputs.determinate.darwinModules.default
  ];
  environment.systemPackages = with pkgs; [
    coreutils
    mosh  # system-level so non-interactive SSH can find mosh-server
    tmux  # better than zellij for iOS terminals (scroll mode works with touch)
  ];
  environment.extraInit = ''
    [[ -d /opt/homebrew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ] && [ -n "''${SSH_CONNECTION:-}" ] && [ "''${SHLVL:-0}" -eq 1 ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
  '';
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  ids.gids.nixbld = 350;

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
      "root"
      "@admin"
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

  system = {
    defaults = {
      loginwindow = {
        GuestEnabled = false;
      };

      finder = {
        AppleShowAllFiles = true; # hidden files
        AppleShowAllExtensions = true; # file extensions
        #_FXShowPosixPathInTitle = true; # title bar full path
        ShowPathbar = true; # breadcrumb nav at bottom
        ShowStatusBar = true; # file count & disk space
    	# This magic string makes it search the current folder by default
    	FXDefaultSearchScope = "SCcf";
    	# Use the column view by default (the obviously correct and best view)
    	FXPreferredViewStyle = "clmv";
      };
      
      dock.autohide = true;

      NSGlobalDomain = {
        ApplePressAndHoldEnabled = true;
    	AppleShowAllExtensions = true;
    	NSAutomaticCapitalizationEnabled = false;
    	NSAutomaticPeriodSubstitutionEnabled = false;
    	NSAutomaticSpellingCorrectionEnabled = false;
    	NSWindowShouldDragOnGesture = true;
    	InitialKeyRepeat = 15;
    	KeyRepeat = 2;
    	# Explicitly enabling media keys because the media keycodes themselves are
    	# used for some shortcuts
    	"com.apple.keyboard.fnState" = false;
      };
    };
  };
}