{
  description = "Sharing Hjem and Hjem-Rum modules between NixOS and Darwin with red-tape";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    red-tape = {
      url = "github:otavio/red-tape/fix/home-configurations-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hjem: lightweight $HOME manager alternative to Home Manager
    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";

    # Hjem-Rum: Home Manager-like module collection built on top of Hjem
    hjem-rum.url = "github:snugnug/hjem-rum";
    hjem-rum.inputs.nixpkgs.follows = "nixpkgs";
    hjem-rum.inputs.hjem.follows = "hjem";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Load red-tape via mkFlake
  outputs =
    inputs:
    inputs.red-tape.mkFlake {
      inherit inputs;
      src = ./.;
    };
}
