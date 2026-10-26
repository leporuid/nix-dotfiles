{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
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
    mas
    starship
    ghostty-bin.terminfo

    (writeShellScriptBin "tailscale" ''
      export TAILSCALE_BE_CLI=1
      exec /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
    '')
  ];

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

    customSettings = {
      # Performance and storage optimization for macOS APFS
      auto-optimise-store = false;

      extra-substituters = [
        "https://numtide.com"
        "https://cachix.org"
        "https://cachix.org"
      ];
      extra-trusted-public-keys = [
        #niks3.numtide.com
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
        "lazy-trees"
        "parallel-eval"
        "nix-command"
        "flakes"
      ];
      lazy-trees = true;
      keep-derivations = true;
      keep-outputs = true;
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
        if ${pkgs.tailscale}/bin/tailscale status >/dev/null 2>&1; then
          ${pkgs.tailscale}/bin/tailscale set --accept-dns=false || true
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
            "64".enabled = false;
            "65".enabled = false;
          };
        };
      };
    };
  };
}
