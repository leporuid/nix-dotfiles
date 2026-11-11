{
  inputs,
  pkgs,
  config,
  lib,
  vars,
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
    nix-index-database.darwinModules.nix-index
  ];

  # =========================================================================
  # 2. Environment, System Packages, and Local DNS Settings
  # =========================================================================
  environment.etc = {
    "resolver/ts.net".text = ''
      nameserver 100.100.100.100
    '';

    # Clear Determinate CLI Sentry endpoint to eliminate telemetry leakage (from jake-edmonstone)
    "nix/sentry-endpoint".text = "";
  };

  environment.systemPackages = with pkgs; [
    fish
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
  programs.zsh = {
    promptInit = "";
    enableGlobalCompInit = false;
    enableBashCompletion = false;
  };
  programs.fish = {
    enable = true;
    useBabelfish = true;
    interactiveShellInit = ''
      if test "$TERM" = "dumb"
        function fish_prompt
          echo "\$ "
        end

        function fish_right_prompt; end
        function fish_greeting; end
        function fish_title; end
      end
    '';
  };
  users.users.${config.system.primaryUser}.shell = pkgs.fish;
  documentation.doc.enable = false;
  home-manager.backupFileExtension = "hm-backup";

  determinateNix = {
    enable = true;

    determinateNixd = {
      garbageCollector.strategy = "automatic";
      builder.state = "enabled";
      telemetry.sentry.endpoint = null;
    };

    inherit (vars) customSettings;
  };

  launchd.daemons.determinate-nix-daemon.serviceConfig = {
    SoftResourceLimits.NumberOfFiles = 1048576;
    HardResourceLimits.NumberOfFiles = 1048576;
  };

  # macOS default kern.tty.ptmx_max is 511. Heavy developer/Electron tools (VS Code, Cursor, Ghostty)
  # leak PTYs over long sessions, leading to `posix_openpt: Device not configured (ENXIO)`.
  # Raise to XNU's safe upper ceiling (999).
  launchd.daemons.sysctl-ptmx = {
    script = "/usr/sbin/sysctl -w kern.tty.ptmx_max=999 || true";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
    };
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
    configurationRevision = inputs.self.sourceInfo.shortRev or inputs.self.dirtyShortRev or null;

    activationScripts = {
      # Session-aware settings activation without requiring user logout
      postActivation.text = ''
        _uid=$(id -u ${config.system.primaryUser})
        if [ -n "$_uid" ]; then
          launchctl asuser "$_uid" sudo --user=${config.system.primaryUser} -- \
            /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
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
        NewWindowTarget = "Home";
        QuitMenuItem = true;
        _FXSortFoldersFirst = true;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        expose-animation-duration = 0.1;
        launchanim = false;
        mineffect = "scale";
        mru-spaces = false;
        show-process-indicators = true;
        show-recents = false;
        showhidden = true;
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
        "com.apple.screencapture" = {
          location = "/Volumes/SDXC/Screenshots";
          type = "png";
          "show-thumbnail" = false;
          target = "clipboard";
          "disable-shadow" = true;
        };
      };
    };
  };
}
