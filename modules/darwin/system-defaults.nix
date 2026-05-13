{ inputs, flake, config, pkgs, lib,  ... }:
let
  username = "leporuid";
in
with lib;
{
  imports = [
    inputs.determinate.darwinModules.default
  ];

  nix.nixPath = lib.mkForce [
      "nixpkgs=${inputs.nixpkgs}"
      "home-manager=${inputs.home-manager}"
    ];

   users.users.root = {
        home = "/var/root";
        shell = "/bin/zsh";
        openssh.authorizedKeys.keyFiles = config.users.users.${username}. openssh.authorizedKeys.keyFiles;
        openssh.authorizedKeys.keys = config.users.users.${username}. openssh.authorizedKeys.keys;
      };

  environment.systemPackages = with pkgs; [
   pkg-config
   mas
   ] ++ (with inputs.nix-darwin.packages.${pkgs.stdenv.hostPlatform.system}; [
    darwin-option
    darwin-rebuild
    darwin-version
    darwin-uninstaller
    ]);
  ids.gids.nixbld = 350;

  environment.pathsToLink = [
    "/share/fish/vendor_completions.d"
    "/share/fish/vendor_functions.d"
    "/Applications" 
  ];

  environment.variables = {
    MANPATH = "${config.system.path}/share/man";
  };

  determinateNix = {
    enable = true;
    distributedBuilds = true;
    customSettings = {
      flake-registry = "https://install.determinate.systems/flake-registry/stable/flake-registry.json";
      trusted-users = [ "@admin" ];
      extra-substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs.cachix.org"
        "https://crane.cachix.org"
      ];
      extra-trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
      ];
      accept-flake-config = true;
      builders-use-substitutes = true;
      extra-experimental-features = [
        "build-time-fetch-tree"
        "external-builders"
        "parallel-eval"
        "wasm-builtin"
      ];
      keep-derivations = true;
      keep-outputs = true;
      max-free = 5368709120;
      min-free = 1073741824;
      warn-dirty = false;
      extra-platforms = "x86_64-darwin";
      log-lines = 25;
    };

    determinateNixd = {
      builder.cpuCount = 4;
      builder.memoryBytes = 16 * 1024 * 1024 * 1024;
      builder.state = "disabled";
    };
  };

  system = {
    configurationRevision = flake.rev or flake.dirtyRev or "unknown";

    defaults = {
      loginwindow.GuestEnabled = false;

      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
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
        "com.apple.keyboard.fnState" = false;
      };
    };
  };
}