{
  description = "leporuid's Nix home";

  inputs = {
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
    let
      system = "aarch64-darwin";

      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Mirrors blueprint's perSystem convention:
      # perSystem.${inputName}.${pkgName} = inputs.${inputName}.packages.${system}.${pkgName}
      # perSystem.self.${pkgName}         = self.packages.${system}.${pkgName}
      perSystem =
        builtins.mapAttrs (
          _: input:
          if builtins.isAttrs input && input ? packages && input.packages ? ${system} then
            input.packages.${system}
          else
            { }
        ) inputs
        // {
          self = self.packages.${system};
        };
    in
    {
      # ── Packages ────────────────────────────────────────────────────────────
      packages.${system} = {
        run = import ./packages/run.nix { inherit pkgs; flake = self; };
        age-plugin-se = import ./packages/age-plugin-se.nix { inherit pkgs perSystem; flake = self; };
        ccase = import ./packages/ccase.nix { inherit pkgs; pname = "ccase"; flake = self; };
        cktool = import ./packages/cktool.nix { inherit pkgs; pname = "cktool"; flake = self; };
        has-ancestor = import ./packages/has-ancestor { inherit pkgs; };
        kumono = import ./packages/kumono.nix { inherit pkgs; pname = "kumono"; flake = self; };
        megabasterd = import ./packages/megabasterd.nix { inherit pkgs; pname = "megabasterd"; flake = self; };
        schemat = import ./packages/schemat.nix { inherit pkgs; pname = "schemat"; flake = self; };
      };

      # ── Darwin modules (nix-darwin/) ────────────────────────────────────────
      darwinModules = {
        system-defaults = import ./nix-darwin/system-defaults.nix;
        fish-environment = import ./nix-darwin/fish-environment.nix;
        homebrew = import ./nix-darwin/homebrew.nix;
      };

      # ── Home Manager modules (home-manager/) ────────────────────────────────
      homeModules = {
        my-config = import ./home-manager/my-config.nix;
        my-programs-fish = import ./home-manager/my-programs-fish.nix;
        my-programs-neovim = import ./home-manager/my-programs-neovim.nix;
      };

      # ── Common modules (modules/common/) ────────────────────────────────────
      modules.common = {
        nixpkgs-unstable = import ./modules/common/nixpkgs-unstable.nix;
        determinate = import ./modules/common/determinate.nix;
      };

      # ── Darwin configurations ────────────────────────────────────────────────
      darwinConfigurations.MagiHoHo = inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          flake = self;
        };
        modules = [
          inputs.home-manager.darwinModules.home-manager
          ./hosts/MagiHoHo/darwin-configuration.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs perSystem;
                flake = self;
              };
              users.leporuid = ./hosts/MagiHoHo/users/leporuid/home-configuration.nix;
            };
          }
        ];
      };

      # ── Dev shell ────────────────────────────────────────────────────────────
      devShells.${system}.default = pkgs.mkShellNoCC {
        name = "nix-dotfiles";
        packages =
          [
            inputs.home-manager.packages.${system}.default
            inputs.agenix.packages.${system}.default
            self.packages.${system}.run
            pkgs.nixos-rebuild
            pkgs.nixos-anywhere
            pkgs.nixd
            pkgs.taplo
            pkgs.age
            pkgs.deno
            inputs.nix-darwin.packages.${system}.darwin-rebuild
          ];
        shellHook = ''
          export IN_NIX_CONFIG_DEVSHELL=1
        '';
      };
    };
}
