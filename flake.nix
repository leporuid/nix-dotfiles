{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    blueprint = {
      url = "github:leporuid/blueprint/generic-users";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    ktoolbox = {
      url = "github:leporuid/KToolBox/fix-test";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew-rayburst = {
      url = "github:AnInsomniacy/homebrew-rayburst";
      flake = false;
    };

    catppuccin-bat = {
      url = "github:catppuccin/bat";
      flake = false;
    };

    gallery-ai = {
      url = "github:CrimsonGlory/gallery-ai";
      flake = false;
    };

    yt-ai = {
      url = "github:CrimsonGlory/yt-ai";
      flake = false;
    };

    n-m3u8dl-re = {
      url = "github:nilaoda/N_m3u8DL-RE/main";
      flake = false;
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [ (import overlays/default.nix { inherit inputs; }) ];
    };
}
