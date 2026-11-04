{
  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
      "https://crane.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    blueprint.url = "github:leporuid/blueprint/generic-users";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    ktoolbox.url = "github:leporuid/KToolBox/fix-test";
    ktoolbox.inputs.nixpkgs.follows = "nixpkgs";

    homebrew-rayburst.url = "github:AnInsomniacy/homebrew-rayburst";
    homebrew-rayburst.flake = false;

    gallery-ai.url = "github:CrimsonGlory/gallery-ai";
    gallery-ai.flake = false;

    yt-ai.url = "github:CrimsonGlory/yt-ai";
    yt-ai.flake = false;

    n-m3u8dl-re.url = "github:nilaoda/N_m3u8DL-RE/main";
    n-m3u8dl-re.flake = false;

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixcord.url = "github:4evy/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";

    nix-secrets = {
      url = "git+ssh://git@github.com/leporuid/nix-secrets.git";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      nixpkgs.config.allowUnfree = true;
    };
}
