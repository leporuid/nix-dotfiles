{ inputs, flake, config, pkgs, lib,  ... }:
let
  hostname = "MacBook-Pro";
in
with lib;
{
  imports = [
    inputs.determinate.darwinModules.default
  ];
  
  users.users."${config.system.primaryUser}" = {
    description = "Yu-Min Peng";
    home = "/Users/${config.system.primaryUser}";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINaZLCaoAppOpXqJmBrB8AOCEc7zffCWU3G0P+9W4tnL"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrcoI6oOTch+FI7XVlJ5eYJaGx4ZO2noO9GcXVFMhn9"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyz8c5h0/9ejDcYYkUZ568FUw0OAQEPfRnIbbbd4xGe"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAIJNFFaMxFGkxbzGvTtFfu+DPlxtqK0NoaExRVDvCt"
    ];
    openssh.authorizedKeys.keyFiles = [
      "${flake}/hosts/${hostname}/users/leporuid/id_ed25519.pub"
      "${flake}/hosts/${hostname}/id_ed25519.pub"
    ];
   };


  environment.pathsToLink = [
    "/Applications" 
    "/share/fish/vendor_completions.d"
    "/share/fish/vendor_functions.d"
  ];

  documentation.doc.enable = false;
  programs.zsh.enable = true;
  environment.enableAllTerminfo = true;
  environment.variables = {
    MANPATH = "${config.system.path}/share/man";
  };

  environment.systemPackages = with pkgs; [
    pkg-config
    mas
    inputs.determinate.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.starship
    (pkgs.writeShellScriptBin "tailscale" ''
      export TAILSCALE_BE_CLI=1
      exec /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
    '')
   ] ++ (with inputs.nix-darwin.packages.${pkgs.stdenv.hostPlatform.system}; [
    darwin-option
    darwin-rebuild
    darwin-version
    darwin-uninstaller
   ]);
  

  environment.etc."nix/registry.json".text = builtins.toJSON {
          version = 2;
          flakes = [
            {
              from = {
                type = "indirect";
                id = "nixpkgs";
              };
              to = {
                type = "path";
                path = inputs.self.outPath;
              };
            }
          ];
        };


  time.timeZone = "Asia/Taipei";
  ids.gids.nixbld = 30000;

  determinateNix = {
    enable = true;
    distributedBuilds = true;
    customSettings = {
      flake-registry = "";
      trusted-users = [
        "root"
        "@admin"
      ];
      http2 = false;
      lazy-trees = true;
      extra-substituters = [
        "https://cache.numtide.com"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs.cachix.org"
        "https://crane.cachix.org"
      ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
      ];
      builders-use-substitutes = true;
      extra-experimental-features = [
        "build-time-fetch-tree"
        "external-builders"
        "parallel-eval"
        "wasm-builtin"
        "parse-toml-timestamps"
        "pipe-operators"
        "blake3-hashes"
        "verified-fetches"
        "fetch-tree"
        "git-hashing"
      ];
      max-substitution-jobs = 64;
      http-connections = 35;
      connect-timeout = 5;
      warn-dirty = false;
      keep-derivations = true;
      keep-outputs = true;
      keep-going = true;
      stalled-download-timeout = 20;
      sandbox = true;
      sandbox-fallback = false;
    };

    determinateNixd = {
      garbageCollector.strategy = "automatic";
      builder.state = "enabled";
    };
  };

  system = {
    tools.darwin-uninstaller.enable = false;
    configurationRevision = flake.rev or flake.dirtyRev or null;
    stateVersion = 5;
    activationScripts.postActivation.text = ''
    sudo -u ${config.system.primaryUser} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

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
        "com.apple.keyboard.fnState" = false;
      };
    };
  };
}