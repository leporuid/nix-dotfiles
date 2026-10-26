{ inputs, ... }:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  tailscaleBin = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
in
{
  # =========================================================================
  # 1. Imports and System Modules
  # =========================================================================
  imports = [
    inputs.determinate.darwinModules.default
  ];

  # =========================================================================
  # 2. Environment, System Packages, and Local DNS Settings
  # =========================================================================
  environment.etc = {
    "resolver/ts.net".text = ''
      nameserver 100.100.100.100
    '';
  };

  # Safe injection of custom NIX_PATH that works seamlessly alongside determinateNix
  environment.extraInit = lib.mkForce ''
    export NIX_PATH="nixpkgs=${inputs.nixpkgs}:home-manager=${inputs.home-manager}:$NIX_PATH"
  '';

  environment.systemPackages = with pkgs; [
    fish
    pkg-config
    ghostty-bin.terminfo

    (writeShellScriptBin "tailscale" ''
      export TAILSCALE_BE_CLI=1
      exec ${tailscaleBin} "$@"
    '')
  ];

  environment.enableAllTerminfo = true;
  time.timeZone = "Asia/Taipei";

  environment.pathsToLink = [
    "/share/fish/vendor_completions.d"
    "/share/fish/vendor_functions.d"
    "/Applications"
  ];

  # =========================================================================
  # 3. Nix Core and Determinate Installer Integration
  # =========================================================================

  # Bind standard flake registry profiles locally
  nixpkgs.flake.setNixPath = true;
  nixpkgs.flake.setFlakeRegistry = true;
  documentation.doc.enable = false;
  home-manager.backupFileExtension = "hm-backup";

  determinateNix = {
    enable = true;

    determinateNixd = {
      garbageCollector.strategy = "automatic";
      builder.state = "enabled";
    };

    customSettings = {
      # Performance and storage optimization for macOS APFS
      auto-optimise-store = false;
      builders-use-substitutes = true;
       accept-flake-config = true;
      connect-timeout = 5;
      eval-cores = 0;
      keep-going = true;
      warn-dirty = false;
      fallback = true;
      log-lines = 25;
      min-free = 1073741824;
      lazy-trees = true;
      keep-derivations = true;
      keep-outputs = true;

      extra-substituters = [
        "https://cache.numtide.com"
        "https://nix-community.cachix.org"
        "https://crane.cachix.org"
      ];
      extra-trusted-public-keys = [
        # niks3.numtide.com
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        # nix-community.cachix.org
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # crane.cachix.org
        "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
      ];

      extra-trusted-users = [
        "@admin"
        config.system.primaryUser
      ];
      extra-experimental-features = [
        "parallel-eval"
      ];
    };
  };

  # =========================================================================
  # 4. macOS System Architecture and Native Configurations
  # =========================================================================
  system = {
    tools.darwin-uninstaller.enable = false;
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    activationScripts = {
      tailscaleDns.text = ''
        if [ -x "${tailscaleBin}" ] && TAILSCALE_BE_CLI=1 "${tailscaleBin}" status >/dev/null 2>&1; then
          TAILSCALE_BE_CLI=1 "${tailscaleBin}" set --accept-dns=false || true
        fi
      '';

      postActivation.text = ''
        sudo -u ${config.system.primaryUser} \
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
    };

    defaults = {
      loginwindow.GuestEnabled = false;

      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "clmv";
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.15;
        show-recents = false;
        mru-spaces = false;
        launchanim = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        ApplePressAndHoldEnabled = true;
        AppleShowAllExtensions = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSWindowShouldDragOnGesture = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        "com.apple.sound.beep.feedback" = 0;
      };

      CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "64".enabled = false;
            "65".enabled = false;
          };
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };
    };
  };
}
