{ inputs, ... }:
{
  pkgs,
  config,
  lib,
  nixCaches,
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
    inputs.self.modules.common.vars
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
  # and ensures SSH sessions automatically source the Nix daemon environment.
  environment.extraInit = lib.mkForce ''
    export NIX_PATH="nixpkgs=${inputs.nixpkgs.outPath}:home-manager=${inputs.home-manager.outPath}:$NIX_PATH"

    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && [ -n "''${SSH_CONNECTION:-}" ] && [ "''${SHLVL:-0}" -eq 1 ]; then
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
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

  # Exclude ~/.nix-profile from PATH and keep strictly per-user and system profiles
  environment.profiles = lib.mkForce [
    "/etc/profiles/per-user/${config.system.primaryUser}"
    "/run/current-system/sw"
    "/nix/var/nix/profiles/default"
  ];

  environment.pathsToLink = [
    "/share/fish/vendor_completions.d"
    "/share/fish/vendor_functions.d"
    "/Applications"
  ];

  # =========================================================================
  # 3. Nix Core and Determinate Installer Integration
  # =========================================================================

  documentation.doc.enable = false;
  home-manager.backupFileExtension = "hm-backup";

  determinateNix = {
    enable = true;

    determinateNixd = {
      garbageCollector.strategy = "automatic";
      builder.state = "enabled";
    };

    customSettings = {
      inherit (nixCaches) extra-substituters extra-trusted-public-keys;

      # Performance and storage optimization for macOS APFS
      accept-flake-config = true;
      auto-optimise-store = false;
      builders-use-substitutes = true;
      connect-timeout = 5;
      eval-cores = 0;
      fallback = true;
      http-connections = 50;
      keep-derivations = true;
      keep-going = true;
      keep-outputs = true;
      lazy-trees = true;
      log-lines = 25;
      max-free = 3221225472;
      max-jobs = "auto";
      min-free = 1073741824;
      stalled-download-timeout = 20;
      warn-dirty = false;

      extra-trusted-users = [
        "@admin"
        config.system.primaryUser
      ];
      extra-experimental-features = [
        "parallel-eval"
        "provenance"
      ];
    };
  };

  launchd.daemons.determinate-nix-daemon.serviceConfig = {
    SoftResourceLimits.NumberOfFiles = 1048576;
    HardResourceLimits.NumberOfFiles = 1048576;
  };

  # =========================================================================
  # 4. macOS System Architecture and Native Configurations
  # =========================================================================
  system = {
    tools.darwin-uninstaller.enable = false;
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    activationScripts = {
      postActivation.text = ''
        sudo -u ${config.system.primaryUser} \
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

        # Automatically link Home Manager Applications to /Applications
        hmApps="/Users/${config.system.primaryUser}/Applications/Home Manager Apps"
        if [ -d "$hmApps" ]; then
          echo "Linking Home Manager Applications to /Applications..."
          for app in "$hmApps"/*.app; do
            if [ -e "$app" ]; then
              appName="$(basename "$app")"
              target="/Applications/$appName"
              if [ -d "$target" ] && [ ! -L "$target" ]; then
                echo "Notice: Removing stale directory $target to link from Home Manager..."
                rm -rf "$target"
              fi
              ln -sfn "$app" "$target"
            fi
          done
        fi
      '';
    };

    defaults = {
      loginwindow.GuestEnabled = false;

      LaunchServices.LSQuarantine = false;

      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "clmv";
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        _FXSortFoldersFirst = true;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.15;
        show-recents = false;
        showhidden = true;
        mru-spaces = false;
        launchanim = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;
        AppleShowAllExtensions = true;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSWindowResizeTime = 0.001;
        NSWindowShouldDragOnGesture = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        "com.apple.sound.beep.feedback" = 0;
      };

      CustomUserPreferences = {
        "NSGlobalDomain" = {
          QLPanelAnimationDuration = 0.0;
        };
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
