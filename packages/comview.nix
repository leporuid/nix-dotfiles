{ pkgs, pname, ... }:
pkgs.buildGoModule {
  inherit pname;
  version = "0-unstable-2026-11-13";
  src = pkgs.fetchFromGitHub {
    owner = "rockorager";
    repo = "comview";
    rev = "8508f29ddcdf8dd8a93e93e2d7b0b940c31b6ab8";
    hash = "sha256-9wAz+TwamMtNkBH0Og2wy2SPlM1QiQzuizRrkYq5EfM=";
  };
  vendorHash = "sha256-f7Q4+Bd22xnxkOWjgv4TzPmgZTNHhYvMtoVyl9anGzc=";

  meta = {
    description = "The best diff viewer ever made";
    homepage = "https://github.com/rockorager/comview";
    license = pkgs.lib.licenses.mit;
    mainProgram = "comview";
    maintainers = [ ];
  };
}
