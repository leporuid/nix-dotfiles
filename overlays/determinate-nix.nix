inputs: final: prev:
  let
    determinateNix = inputs.determinate.inputs.nix.packages.${prev.stdenv.system}.default;
  in
  {
    # Override packages that use nix to use Determinate Nix
    nix-update = prev.nix-update.override { nix = determinateNix; };
    nixpkgs-review = prev.nixpkgs-review.override { nix = determinateNix; };
    comma = prev.comma.override { nix = determinateNix; };
  }
