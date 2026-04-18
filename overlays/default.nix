{ inputs, ... }:
final: prev: {
  my = {
    run = import ../packages/run.nix { pkgs = final; flake = final; };
    helix = inputs.helix.packages.${final.stdenv.hostPlatform.system}.helix;
    steel = prev.steel.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        if [ -e "$out/bin/forge" ]; then
          chmod +x "$out/bin/forge"
        fi
      '';
    });
    hx = import ../packages/helix.nix {
      pkgs = final;
      flake = inputs.self;
    };
    hx-clo4 = import ../packages/helix-clo4.nix {
      pkgs = final;
      perSystem = final.my;
      flake = inputs.self;
    };

    has-ancestor = import ../packages/has-ancestor/default.nix {
      pkgs = final;
    };

    ktoolbox = inputs.ktoolbox.packages.${final.stdenv.hostPlatform.system}.default;

    schemat = import ../packages/schemat.nix {
      pname = "schemat";
      pkgs = final;
    };

    megabasterd = import ../packages/megabasterd.nix {
      pname = "megabasterd";
      pkgs = final;
    };

    kumono = import ../packages/kumono.nix {
      pname = "kumono";
      pkgs = final;
    };

    cktool = import ../packages/cktool.nix {
      pname = "cktool";
      pkgs = final;
    };

    ccase = import ../packages/ccase.nix {
      pname = "ccase";
      pkgs = final;
    };

    age-plugin-se = import ../packages/age-plugin-se.nix {
      pkgs = final;
    };
  };

  nushell = prev.nushell.overrideAttrs (old: { doCheck = false; });

  determinate =
    if inputs.determinate ? packages && builtins.hasAttr final.stdenv.hostPlatform.system inputs.determinate.packages
    then inputs.determinate.packages.${final.stdenv.hostPlatform.system}.default
    else throw "determinate package set is not available for ${final.stdenv.hostPlatform.system}";
}