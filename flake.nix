{
  description = "leporuid's nix-dotfiles";

  inputs = {
    red-tape = {
      url = "github:phaer/red-tape";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    motrix-next.url = "github:AnInsomniacy/motrix-next";
    motrix-next.flake = false;

    darwin-vz-nix.url = "github:takeokunn/darwin-vz-nix";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "nix-darwin";
      inputs.home-manager.follows = "home-manager";
    };

    ktoolbox = {
      url = "github:leporuid/KToolBox";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  outputs =
    { self, ... }@inputs:
    inputs.red-tape.mkFlake {
      inherit inputs self;
      src = ./.;
      modules = [
        (import "${inputs.red-tape}/contrib/darwin.nix")
        (import "${inputs.red-tape}/contrib/home-manager.nix")
      ];
    };
}

