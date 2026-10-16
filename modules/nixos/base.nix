{ inputs, pkgs, ... }:
{
  imports = [
    inputs.determinate.nixosModules.default
  ];

  determinate.enable = true;

  nix.settings = {
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
    
    substituters = [
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
      "https://nixpkgs.cachix.org"
      "https://crane.cachix.org"
    ];
    
    trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
      "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
    ];
    
    experimental-features = [
      "nix-command"
      "flakes"
      "build-time-fetch-tree"
      "parallel-eval"
      "wasm-builtin"
      "parse-toml-timestamps"
      "pipe-operators"
      "fetch-tree"
    ];

    builders-use-substitutes = true;
    max-substitution-jobs = 28;
    http-connections = 35;
    connect-timeout = 5;
    warn-dirty = false;
    keep-derivations = true;
    keep-outputs = true;
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}