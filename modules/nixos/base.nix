{ ... }: 
{
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;

  determinateNix = {
    enable = true;
    distributedBuilds = true;

    determinateNixd = {
      garbageCollector.strategy = "automatic";
      builder.state = "enabled";
    };

    customSettings = {
      extra-trusted-users = [ "@wheel" ];
      
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
      
      builders-use-substitutes = true;
      lazy-trees = true;
      max-substitution-jobs = 28;
      http-connections = 35;
      connect-timeout = 5;
      warn-dirty = false;
      keep-derivations = true;
      keep-outputs = true;
    };
  };
}