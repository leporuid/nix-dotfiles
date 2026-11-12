{
  description = "Sharing Hjem and Hjem-Rum modules between NixOS and Darwin with red-tape";

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

    # Determinate Nix: Determinate Systems' Nix distribution & daemon (do not follow nixpkgs)
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    red-tape = {
      url = "path:../otavio-red-tape";
      inputs.adios-flake.follows = "github:Mic92/adios-flake";
    };


    # Hjem: lightweight $HOME manager alternative to Home Manager
    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";

    # Hjem-Rum: Home Manager-like module collection built on top of Hjem
    hjem-rum.url = "github:snugnug/hjem-rum";
    hjem-rum.inputs.nixpkgs.follows = "nixpkgs";
    hjem-rum.inputs.hjem.follows = "hjem";

    # Hjem-Impure: out-of-store symlinking for live dotfile editing without rebuilds
    hjem-impure = {
      url = "github:Rexcrazy804/hjem-impure";
      inputs.nixpkgs.follows = "";
      inputs.hjem.follows = "";
    };

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.inputs.treefmt-nix.follows = "treefmt";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    ktoolbox.url = "github:leporuid/KToolBox/uv2nix";
    ktoolbox.inputs.nixpkgs.follows = "nixpkgs";

    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt";
    };

    multiverse.url = "github:fzakaria/nixpkgs-multiverse";

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew-rayburst.url = "github:AnInsomniacy/homebrew-rayburst";
    homebrew-rayburst.flake = false;

    gallery-ai.url = "github:CrimsonGlory/gallery-ai";
    gallery-ai.flake = false;

    yt-ai.url = "github:CrimsonGlory/yt-ai";
    yt-ai.flake = false;

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixcord.url = "github:4evy/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";
    nixcord.inputs.treefmt-nix.follows = "treefmt";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    ghostty-cursor-shaders = {
      url = "github:sahaj-b/ghostty-cursor-shaders";
      flake = false;
    };

    vpn-pack-src = {
      url = "github:eds-ch/vpn-pack/v1.6.4";
      flake = false;
    };

    nix-secrets.url = "git+ssh://git@github.com/leporuid/nix-secrets.git";
  };

  # Load red-tape via mkFlake
  outputs =
    inputs:
    inputs.red-tape.mkFlake {
      inherit inputs;
      src = ./.;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
}
