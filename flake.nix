{
  description = "Nix dotfiles for leporuid";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    red-tape = {
      url = "github:phaer/red-tape";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    motrix-next = {
      url = "github:AnInsomniacy/motrix-next";
      flake = false;
    };
    
    ktoolbox = {
  	url = "github:leporuid/KToolBox/uv-migration";
  	inputs.nixpkgs.follows = "nixpkgs";
    };
    
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "nix-darwin";
      inputs.home-manager.follows = "home-manager";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, red-tape, ... }:
    let
      username = "leporuid";
      systems = [ "aarch64-darwin" ];

      overlay = import ./overlays/default.nix { inherit inputs; };

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      pkgsFor = system: import nixpkgs {
      inherit system;
      overlays = [ overlay ];
      config.allowUnfree = true;
    };
    pkgs' = system: import nixpkgs-unstable {
      inherit system;
      overlays = [ overlay ];
      config.allowUnfree = true;
    };     
    in
    (red-tape.mkFlake {
      inherit inputs self;
      src = ./.;

      modules = [
        ({ ... }: {
          _module.args = {
            inherit username;
          };
          _module.args.pkgs' = system: import nixpkgs-unstable {
            inherit system;
            overlays = [ overlay ];
            config.allowUnfree = true;
     	  };
        })

        (import "${inputs.red-tape}/contrib/darwin.nix")
        (import "${inputs.red-tape}/contrib/home-manager.nix")
      ];
    }) // {
      overlays.default = overlay;

      packages = forAllSystems (system: {
        default = import ./packages/run.nix {
          pkgs = pkgsFor system;
          flake = self;
        };

        run = import ./packages/run.nix {
          pkgs = pkgsFor system;
          flake = self;
        };

        hx = import ./packages/helix.nix {
          pkgs = pkgsFor system;
          flake = self;
        };

        helix = import ./packages/helix-clo4.nix {
          pkgs = pkgsFor system;
          perSystem = self.packages.${system};
          flake = self;
        };
      });

      devShells = forAllSystems (system: {
  	default = import ./devshell.nix {
    	pkgs = pkgsFor system;
    	flake = self;
    	home-manager = inputs.home-manager.packages.${system}.default;
    	agenix = inputs.agenix.packages.${system}.default;
    	run = self.packages.${system}.run;
    	nix-darwin = inputs.nix-darwin.packages.${system}.default;
      };
    });
    };
}