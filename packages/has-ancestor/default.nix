{ pkgs, ... }:
let
  inherit (pkgs.lib) licenses platforms;
in
pkgs.stdenv.mkDerivation {
  pname = "has-ancestor";
  version = "0.1.0";

  src = pkgs.lib.fileset.toSource {
    root = ./.;
    fileset = ./main.c;
  };

  buildPhase = ''
    $CC -O2 -Wall -Wextra -o has-ancestor main.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp has-ancestor $out/bin/
  '';

  meta = {
    description = "A tool to check ancestor relationships";
    license = licenses.mit;
    mainProgram = "has-ancestor";
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
