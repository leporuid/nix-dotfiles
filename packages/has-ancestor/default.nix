{ pkgs, pname, ... }:

pkgs.stdenv.mkDerivation {
  pname = "has-ancestor";
  version = "0.1.0";

  src = ./.;

  buildPhase = ''
    $CC -O2 -Wall -Wextra -o has-ancestor main.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp has-ancestor $out/bin/
  '';

  meta = with pkgs.lib; {
    description = "A tool to check ancestor relationships";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.unix;
  };
}