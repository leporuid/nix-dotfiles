{ inputs, ... }:
{
  imports = [
    inputs.determinate.nixosModules.default
  ];

  determinate.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    extra-substituters = [
    "https://cache.numtide.com"
    "https://nix-community.cachix.org"
    "https://crane.cachix.org"
  ];
    extra-trusted-public-keys = [
    # cache.numtide.com
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="

    # nix-community.cachix.org
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

    # crane.cachix.org
    "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
  ];

    auto-optimise-store = true;
    builders-use-substitutes = true;
    lazy-trees = true;

    trusted-users = [
      "leporuid"
    ];
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
