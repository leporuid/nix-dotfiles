{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-swift.url = "github:reckenrode/nixpkgs?ref=swift-update-mk2";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    # blueprint.url = "path:/Users/leporuid/Developer/blueprint";
    # blueprint.url = "github:numtide/blueprint";
    blueprint.url = "github:leporuid/blueprint/generic-users";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # helix.url = "github:clo4/helix/helix-cogs-steel-language-server";
    # helix.inputs.nixpkgs.follows = "nixpkgs";
    # helix.inputs.crane.follows = "crane";
    # crane.url = "github:ipetkov/crane";
    # steel.url = "github:mattwparas/steel";
    # steel.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    darwin-vz-nix.url = "github:takeokunn/darwin-vz-nix";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "nix-darwin";
    agenix.inputs.home-manager.follows = "home-manager";
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      nixpkgs.config.allowUnfree = true;
    };
}
