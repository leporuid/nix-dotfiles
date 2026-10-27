{ inputs, ... }:
{ nixCaches, ... }:
{
  imports = [
    inputs.determinate.nixosModules.default
    inputs.self.modules.common.nix-caches
  ];

  determinate.enable = true;

  nix.settings = {
    inherit (nixCaches) extra-substituters extra-trusted-public-keys;

    experimental-features = [
      "nix-command"
      "flakes"
      "parallel-eval"
    ];

    accept-flake-config = true;
    auto-optimise-store = true;
    auto-allocate-uids = true;
    builders-use-substitutes = true;
    connect-timeout = 5;
    eval-cores = 0;
    fallback = true;
    http-connections = 50;
    keep-going = true;
    lazy-trees = true;
    log-lines = 25;
    max-free = 3221225472;
    max-jobs = "auto";
    min-free = 1073741824;
    stalled-download-timeout = 20;
    warn-dirty = false;

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
