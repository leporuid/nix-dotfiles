{ inputs, ... }:
let
  nixCaches = import ../common/nix-caches.nix;
in
{
  imports = [
    inputs.determinate.nixosModules.default
  ];

  determinate.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "parallel-eval"
    ];

    inherit (nixCaches) extra-substituters extra-trusted-public-keys;
    auto-optimise-store = true;
    builders-use-substitutes = true;
    lazy-trees = true;

    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
