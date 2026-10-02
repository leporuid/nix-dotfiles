{ inputs, flake, config, pkgs, lib, ... }:

with lib;
{
  imports = [
    inputs.determinate.darwinModules.default
  ];

  documentation.doc.enable = false;

  ids.gids.nixbld = 350;

  home-manager.backupFileExtension = "hm-backup";

  environment = {
    variables = {
      NIX_PATH = [
        "nixpkgs=${inputs.nixpkgs}"
        "home-manager=${inputs.home-manager}"
      ];
    };
    
    etc = {
      "resolver/ts.net".text = ''
        nameserver 100.100.100.100
      '';

      "nix/nix.custom.conf".knownSha256Hashes = [
        "3bd68ef979a42070a44f8d82c205cfd8e8cca425d91253ec2c10a88179bb34aa"
      ];
    };

    systemPackages = with pkgs; [
      pkg-config
      mas
      starship
      ghostty-bin.terminfo
      (pkgs.writeShellScriptBin "tailscale" ''
        export TAILSCALE_BE_CLI=1
        exec /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
      '')
    ];

    pathsToLink = [
      "/share/fish/vendor_completions.d"
      "/share/fish/vendor_functions.d"
      "/Applications"
    ];
  };

  determinateNix = {
    enable = true;

    customSettings = {      
      extra-trusted-users = [
        "@admin"
      ];
      extra-substituters = [
        "https://cache.numtide.com"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
     extra-experimental-features = [
      "build-time-fetch-tree"
      "parallel-eval"
     ];
      lazy-trees = true;
      connect-timeout = 5;
      keep-derivations = true;
      keep-outputs = true;
    };
  };

  system = {
    tools.darwin-uninstaller.enable = false;
    configurationRevision = flake.rev or flake.dirtyRev or null;

    activationScripts = {
      "tailscaleDns".text = ''
        if ${pkgs.tailscale}/bin/tailscale status >/dev/null 2>&1; then
          ${pkgs.tailscale}/bin/tailscale set --accept-dns=false || true
        fi
      '';

      "postActivation".text = ''
        sudo -u ${config.system.primaryUser} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
    };

    defaults = {
      loginwindow.GuestEnabled = false;

      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXDefaultSearchScope = "SCcf";
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
      };
      
      CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "64" = {
              enabled = false;
            };
            "65" = {
              enabled = false;
            };
          };
        };
      };
    };
  };
}