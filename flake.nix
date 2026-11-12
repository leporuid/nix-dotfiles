{
  description = "Sharing Hjem and Hjem-Rum modules between NixOS and Darwin with red-tape";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    # Determinate Nix: Determinate Systems' Nix distribution & daemon (do not follow nixpkgs)
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    # Adios-flake: track latest upstream from Mic92
    adios-flake.url = "github:Mic92/adios-flake";

    red-tape = {
      url = "github:otavio/red-tape/fix/home-configurations-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.adios-flake.follows = "adios-flake";
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

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    vpn-pack-src = {
      url = "github:eds-ch/vpn-pack/v1.6.4";
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
