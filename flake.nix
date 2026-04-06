{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    red-tape.url = "github:phaer/red-tape";
    red-tape.inputs.nixpkgs.follows = "nixpkgs";

    ktoolbox.url = "github:leporuid/KToolBox";
    ktoolbox.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    motrix-next.url = "github:AnInsomniacy/motrix-next";
    motrix-next.flake = false;

    darwin-vz-nix.url = "github:takeokunn/darwin-vz-nix";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "nix-darwin";
    agenix.inputs.home-manager.follows = "home-manager";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  outputs =
    inputs:
    let
      darwin-contrib = import "${inputs.red-tape}/contrib/darwin.nix";
      home-manager-contrib = import "${inputs.red-tape}/contrib/home-manager.nix";
    in
    inputs.red-tape.mkFlake {
      inherit inputs;
      src = ./.;
      modules = [
        darwin-contrib
        home-manager-contrib
      ];
    };
}
