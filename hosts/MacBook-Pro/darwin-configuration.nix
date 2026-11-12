{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.determinate.darwinModules.default
    inputs.hjem.darwinModules.default
    ../../modules/nixos/host-shared.nix
  ];

  # Determinate Nix: Unified Nix distribution, daemon management, and binary caches
  determinateNix = {
    enable = true;

    determinateNixd = {
      garbageCollector.strategy = "automatic";
      builder.state = "enabled";
      telemetry.sentry.endpoint = null;
    };

    customSettings = {
      extra-substituters = [
        "https://cache.numtide.com"
        "https://nix-community.cachix.org"
        "https://crane.cachix.org"
      ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
      ];
      trusted-users = [
        "root"
        "leporuid"
      ];
      accept-flake-config = true;
      auto-optimise-store = false;
      builders-use-substitutes = true;
      connect-timeout = 10;
      fallback = true;
      keep-going = true;
      keep-derivations = true;
      keep-outputs = true;
      log-lines = 25;
      max-free = 3221225472;
      min-free = 1073741824;
      stalled-download-timeout = 20;
      warn-dirty = false;
    };
  };

  # Determinate Nix owns the daemon and nix.conf; disable nix-darwin's Nix management
  # completely to prevent both from competing over /etc/nix/nix.conf and launchd.
  nix.enable = false;
  nix.channel.enable = false;
  nix.nixPath = lib.mkForce [ ];

  hjem = {
    clobberByDefault = true;
    extraModules = [
      inputs.hjem-rum.hjemModules.default
      inputs.hjem-impure.hjemModules.default
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Fish shell integration on macOS
  programs.fish = {
    enable = true;
    useBabelfish = true;
    interactiveShellInit = ''
      if test "$TERM" = "dumb"
        function fish_prompt; echo "\$ "; end
        function fish_right_prompt; end
        function fish_greeting; end
        function fish_title; end
      end
    '';
  };

  environment.pathsToLink = [
    "/share/fish/vendor_completions.d"
    "/share/fish/vendor_functions.d"
  ];

  users.users.leporuid = {
    home = "/Users/leporuid";
    shell = pkgs.fish;
  };

  hjem.users.leporuid =
    { ... }:
    {
      directory = "/Users/leporuid";
      imports = [ ../../users/leporuid/home-configuration.nix ];
    };

  system.stateVersion = 6;
}
