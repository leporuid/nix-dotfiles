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
    red-tape.url = "github:/leporuid/red-tape";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Determinate Nix: Determinate Systems' Nix distribution & daemon (do not follow nixpkgs)
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    hjem = {
      # Hjem: lightweight $HOME manager alternative to Home Manager
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem-rum = {
      # Hjem-Rum: Home Manager-like module collection built on top of Hjem
      url = "github:snugnug/hjem-rum";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        hjem.follows = "hjem";
      };
    };
    # Hjem-Impure: out-of-store symlinking for live dotfile editing without rebuilds
    hjem-impure = {
      url = "github:Rexcrazy804/hjem-impure";
      inputs = {
        nixpkgs.follows = "";
        hjem.follows = "";
      };
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt";
      };
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    ktoolbox = {
      url = "github:leporuid/KToolBox/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt";
      };
    };
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt";
      };
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-rayburst = {
      url = "github:AnInsomniacy/homebrew-rayburst";
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
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:4evy/nixcord";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt";
      };
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    { self, ... }@inputs:
    inputs.red-tape.mkFlake {
      inherit inputs self;
      src = ./.;
      modules = [
        inputs.red-tape.modules.redTape.darwin
        inputs.red-tape.modules.redTape.hjem
        {
          name = "hjem-outputs";
          outputs.hjemModules = {
            type = "attrset";
            scope = "flake";
          };
        }
      ];
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      flake = {
        overlays.default = inputs.nixpkgs.lib.composeManyExtensions (import ./overlays { inherit inputs; });
      };
    };
}
