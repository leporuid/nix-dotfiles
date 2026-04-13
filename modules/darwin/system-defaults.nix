{ inputs, flake, config, pkgs, lib, self, ...}:
let username = "leporuid"; in
with lib;
{
  imports = [
  inputs.determinate.darwinModules.default
  ];

  environment.etc."nix/flake-registry.json" = 
    let
      entry = id: to: {
        from = {
          inherit id;
          type = "indirect";
        };
        inherit to;
      };

      flakehub =
        id: org: flake: version:
        entry id {
          type = "tarball";
          url = "https://flakehub.com/f/${org}/${flake}/${version}";
        };

      github =
        id: owner: repo:
        entry id {
          type = "github";
          inherit owner repo;
        };
    in
    lib.mkIf (config.determinateNix.registry != null) {
    text = builtins.toJSON {
      version = 2;
      flakes = lib.mapAttrsToList (_n: v: {inherit (v) from to exact;}) config.determinateNix.registry;
    };
  };

  environment.systemPackages = with inputs.nix-darwin.packages.${pkgs.stdenv.hostPlatform.system}; [
        darwin-option
        darwin-rebuild
        darwin-version
        darwin-uninstaller
      ];

  ids.gids.nixbld = 350;
  programs.fish.useBabelfish = true;
  environment.variables = {
        MANPATH = "${config.system.path}/share/man";
     };

  # ============================================================================
  # Determinate Nix Integration
  # ============================================================================
  # Official module — automatically sets nix.enable = false and manages
  # /etc/nix/nix.custom.conf + /etc/determinate/config.json declaratively.
  determinateNix = {
    enable = true;
    distributedBuilds = true;
    determinateNixd = {
      builder.cpuCount = 4;
      builder.memoryBytes = 16 * 1024 * 1024;
      builder.state = "disabled";
    };
    # ============================================================================
    # Nix Store Settings (written to /etc/nix/nix.custom.conf)
    # ============================================================================
    customSettings = {
      # Hard-link identical files in the store to save disk space
      # Runs during every build — slight build-time cost for ongoing savings
      # Default: false
      eval-cores = 0;
      auto-optimise-store = true;
      trusted-users = [      
      "root"
      "@admin"
      username
     ];
      accept-flake-config = true;
      substituters = [
          # high priority since it's almost always used
          "https://cache.nixos.org?priority=10"
          "https://install.determinate.systems"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM"
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      extra-experimental-features = [
        "build-time-fetch-tree"
        "external-builders"
        "parallel-eval"
        "wasm-builtin"
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
      log-lines = 25;
    };
  };

  system = {
    configurationRevision = config._module.args.self.rev or config._module.args.self.dirtyRev or null;
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
