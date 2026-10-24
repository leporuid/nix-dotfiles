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
    inherit (nixCaches) extra-substituters extra-trusted-public-keys;

    auto-optimise-store = true;
    trusted-users = [
      "root"
      "@wheel"
    ];

    extra-experimental-features = [
      "nix-command"
      "flakes"
      "parallel-eval"
    ];

    builders-use-substitutes = true;
    lazy-trees = true;
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
