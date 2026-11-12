{
  inputs,
  pkgs,
  ...
}:
let
  treefmtConfig = import ../treefmt.nix { inherit pkgs; };
  treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs treefmtConfig;
  treefmtWrapper = treefmtEval.config.build.wrapper;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "pre-commit-check";
  src = inputs.self;

  nativeBuildInputs = [
    treefmtWrapper
  ];

  phases = [
    "unpackPhase"
    "checkPhase"
    "installPhase"
  ];

  doCheck = true;
  checkPhase = ''
    ${treefmtWrapper}/bin/treefmt --fail-on-change
  '';

  installPhase = ''
    touch $out
  '';

  passthru = {
    treefmt = treefmtWrapper;
    shellHook = ''
            if [ -d .git ] && [ ! -f .git/hooks/pre-commit ]; then
              mkdir -p .git/hooks
              cat << 'EOF' > .git/hooks/pre-commit
      #!/usr/bin/env sh
      exec ${treefmtWrapper}/bin/treefmt --fail-on-change
      EOF
              chmod +x .git/hooks/pre-commit
            fi
    '';
  };
}
