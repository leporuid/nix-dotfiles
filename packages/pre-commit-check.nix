{
  inputs,
  pkgs,
  ...
}:
let
  treefmtConfig = {
    projectRootFile = "flake.nix";

    programs.nixfmt.enable = true;
    programs.deadnix.enable = true;
    programs.statix.enable = true;
    programs.taplo.enable = true;
    programs.fish_indent.enable = true;
    programs.yamlfmt.enable = true;

    settings.global.excludes = [
      "*.age"
      "flake.lock"
      ".direnv/**"
      "*.bttpreset"
      "*.tar.gz"
    ];
  };

  treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs treefmtConfig;

  preCommitCheck = inputs.git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
    src = inputs.self;
    package = pkgs.pre-commit.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
      nativeCheckInputs = [ ];
      checkInputs = [ ];
    });
    hooks = {
      statix.enable = true;
      deadnix.enable = true;
      treefmt = {
        enable = true;
        package = treefmtEval.config.build.wrapper;
      };
    };
  };
in
preCommitCheck // {
  passthru = (preCommitCheck.passthru or { }) // {
    treefmt = treefmtEval.config.build.wrapper;
  };
}
