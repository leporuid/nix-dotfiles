{
  inputs,
  pkgs,
  config,
  lib,
  vars,
  flake,
  ...
}:
with inputs;
{
  # =========================================================================
  # 1. Imports and System Modules
  # =========================================================================
  imports = [
    determinate.darwinModules.default
    self.modules.common.vars
    mac-app-util.darwinModules.default
    nix-index-database.darwinModules.nix-index
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
    export NIX_PATH="nixpkgs=${nixpkgs.outPath}:home-manager=${home-manager.outPath}''${NIX_PATH:+:$NIX_PATH}"

    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && [ -n "''${SSH_CONNECTION:-}" ] && [ "''${SHLVL:-0}" -eq 1 ]; then
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
  '';

  environment.systemPackages = with pkgs; [
    fish
    pkg-config
    ghostty-bin.terminfo
    self.packages.${pkgs.stdenv.hostPlatform.system}.n-m3u8dl-re

    (writeShellApplication {
      name = "tailscale";
      text = ''
        export TAILSCALE_BE_CLI=1
        exec /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
      '';
    })

    (writeShellApplication {
      name = "apfs-purge";
      text = ''
        date
        exec sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -P -minsize 0 /System/Volumes/Data
      '';
    })
  ];

  environment.enableAllTerminfo = true;

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

  programs.nix-index-database.comma.enable = true;

  documentation.doc.enable = false;
  home-manager.backupFileExtension = "hm-backup";

  determinateNix = {
    enable = true;

    determinateNixd = {
      garbageCollector.strategy = "automatic";
      builder.state = "enabled";
    };

    customSettings = {
      inherit (vars.caches) extra-substituters extra-trusted-public-keys;

      nix-path = [
        "nixpkgs=${nixpkgs}"
        "home-manager=${home-manager}"
      ];

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

  # Weekly automated APFS purgeable space and local snapshot reclamation (Plan 2)
  launchd.daemons.apfs-purge = {
    serviceConfig = {
      ProgramArguments = [
        "/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util"
        "-P"
        "-minsize"
        "0"
        "/System/Volumes/Data"
      ];
      StartCalendarInterval = [
        {
          Hour = 3;
          Minute = 0;
          Weekday = 0;
        }
      ];
    };
  };

  # =========================================================================
  # 4. macOS System Architecture and Native Configurations
  # =========================================================================
  system = {
    tools.darwin-uninstaller.enable = false;
    configurationRevision = flake.rev or flake.dirtyRev or null;

    activationScripts = {
      # Disable default symlinking of system packages to /Applications/Nix Apps
      applications.text = lib.mkForce "";

      postActivation.text = ''
        sudo -u ${config.system.primaryUser} \
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

        # Clean up legacy Nix Apps symlink directory if present
        rm -rf "/Applications/Nix Apps"

        # Physically copy M3U8DLProtocol.app to /Applications via APFS clone without symlinks
        m3u8App="${self.packages.${pkgs.stdenv.hostPlatform.system}.n-m3u8dl-re}/Applications/M3U8DLProtocol.app"
        if [ -d "$m3u8App" ]; then
          rm -rf /Applications/M3U8DLProtocol.app
          /bin/cp -cR "$m3u8App" /Applications/M3U8DLProtocol.app 2>/dev/null || /bin/cp -R "$m3u8App" /Applications/M3U8DLProtocol.app
          chmod -R u+w /Applications/M3U8DLProtocol.app
        fi

        # Physically copy Discord.app to /Applications via APFS clone to allow Vencord patching
        discordPkg="${config.programs.nixcord.discord.package}"
        if [ -d "$discordPkg/Applications/Discord.app" ]; then
          rm -rf /Applications/Discord.app
          /bin/cp -cR "$discordPkg/Applications/Discord.app" /Applications/Discord.app 2>/dev/null || /bin/cp -R "$discordPkg/Applications/Discord.app" /Applications/Discord.app
          chmod -R u+w /Applications/Discord.app
        fi

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
        Dragging = true;
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

  # =========================================================================
  # 5. User Account Specifications (nixelium style)
  # =========================================================================
  users.users.root = {
    home = "/var/root";
    shell = "/bin/zsh";
    uid = 0;
  };
}
